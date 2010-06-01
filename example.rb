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

module HasCache
  extend ActiveSupport::Concern
  
  included do
    
    cattr_accessor :cache_lookups, :cache_keys do
      {}
    end
    
    def self.has_cache(name, options, &block)
      cache_lookups[name] = block
      cache_keys[name] = options[:key]
      
      class_eval %Q{
        def #{name}(*args)
          return @#{name} if @#{name}.present?
          key = method(cache_keys[:#{name}]).call
          @#{name} = CACHE.fetch(key) do
            lookup = cache_lookups[:#{name}]
            if lookup.arity > 1 && args.length > 0
              lookup.call(self, *args)
            else
              lookup.call(self)
            end
          end
        end
      }
    end
    
    def self.get(id, includes={})
      record = CACHE.fetch(['author', id].join(':')) do
        find(id)
      end
      
      if includes.has_key?(:include)
        mappings = includes[:include].inject({}) do |hsh, attr|
          hsh.update(record.send("#{attr}_key") => attr)
        end
        CACHE.read_multi(mappings.keys).each do |key, value|
          record.instance_variable_set("@#{mappings[key]}", value)
        end
      end
      
      record
    end
    
  end
  
end

class Post < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  include HasCache
  
  has_many :posts
  
  # AKK: sugar this up, get the block to evaluate with the object instance
  has_cache :post_count, :key => :post_count_key do |author|
    author.posts.count
  end
  
  has_cache :private_post_count, :key => :private_post_count_key do |author|
    author.posts.where(:private => true).count
  end
  
  has_cache :histogram, :key => :histogram_key do |_, histogram|
    histogram
  end
  
  has_cache :cloud, :key => :cloud_key do |_, cloud|
    cloud
  end
  
  # Sugar this
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
  
end
