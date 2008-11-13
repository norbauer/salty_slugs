$:.unshift(File.dirname(__FILE__) + '/../lib')
RAILS_ROOT = File.dirname(__FILE__)

require 'rubygems'
require 'test/unit'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

require "salty_slugs"
require "#{File.dirname(__FILE__)}/../init"
load(File.dirname(__FILE__) + "/schema.rb")