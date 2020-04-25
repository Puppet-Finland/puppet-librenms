# frozen_string_literal: true

Puppet::Type.type(:librenms_service).provide(:api) do
  require 'rubygems'
  require 'rest_client'
  require 'json'

  defaultfor kernel: 'Linux'

  def exists?
    # This emulates the @property_hash. For the rationale refer to  the
    # librenms_device provider implementation.
    @my_properties = {}

    devices_response = RestClient.get "#{resource['url']}/services/#{resource[:hostname]}",
                                      accept: :json,
                                      content_type: :json,
                                      x_auth_token: resource['auth_token']

    body = JSON.parse(devices_response.body)

    # Check for existance of matching services. There can be several that have
    # exactly the same parameters _except_ for 'service_id'.
    @my_properties['matching_service_ids'] = []

    body['services'][0].each do |service|
      # We set the value of "service_desc" field to the resource title. That is
      # the only field in LibreNMS services that has no practical effect and
      # which can be used as an identifier at the LibreNMS end. The service_id
      # field is useless because its value is dynamically assigned by LibreNMS.
      next unless service['service_desc'] == resource[:desc]

      # This is a match, so populate the resource hash
      @my_properties['matching_service_ids'] << service['service_id']

      # There's no point in filling @my_properties with duplicate information
      next unless @my_properties['matching_service_ids'].length == 1
      properties = ['ip', 'type', 'param', 'desc']
      properties.each do |property|
        @my_properties[property] = service['service_' + property]
      end
    end

    Puppet.debug("Matching services: #{@my_properties}")

    if @my_properties['matching_service_ids'].empty?
      false
    elsif @my_properties['matching_service_ids'].length > 1
      raise Puppet::Error, "Multiple matching services found! Please ensure that there's only one service that has a \"desc\" property that matches #{resource[:desc]}"
    else
      true
    end
  end

  def create
    data = { 'type'  => resource[:type],
             'ip'    => resource[:ip],
             'desc'  => resource[:desc],
             'param' => resource[:param] }

    begin
      RestClient.post "#{resource[:url]}/services/#{resource[:hostname]}",
                      data.to_json,
                      x_auth_token: resource[:auth_token]
    rescue StandardError => e
      raise "LibreNMS add_service_to_host API call failed for resource #{resource[:name]}: #{e.message}."
    end
  end

  def destroy
    @my_properties['matching_service_ids'].each do |service_id|
      RestClient.delete "#{resource[:url]}/services/#{service_id}", x_auth_token: resource[:auth_token]
    end
  rescue StandardError => e
    raise "LibreNMS delete_service_from_host API call failed for resource #{resource[:name]}: #{e.message}."
  end

  def update_service_field(field, data)
    data = { field => data }
    begin
      # We only ever touch the first match, i.e. service with "desc" field set
      # to resource[:name].  Otherwise there would be the risk that Puppet
      # would overwrite settings in a large number of  manually configured
      # services. That said, this provider will bail out earlier in the exists?
      # method before that becomes an issue.
      service_id = @my_properties['matching_service_ids'][0]
      RestClient.patch "#{resource[:url]}/services/#{service_id}",
                       data.to_json,
                       x_auth_token: resource[:auth_token]
      Puppet.debug("Field #{data['field']} changed to #{data['data']} for service_id #{service_id}")
    rescue StandardError
      raise "LibreNMS update_device_field API call failed for resource #{resource[:name]} field #{field}"
    end
  end

  def type
    @my_properties['type']
  end

  def type=(value)
    update_service_field('service_type', value)
  end

  def ip
    @my_properties['ip']
  end

  def ip=(value)
    update_service_field('service_ip', value)
  end

  def desc
    @my_properties['desc']
  end

  def desc=(value)
    update_service_field('service_desc', value)
  end

  def param
    @my_properties['param']
  end

  def param=(value)
    update_service_field('service_param', value)
  end
end
