require 'uri'

# frozen_string_literal: true

# LibreNMS device type for Puppet
module Puppet
  Type.newtype(:librenms_device) do
    @doc = 'Manage LibreNMS devices'

    validate do
      if self[:snmpver] == :v3 && self[:community]
        raise('community is only valid for SNMP v1/v2c')
      end

      if self[:snmpver] != :v3
        params = %i[authlevel authname authpass authalgo cryptopass cryptoalgo]
        params.each do |param|
          raise("Parameter #{param} is only valid for SNMPv3") if self[param]
        end
      end
    end

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

    newparam(:hostname, namevar: true) do
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

    newproperty(:community) do
      desc 'SNMP community'
      validate do |community|
        unless community.is_a?(String)
          raise('Property community must be a string')
        end
      end
    end

    newproperty(:authlevel) do
      desc 'SNMP authlevel'
      newvalues(:noAuthNoPriv, :authNoPriv, :authPriv)
    end

    newproperty(:authname) do
      desc 'SNMP auth username'
      validate do |authname|
        unless authname.is_a?(String)
          raise('Property authname must be a string')
        end
      end
    end

    newproperty(:authpass) do
      desc 'SNMP auth password'
      validate do |authpass|
        unless authpass.is_a?(String)
          raise('Property authpass must be a string')
        end
      end
    end

    newproperty(:authalgo) do
      desc 'SNMP auth algorithm'
      newvalues(:md5, :sha)
      munge do |value|
        value.upcase!
      end
    end

    newproperty(:cryptopass) do
      desc 'SNMP crypto password'
      validate do |cryptopass|
        unless cryptopass.is_a?(String)
          raise('Property cryptopass must be a string')
        end
      end
    end

    newproperty(:cryptoalgo) do
      desc 'SNMP crypto algorithm'
      newvalues(:aes, :des)
      munge do |value|
        value.upcase!
      end
    end

    newproperty(:snmpver) do
      desc 'SNMP version'
      newvalues(:v1, :v2c, :v3)
      defaultto :v2c
    end

    newproperty(:port) do
      desc 'SNMP port'
      defaultto 161
      validate do |port|
        raise('Property port must be an integer') unless port.is_a?(Integer)
        unless port.between?(1, 65_535)
          raise("Invalid port #{port}. Valid range is from 1 to 65535.")
        end
      end
    end
  end
end
