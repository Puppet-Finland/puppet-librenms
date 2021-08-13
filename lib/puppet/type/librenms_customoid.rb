# frozen_string_literal: true

# LibreNMS CustomOID type for Puppet
module Puppet
  Type.newtype(:librenms_customoid) do
    require 'uri'

    @doc = 'Manage LibreNMS CustomOIDs'

    ensurable do
      desc 'Create or remove the CustomOID.'

      newvalue(:present) do
        provider.create
      end

      newvalue(:absent) do
        provider.destroy
      end

      defaultto :present
    end

    newparam(:host) do
      desc 'Database host'
      defaultto 'localhost'
      validate do |host|
        raise('Parameter host must be a string') unless host.is_a?(String)
      end
    end

    newparam(:port) do
      desc 'Database port'
      defaultto 3306
      validate do |port|
        raise('Parameter port must be an integer') unless port.is_a?(Integer)
      end
    end

    newparam(:username) do
      desc 'Database username'
      validate do |username|
        raise('Parameter username must be a string') unless username.is_a?(String)
      end
    end

    newparam(:password) do
      desc 'Database password'
      validate do |password|
        raise('Parameter password must be a string') unless password.is_a?(String)
      end
    end

    newparam(:database) do
      desc 'Database name'
      defaultto 'librenms'
      validate do |database|
        raise('Parameter database must be a string') unless database.is_a?(String)
      end
    end

    newparam(:name, namevar: true) do
      desc 'Name of this OID'
    end

    newparam(:hostname) do
      desc 'Hostname to bind this Custom OID to; must be unique in the devices table'
      validate do |hostname|
        raise('Parameter hostname must be a string') unless hostname.is_a?(String)
      end
    end

    newparam(:sysname) do
      desc 'sysName to bind this Custom OID to; must be unique in the devices table'
      validate do |sysname|
        raise('Parameter sysname must be a string') unless sysname.is_a?(String)
      end
    end

    newproperty(:descr) do
      desc 'A description of the OID'
      validate do |descr|
        raise('Property descr must be a string') unless descr.is_a?(String)
      end
    end

    newproperty(:oid) do
      desc 'SNMP OID'
      validate do |oid|
        raise('Property oid must be a string') unless oid.is_a?(String)
      end
    end

    newproperty(:datatype) do
      desc 'Data type for this Custom OID'
      defaultto 'gauge'
      validate do |datatype|
        raise('Property datatype must be gauge or counter') unless ['gauge','counter'].include?(datatype)
      end
      munge do |value|
        value.upcase
      end
    end

    newproperty(:unit) do
      desc 'Unit of value being polled'
      validate do |unit|
        raise('Property unit must be a string') unless unit.is_a?(String)
      end
    end

    newproperty(:divisor) do
      desc 'Divide raw SNMP value by'
      defaultto 1
      validate do |divisor|
        raise('Property divisor must be an integer') unless divisor.is_a?(Integer)
      end
    end

    newproperty(:multiplier) do
      desc 'Multiply raw SNMP value by'
      defaultto 1
      validate do |multiplier|
        raise('Property multiplier must be an integer') unless multiplier.is_a?(Integer)
      end
    end

    newproperty(:limit) do
      desc 'Level to alert above'
      defaultto 0
      validate do |limit|
        raise('Property limit must be an integer') unless limit.is_a?(Integer)
      end
    end

    newproperty(:limit_warn) do
      desc 'Level to warn above'
      defaultto 0
      validate do |limit_warn|
        raise('Property limit_warn must be an integer') unless limit_warn.is_a?(Integer)
      end
    end

    newproperty(:limit_low) do
      desc 'Level to alert below'
      defaultto 0
      validate do |limit_low|
        raise('Property limit_low must be an integer') unless limit_low.is_a?(Integer)
      end
    end

    newproperty(:limit_low_warn) do
      desc 'Level to warn below'
      defaultto 0
      validate do |limit_low_warn|
        raise('Property limit_low_warn must be an integer') unless limit_low_warn.is_a?(Integer)
      end
    end

    newproperty(:alert) do
      desc 'Alerts for this OID enabled'
      validate do |alert|
        raise('Property alert must be 0 or 1') unless [0,1].include?(alert)
      end
    end

    newproperty(:user_func) do
      desc 'User function to apply to value'
      validate do |user_func|
        raise('Property user_func must be a string') unless user_func.is_a?(String)
      end
    end

    validate do
      if ! (self[:hostname] || self[:sysname]) || (self[:hostname] && self[:sysname])
        raise "ERROR: must define either hostname or sysname!"
      end
    end
  end
end
