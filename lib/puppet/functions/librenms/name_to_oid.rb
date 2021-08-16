# frozen_string_literal: false

# Convert string to a numeric OID based on the ASCII values of the individual
# characters.  While the process is general purpose, it is only used by
#
# https://github.com/Puppet-Finland/net-snmp-systemd-service-status
#
# as far as we know.
#
Puppet::Functions.create_function('librenms::name_to_oid') do dispatch :get do
  param 'String', :name return_type 'String' end

  def get(name)
    oid = String.new
    name.chars.each do |c|
      oid << c.ord.to_s
      oid << '.'
    end
    oid.delete_suffix!('.')
  end
end
