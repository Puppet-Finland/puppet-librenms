# frozen_string_literal: true

Puppet::Type.type(:librenms_device).provide(:api) do

  require 'rubygems'
  require 'rest_client'
  require 'json'

  defaultfor kernel: 'Linux'

  def exists?
    begin
      devices_response = RestClient.get "#{resource[:url]}/devices",
                                        accept: :json,
                                        content_type: :json,
                                        x_auth_token: resource[:auth_token]
    rescue StandardError
      raise "LibreNMS get_devices API call failed for resource #{resource[:name]}"
    end

    # Store this resource's parameters in a hash. We can't use self.prefetch
    # for two reasons:
    #
    # 1. It runs once per provider type and there may be multiple LibreNMS
    #    instances with different connectio details (url, auth_token)
    #    defined in the catalog.
    # 2. It does not have access to connection details (url, auth_token)
    #    stored in each resource's properties
    #
    # What we can do, however, is create an instance variable - something akin
    # to @property_hash - and make use of it in the getter methods. This
    # reduces the number of API calls by a very large amount.
    @my_properties = {}

    body = JSON.parse(devices_response.body)

    body['devices'].each do |device|
      next unless device['hostname'] == resource[:name]

      # Populate properties of this instance
      properties = %w[authalgo authlevel authname authpass community
                      cryptoalgo cryptopass port snmpver]
      properties.each do |property|
        @my_properties[property] = device[property]
      end
    end

    if @my_properties.empty?
      false
    else
      true
    end
  end

  def snmp_v2c_data
    { 'hostname' => resource[:name],
      'port' => resource[:port],
      'version' => resource[:snmpver],
      'community' => resource[:community],
      'force_add' => true }
  end

  def snmp_v3_data
    { 'hostname' => resource[:name],
      'port' => resource[:port],
      'version' => resource[:snmpver],
      'authlevel' => resource[:authlevel],
      'authname' => resource[:authname],
      'authpass' => resource[:authpass],
      'authalgo' => resource[:authalgo],
      'cryptopass' => resource[:cryptopass],
      'cryptoalgo' => resource[:cryptoalgo],
      'force_add' => true }
  end

  def create
    # Construct data differently for SNMP v1/v2c and v3 clients. The validate
    # function in the type ensures that we don't need excessive logic at this
    # point.
    if resource[:snmpver] =~ /(v1|v2c)/
      data = snmp_v2c_data
    elsif resource[:snmpver] == :v3
      data = snmp_v3_data
    end

    begin
      RestClient.post "#{resource[:url]}/devices",
                      data.to_json,
                      x_auth_token: resource[:auth_token]
    rescue StandardError
      raise "LibreNMS add_device API call failed for resource #{resource[:name]}"
    end
  end

  def destroy
    RestClient.delete "#{resource[:url]}/devices/#{resource[:name]}",
                      x_auth_token: resource[:auth_token]
  rescue StandardError
    raise "LibreNMS del_device API call failed for resource #{resource[:name]}"
  end

  def update_device_field(field, data)
    data = { 'field' => field, 'data' => data }
    begin
      RestClient.patch "#{resource[:url]}/devices/#{resource[:name]}",
                       data.to_json,
                       x_auth_token: resource[:auth_token]
    rescue StandardError
      raise "LibreNMS update_device_field API call failed for resource #{resource[:name]} field #{field}"
    end
  end

  def authlevel
    @my_properties['authlevel']
  end

  def authlevel=(value)
    update_device_field('authlevel', value)
  end

  def authname
    @my_properties['authname']
  end

  def authname=(value)
    update_device_field('authname', value)
  end

  def authpass
    @my_properties['authpass']
  end

  def authpass=(value)
    update_device_field('authpass', value)
  end

  def authalgo
    @my_properties['authalgo']
  end

  def authalgo=(value)
    update_device_field('authalgo', value)
  end

  def community
    @my_properties['community']
  end

  def community=(value)
    update_device_field('community', value)
  end

  def cryptopass
    @my_properties['cryptopass']
  end

  def cryptopass=(value)
    update_device_field('cryptopass', value)
  end

  def cryptoalgo
    @my_properties['cryptoalgo']
  end

  def cryptoalgo=(value)
    update_device_field('cryptoalgo', value)
  end

  def snmpver
    @my_properties['snmpver']
  end

  def snmpver=(value)
    update_device_field('snmpver', value)
  end

  def port
    @my_properties['port']
  end

  def port=(value)
    update_device_field('port', value)
  end
end
