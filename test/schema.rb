ActiveRecord::Schema.define(:version => 1) do

  create_table :posts do |t|
    t.column :title, :string
    t.column :slug, :string
  end

  create_table :products do |t|
    t.column :name, :string
    t.column :permalink, :string
  end

  create_table :articles do |t|
    t.column :title, :string
    t.column :body, :text
    t.column :author, :string
    t.column :permalink, :string
  end
end