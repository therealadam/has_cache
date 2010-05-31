require 'rubygems'
require 'bundler'

Bundler.setup
require 'active_record'

config = {
  :adapter => 'postgresql',
  :host => 'localhost',
  :user => 'root',
  :password => '',
  :database => 'cms'
}

ActiveRecord::Base.establish_connection(config)

ActiveRecord::Schema.define do
  
  create_table :authors do |t|
    t.string :name, :null => false
  end
  
  add_index :authors, :name, :unique
  
  create_table :posts do |t|
    t.integer :author_id, :null => false
    t.string :subject
    t.text :body
    t.boolean :private, :default => false
  end
  
  add_index :posts, :author_id
  
end unless ActiveRecord::Base.connection.table_exists?('posts')

class Post < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  has_many :posts
end
