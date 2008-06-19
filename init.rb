require "iconv"
require "unicode"
ActiveRecord::Base.send!(:extend, Slug)