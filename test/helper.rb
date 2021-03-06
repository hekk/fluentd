# simplecov must be loaded before any of target code
if ENV['SIMPLE_COV']
  require 'simplecov'
  if defined?(SimpleCov::SourceFile)
    mod = SimpleCov::SourceFile
    def mod.new(*args, &block)
      m = allocate
      m.instance_eval do
        begin
          initialize(*args, &block)
        rescue Encoding::UndefinedConversionError
          @src = "".force_encoding('UTF-8')
        end
      end
      m
    end
  end
  unless SimpleCov.running
    SimpleCov.start do
      add_filter '/test/'
      add_filter '/gems/'
    end
  end
end

# Some tests use Hash instead of Element for configure.
# We should rewrite these tests in the future and remove this ad-hoc code
class Hash
  def corresponding_proxies
    @corresponding_proxies ||= []
  end

  def to_masked_element
    self
  end
end

require 'rr'
require 'test/unit'
require 'test/unit/rr'
require 'fileutils'
require 'fluent/config/element'
require 'fluent/log'
require 'fluent/test'
require 'fluent/plugin/base'
require 'fluent/log'
require 'fluent/plugin_id'
require 'fluent/plugin_helper'
require 'fluent/time'

module Fluent
  module Plugin
    class TestBase < Base
      # a base plugin class, but not input nor output
      # mainly for helpers and owned plugins
      include PluginId
      include PluginLoggerMixin
      include PluginHelper::Mixin
    end
  end
end

unless defined?(Test::Unit::AssertionFailedError)
  class Test::Unit::AssertionFailedError < StandardError
  end
end

def config_element(name = 'test', argument = '', params = {}, elements = [])
  Fluent::Config::Element.new(name, argument, params, elements)
end

def event_time(str=nil)
  if str
    Fluent::EventTime.parse(str)
  else
    Fluent::EventTime.now
  end
end

def unused_port(num = 1)
  ports = []
  sockets = []
  num.times do
    s = TCPServer.open(0)
    sockets << s
    ports << s.addr[1]
  end
  sockets.each{|s| s.close }
  if num == 1
    return ports.first
  else
    return *ports
  end
end

def ipv6_enabled?
  require 'socket'

  begin
    TCPServer.open("::1", 0)
    true
  rescue
    false
  end
end

$log = Fluent::Log.new(Fluent::Test::DummyLogDevice.new, Fluent::Log::LEVEL_WARN)
