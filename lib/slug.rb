module Slug
  
  def has_slug(options = {})      
    
    unless included_modules.include? InstanceMethods 
      extend ClassMethods
      include InstanceMethods
    end
    
    slug_column = options[:slug_column] || 'slug'
    source_column = options[:source_column] || 'title'
    prepend_id = options[:prepend_id] == false ? false : true
    
    write_inheritable_attribute :slug_column, slug_column  
    write_inheritable_attribute :slug_prepend_id, prepend_id  

    class_inheritable_reader :slug_column
    class_inheritable_reader :slug_prepend_id
    
    before_validation { |record| record[slug_column] = record[slug_column].blank? ? sluggify(record[source_column]) : sluggify(record[slug_column]) }
    validates_uniqueness_of slug_column
    
  end
  
  module ClassMethods
    
    def slugged_find(slug, options = {})
      if slug_prepend_id && slug.to_i != 0
        find(slug.to_i, options)
      else
        with_scope(:find => { :conditions => { slug_column => slug } }) do
          find(:first, options)
        end or raise ::ActiveRecord::RecordNotFound
      end
    end
    
    private 
    
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
      slug_prepend_id ? "#{self.id}-#{self[slug_column]}" : self[slug_column]
    end
    
  end
  
end