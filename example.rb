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
  
  # Sugar this
  attr_accessor :post_count, :private_post_count, :histogram, :cloud
  
  # Sugar this
  def self.get(id, includes={})
    record = CACHE.fetch(['author', id].join(':')) do
      find(id)
    end
    
    if includes.has_key?(:include)
      mappings = includes[:include].inject({}) do |hsh, attr|
        hsh.update(record.send("#{attr}_key") => attr)
      end
      CACHE.read_multi(mappings.keys).each do |key, value|
        record.send("#{mappings[key]}=", value)
      end
    end
    
    record
  end
  
  def post_count_key
    ['author', self.id, 'posts'].join(':')
  end
  
  def private_post_count_key
    ['author', self.id, 'private'].join(':')
  end
  
  def histogram_key
    ['author', self.id, 'histogram'].join(':')
  end
  
  def cloud_key
    ['author', self.id, 'cloud'].join(':')
  end
  
  # Sugar this?
  def post_count
    @post_count ||= CACHE.fetch(post_count_key) do
      posts.count
    end
  end
  
  def private_post_count
    @private_post_count ||= CACHE.fetch(private_post_count_key) do
      posts.where(:private => true).count
    end
  end
  
  def histogram(histogram=nil)
    @histogram ||= CACHE.fetch(histogram_key) do
      histogram
    end
  end
  
  def cloud(cloud=nil)
    @cloud ||= CACHE.fetch(cloud_key) do
      cloud
    end
  end
  
end
