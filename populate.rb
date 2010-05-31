require 'example'
require 'benchmark'
require 'faker'

AUTHORS = 100
POSTS = 100_000

authors = nil
if Author.count < AUTHORS
  puts "Creating #{AUTHORS} authors"
  puts Benchmark.measure {
    authors = AUTHORS.times.map { Author.create(:name => Faker::Name.name).id }
  }
end

if Post.count < POSTS
  puts "Creating #{POSTS} posts"
  puts Benchmark.measure {
    POSTS.times { Post.create(:subject => Faker::Lorem.sentence, 
                              :body => Faker::Lorem.paragraph, 
                              :private => (rand(9) > 8),
                              :author_id => authors[rand(authors.length - 1)]) }
  }
end

# First time run:
# Creating 100 authors
#   0.250000   0.010000   0.260000 (  0.444360)
# Creating 100000 posts
# 345.970000  10.910000 356.880000 (528.442678)