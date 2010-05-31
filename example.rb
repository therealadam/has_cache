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

CACHE = ActiveSupport::Cache::MemCacheStore.new('localhost')

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
  
  def post_count
    @post_count ||= CACHE.fetch(['author', self.id, 'posts'].join(':')) do
      posts.count
    end
  end
  
  def private_post_count
    @private_post_count ||= CACHE.fetch(['author', self.id, 'private'].join(':')) do
      posts.where(:private => true).count
    end
  end
  
  def histogram(histogram=nil)
    @histogram ||= CACHE.fetch(['author', self.id, 'histogram'].join(':')) do
      histogram
    end
  end
  
  def cloud(cloud=nil)
    @cloud ||= CACHE.fetch(['author', self.id, 'cloud'].join(':')) do
      cloud
    end
  end
  
end
