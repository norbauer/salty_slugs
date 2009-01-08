require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class Post < ActiveRecord::Base
  has_slug
end

class Product < ActiveRecord::Base
  has_slug :source_column => :name, :slug_column => :permalink, :prepend_id => false, :sync_slug => true
end

class Article < ActiveRecord::Base
  has_slug :slug_column => :permalink, :prepend_id => false, :sync_slug => true, :scope => :author
end

class PostPublicSluggify < ActiveRecord::Base
  has_slug
  class << self; public :sluggify; end
end

class SlugTest < Test::Unit::TestCase
  
  def setup
    @post = Post.create(:title => "Can has cheesburger?")
    @product = Product.create(:name => "Salt Shaker")
    @article = Article.create(:title => "Lock On Black Shark", :author => "Siddhaarth Verma", :body => "It's gonna be the Mecca for simulation fans!")
  end
  
  def teardown
    Post.delete_all
    Product.delete_all
  end

  def test_slugged_find
    assert Post.slugged_find("#{@post.id}-can-has-cheesburger")
    assert Product.slugged_find("salt-shaker")
  end
  
  def test_failing_slugged_find
    assert_raise(ActiveRecord::RecordNotFound) { Post.slugged_find("this is not an existing slug") }
  end

  def test_slug_column
    assert_equal "slug", Post.slug_column.to_s
    assert_equal "permalink", Product.slug_column.to_s
  end
  
  def test_source_column
    assert_equal PostPublicSluggify.sluggify(@post.title), @post.slug
    assert_equal PostPublicSluggify.sluggify(@product.name), @product.permalink
  end
  
  def test_uniqueness_of_slug
    assert_nothing_raised { Post.create!(:title => "can has CHEESBURGER??") }
    assert_raise(ActiveRecord::RecordInvalid) { Product.create!(:name => "!!!~~Salt SHAKER~~~!!!!") }
  end
  
  def test_uniqueness_of_slug_with_scope
    assert_nothing_raised { Article.create!(:title => "Left 4 Dead", :author => "Siddhaarth Verma", :body => "Valve has done it again! This is a zombie fragging masterpiece.") }
    assert_nothing_raised { Article.create!(:title => "Left 4 Dead", :author => "Sid", :body => "The co-op multiplayer game of the year!") }
    assert_raise(ActiveRecord::RecordInvalid) { Article.create!(:title => "Lock On Black Shark", :author => "Siddhaarth Verma", :body => "The most authentic gunship simuator ever.") }
  end
  
  def test_sync_slug
    @post.title, @product.name = 'foo', 'bar'
    @post.save
    assert @post.title != @post.slug
    @post.slug = 'quack'
    @post.save
    assert @post.title != @post.slug
    @product.save
    assert @product.name == @product.permalink
  end
  
  def test_to_param
    assert_equal @post.to_param, "#{@post.id}-#{@post[Post.slug_column]}"
    assert_equal @product.to_param, "#{@product[Product.slug_column]}"
    post_with_blank_slug = Post.create
    assert_equal post_with_blank_slug.to_param, post_with_blank_slug.id.to_s
  end
  
  def test_sluggify
    slugs = {
      "This is just a title" => "this-is-just-a-title",
      "//\\?!(*)hai you! su!!c%%%%%k" => "hai-you-su-c-k",
      # Use the correct expected string with Unicode support
      "ñæüéå" => defined?(Unicode) ? "nuea" : "nae-u-ea",
      # Stolen from Ricks tests, as always.
      'This IS a Tripped out title!!.!1  (well/ not really)' => 'this-is-a-tripped-out-title-1-well-not-really',
      '////// meph1sto r0x ! \\\\\\' => 'meph1sto-r0x',
      'āčēģīķļņū' => 'acegiklnu'
    }
    
    slugs.each { |title, slug| assert_equal slug, PostPublicSluggify.sluggify(title) }
  end
end
