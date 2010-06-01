require 'example'
require 'benchmark'
require 'logger'

BATCH_SIZE = 25

# ActiveSupport::Cache::Store.logger = Logger.new(STDOUT)
# ActiveSupport::Cache::Store.instrument = true

author_ids = Author.connection.select_values("SELECT id FROM authors LIMIT #{BATCH_SIZE}")

authors = []
puts Benchmark.measure { 
  authors = author_ids.map { |id| Author.get(id) } 
  authors.each do |author|
    author.post_count
    author.private_post_count
    author.histogram
    author.cloud
  end
}

# puts Benchmark.measure {
#   author_ids.map { |id| Author.get(id, :include => [:post_count, :private_post_count, :histogram, :cloud]) }
# }