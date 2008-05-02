module Slug
  def has_slug(column = :title)      
    extend ClassMethods
    include InstanceMethods
    
    before_validation { |record| record[slug_column] = record[slug_column].blank? ? sluggify(record[column]) : sluggify(record[slug_column]) }
    validates_uniqueness_of self.class_eval { slug_column }
  end
  
  module ClassMethods
    def slugged_find(slug)
      self.send("find_by_#{slug_column}", slug) || raise(::ActiveRecord::RecordNotFound)
    end
    
    private 
    
    def slug_column
      "slug"
    end
    
    def sluggify(text)
      # hugs and kisses to Rick Olson's permalink_fu
      s = Iconv.iconv('ascii//translit', 'utf-8', text).to_s
      s.gsub!(/\W+/, ' ')
      s.strip!
      s.downcase!
      s.gsub!(/\ +/, '-')
      return s
    end
  end
  
  module InstanceMethods
    def to_param
      self[self.class.class_eval { slug_column }]
    end
  end
end