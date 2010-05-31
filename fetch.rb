require 'example'
require 'benchmark'
require 'faker'

BATCH_SIZE = 25

authors = Author.limit(BATCH_SIZE).all

authors.each do |author|
  CACHE.delete(['author', author.id, 'posts'].join(':'))
end

puts 'Fetch cold'
puts Benchmark.measure {
  authors.each do |author|
    author.post_count
    author.private_post_count
    
    histogram = 10.times.inject({}) do |hsh, _|
      hsh.update(Faker::Lorem.words(1) => rand(100))
    end
    author.histogram(histogram)
    
    author.cloud(Faker::Lorem.words(10))
  end
}

puts 'Fetch warm, 1 entry'
puts Benchmark.measure {
  authors.each do |author|
    author.post_count
  end
}

puts 'Fetch warm, 2 entries'
puts Benchmark.measure {
  authors.each do |author|
    author.post_count
    author.private_post_count
  end
}

puts 'Fetch warm, 3 entries'
puts Benchmark.measure {
  authors.each do |author|
    author.post_count
    author.private_post_count
    author.histogram
  end
}

puts 'Fetch warm, 8 entries'
puts Benchmark.measure {
  authors.each do |author|
    author.post_count
    author.private_post_count
    author.histogram
    author.cloud
    
    author.post_count
    author.private_post_count
    author.histogram
    author.cloud
  end
}

puts 'Fetch warm, 12 entries'
puts Benchmark.measure {
  authors.each do |author|
    author.post_count
    author.private_post_count
    author.histogram
    author.cloud
    
    author.post_count
    author.private_post_count
    author.histogram
    author.cloud
    
    author.post_count
    author.private_post_count
    author.histogram
    author.cloud
  end
}
