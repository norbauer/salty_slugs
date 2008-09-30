module Slug
  def has_slug(*args)
    unless included_modules.include? InstanceMethods 
      extend ClassMethods
      include InstanceMethods
    end
    
    options = args.extract_options!
    slug_column = options[:slug_column] || 'slug'
    source_column = options[:source_column] || 'title'
    prepend_id = options[:prepend_id].nil? ? true : options[:prepend_id]
    sync_slug = options[:sync_slug].nil? ? false : options[:sync_slug]
    scope_column = options[:scope] if options[:scope]
    
    write_inheritable_attribute :slug_column, slug_column  
    write_inheritable_attribute :slug_prepend_id, prepend_id  

    class_inheritable_reader :slug_column
    class_inheritable_reader :slug_prepend_id
    
    validates_uniqueness_of slug_column, :scope => scope_column, :unless => :slug_prepend_id
    
    before_validation { |record| record[slug_column] = (sync_slug || record[slug_column].blank?) ? sluggify(record.send(source_column)) : sluggify(record[slug_column]) }  
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
      return nil if text.blank?
      if defined?(Unicode)
        str = Unicode.normalize_KD(text).gsub(/[^\x00-\x7F]/n,'')
        str = str.gsub(/\W+/, '-').gsub(/^-+/,'').gsub(/-+$/,'').downcase
        return str
      else
        str = Iconv.iconv('ascii//translit', 'utf-8', text).to_s
        str.gsub!(/\W+/, ' ')
        str.strip!
        str.downcase!
        str.gsub!(/\ +/, '-')
        return str
      end
    end
  end
  
  module InstanceMethods
    def to_param
      return self.id if slug_prepend_id && self[slug_column].blank?
      slug_prepend_id ? "#{self.id}-#{self[slug_column]}" : self[slug_column]
    end
  end 
end
