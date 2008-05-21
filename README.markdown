## SaltySlugs

 Abstraction of word-based slugs for URLs, w/ or w/o leading numeric IDs.

## Instructions

* Defaults to 'title' as the source column and 'slug' as the slug column.  Prepends the model ID

<pre> 
class Post < ActiveRecord::Base
   has_slug
end
 
post = Post.create(:title => "Do Not Mix Slugs and Salt!")
@post.to_param
=> '23-do-not-mix-slugs-and-salt'
</pre>

* You can also overwrite the defaults

<pre>
class Product < ActiveRecord::Base
   has_slug :source_column => :name, :slug_column => :permalink, :prepend_id => false
end
 
@product = Product.create(:name => "Salt and Pepper Shaker")
@product.to_param
=> 'salt-and-pepper-shaker'
</pre>
 
* Use the slugged_find class method in your controllers, smart enough to modify the search conditions if prepending ID is found or not.

<pre>
class PostsController < ApplicationController

   def show
      @post = Post.slugged_find(params[:id])
   end
   
end
</pre>

---
Copyright (c) 2008 Norbauer Inc, released under the MIT license
Written by Jonathan Dance and Jose Fernandez
