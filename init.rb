begin
  require "unicode"
rescue LoadError
  require "iconv"
end
ActiveRecord::Base.send(:include, Norbauer::SaltySlugs)