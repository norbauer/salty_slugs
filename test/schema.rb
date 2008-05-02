ActiveRecord::Schema.define(:version => 1) do

  create_table :posts do |t|
    t.column :title, :string
    t.column :slug, :string
  end
end