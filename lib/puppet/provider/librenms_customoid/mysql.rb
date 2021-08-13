# frozen_string_literal: true

Puppet::Type.type(:librenms_customoid).provide(:mysql) do
  require 'sequel'

  def exists?
    @DB = Sequel.connect("mysql2://#{resource[:username]}:#{resource[:password]}@#{resource[:host]}:#{resource[:port]}/#{resource[:database]}")
    @customoids = @DB.from(:customoids)
    @DB.sql_log_level = :debug

    # Hash that contains this Custom OID's real state as opposed to desired state
    @my_properties = {}

    entries = @customoids.where(device_id: resource[:device_id], customoid_oid: resource[:oid]).entries
    case entries.size
    when 1
      @my_properties = entries[0]
      true
    when 0
      false
    else
      raise "ERROR: found more than one matching customoid entry! We should never end up in here, exiting..."
    end
  end

  def create
    begin
      @customoids.insert(device_id: resource[:device_id],
                         customoid_descr: resource[:descr],
                         customoid_oid: resource[:oid],
                         customoid_datatype: resource[:datatype],
                         customoid_unit: resource[:unit],
                         customoid_divisor: resource[:divisor],
                         customoid_multiplier: resource[:multiplier],
                         customoid_limit: resource[:limit],
                         customoid_limit_warn: resource[:limit_warn],
                         customoid_limit_low: resource[:limit_low],
                         customoid_limit_low_warn: resource[:limit_low_warn],
                         customoid_alert: resource[:alert],
                         # Set 1 here to force LibreNMS to believe that snmpget
                         # for the OID returns a value. If this is not done
                         # LibreNMS will not start polling this Custom OID and
                         # hence will not alert.
                         customoid_passed: 1,
                         user_func: resource[:user_func])
    rescue Sequel::DatabaseError => e
      puts e.message
    end

  end

  def destroy
    @customoids.where(device_id: resource[:device_id], customoid_oid: resource[:oid]).delete
  end

  def update_field(field, value)
    value = 'NULL' if value.nil?
    change = { field => value }
    @customoids.where(device_id: resource[:device_id], customoid_oid: resource[:oid]).update(change)
  end

  def descr
    @my_properties[:customoid_descr]
  end

  def descr=(value)
    update_field(:customoid_descr, resource[:descr])
  end

  def oid
    @my_properties[:customoid_oid]
  end

  def oid=(value)
    update_field(:customoid_oid, resource[:oid])
  end

  def datatype
    @my_properties[:customoid_datatype]
  end

  def datatype=(value)
    update_field(:customoid_datatype, resource[:datatype])
  end

  def unit
    @my_properties[:customoid_unit]
  end

  def unit=(value)
    update_field(:customoid_unit, resource[:unit])
  end

  def divisor
    @my_properties[:customoid_divisor]
  end

  def divisor=(value)
    update_field(:customoid_divisor, resource[:divisor])
  end

  def multiplier
    @my_properties[:customoid_multiplier]
  end

  def multiplier=(value)
    update_field(:customoid_multiplier, resource[:multiplier])
  end

  def limit
    @my_properties[:customoid_limit]
  end

  def limit=(value)
    update_field(:customoid_limit, resource[:limit])
  end

  def limit_warn
    @my_properties[:customoid_limit_warn]
  end

  def limit_warn=(value)
    update_field(:customoid_limit_warn, resource[:limit_warn])
  end

  def limit_low
    @my_properties[:customoid_limit_low]
  end

  def limit_low=(value)
    update_field(:customoid_limit_low, resource[:limit_low])
  end

  def limit_low_warn
    @my_properties[:customoid_limit_low_warn]
  end

  def limit_low_warn=(value)
    update_field(:customoid_limit_low_warn, resource[:limit_low_warn])
  end

  def alert
    @my_properties[:customoid_alert]
  end

  def alert=(value)
    update_field(:customoid_alert, resource[:alert])
  end

  def user_func
    @my_properties[:user_func]
  end

  def user_func=(value)
    update_field(:customoid_user_func, resource[:user_func])
  end
end
