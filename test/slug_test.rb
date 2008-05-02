require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class Post < ActiveRecord::Base
  has_slug
end

class PostPublicSluggify < ActiveRecord::Base
  has_slug
  class << self; public :sluggify; end
end

class SlugTest < Test::Unit::TestCase
  def setup
    @post = Post.create(:title => "Can has cheesburger?")
  end

  def test_slugged_find
    assert Post.slugged_find("can-has-cheesburger")
  end
  
  def test_failing_slugged_find
    assert_raise(ActiveRecord::RecordNotFound) { Post.slugged_find("this is not an existing slug") }
  end

  def test_slug_column
    assert_equal "slug", Post.class_eval { slug_column }
  end
  
  def test_uniqueness_of_slug
    assert_raise(ActiveRecord::RecordInvalid) { Post.create!(:title => "can has CHEESBURGER??") }
  end
  
  def test_to_param
    assert_equal @post.to_param, "#{@post.id}-#{@post[Post.slug_column]}"
  end
  
  def test_sluggify
    slugs = {
      "This is just a title" => "this-is-just-a-title",
      "//\\?!(*)hai you! su!!c%%%%%k" => "hai-you-su-c-k",
      "ñæüéå" => "nae-u-ea",
      # Stolen from Ricks tests, as always.
      'This IS a Tripped out title!!.!1  (well/ not really)' => 'this-is-a-tripped-out-title-1-well-not-really',
      '////// meph1sto r0x ! \\\\\\' => 'meph1sto-r0x',
      'āčēģīķļņū' => 'acegiklnu'
    }
    
    slugs.each { |title, slug| assert_equal slug, PostPublicSluggify.sluggify(title) }
  end
end
