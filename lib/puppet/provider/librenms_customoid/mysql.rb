# frozen_string_literal: true

Puppet::Type.type(:librenms_customoid).provide(:mysql) do
  require 'sequel'

  def exists?
    true
  end

  def create
    true
  end

  def destroy
    true
  end

  def descr
    'foobar'
  end

  def descr=(value)
    'foobar'
  end

  def oid
    'foobar'
  end

  def oid=(value)
    'foobar'
  end

  def datatype
    'foobar'
  end

  def datatype=(value)
    'foobar'
  end

  def unit
    'foobar'
  end

  def unit=(value)
    'foobar'
  end

  def divisor
    'foobar'
  end

  def divisor=(value)
    'foobar'
  end

  def multiplier
    'foobar'
  end

  def multiplier=(value)
    'foobar'
  end

  def limit
    'foobar'
  end

  def limit=(value)
    'foobar'
  end

  def limit_warn
    'foobar'
  end

  def limit_warn=(value)
    'foobar'
  end

  def limit_low
    'foobar'
  end

  def limit_low=(value)
    'foobar'
  end

  def limit_low_warn
    'foobar'
  end

  def limit_low_warn=(value)
    'foobar'
  end

  def alert
    'foobar'
  end

  def alert=(value)
    'foobar'
  end

  def user_func
    'foobar'
  end

  def user_func=(value)
    'foobar'
  end
end