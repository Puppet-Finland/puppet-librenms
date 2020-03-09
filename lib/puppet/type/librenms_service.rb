

# frozen_string_literal: true

# LibreNMS service type for Puppet
module Puppet
  Type.newtype(:librenms_service) do
    require 'uri'

    @doc = 'Manage LibreNMS services'

    ensurable do
      desc 'Create or remove the device.'

      newvalue(:present) do
        provider.create
      end

      newvalue(:absent) do
        provider.destroy
      end

      defaultto :present
    end

    newparam(:hostname) do
      desc 'Hostname or IP of the device'
    end

    newparam(:url) do
      desc 'LibreNMS API endpoint (e.g. https://librenms.example.org/api/v0)'
      validate do |url|
        raise('Property auth_token must be a string') unless url.is_a?(String)
      end
    end

    newparam(:auth_token) do
      desc 'LibreNMS API token'
      validate do |auth_token|
        unless auth_token.is_a?(String)
          raise('Property auth_token must be a string')
        end
      end
    end

    newparam(:desc, namevar: true) do
      desc 'Description (Used internally by Puppet, do not touch)'
      validate do |desc|
        unless desc.is_a?(String)
          raise('Property desc must be a string')
        end
      end
    end

    newproperty(:type) do
      desc 'Type of the monitored service'
      validate do |type|
        unless type.is_a?(String)
          raise('Property type must be a string')
        end
      end
    end

    newproperty(:ip) do
      desc 'IP of the monitored service'
      validate do |ip|
        unless ip.is_a?(String)
          raise('Property IP must be a string')
        end
      end
    end

    newproperty(:param) do
      desc 'Parameters for the service'
      validate do |param|
        unless param.is_a?(String)
          raise('Property param must be a string')
        end
      end
    end
  end
end
