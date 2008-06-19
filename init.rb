begin
  require "unicode"
rescue LoadError
  require "iconv"
end
ActiveRecord::Base.send!(:extend, Slug)