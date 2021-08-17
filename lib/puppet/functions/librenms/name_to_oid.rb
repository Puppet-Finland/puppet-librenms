# frozen_string_literal: false

# Convert string to a numeric OID based on the ASCII values of the individual
# characters.  While the process is general purpose, it is only used by
#
# https://github.com/Puppet-Finland/net-snmp-systemd-service-status
#
# as far as we know.
#
Puppet::Functions.create_function('librenms::name_to_oid') do
  dispatch :get do
    required_param 'String', :name
    required_param 'String', :base_oid
    return_type 'String'
  end

  def get(name, base_oid)
    oid = base_oid.dup
    name.chars.each do |c|
      oid << '.'
      oid << c.ord.to_s
    end
    oid
  end
end
