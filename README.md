# HasCache

This is a proof-of-concept.

HasCache wraps up a few memcached-related pattern and then puts some tasty sugar on top:

- Decouple memcached keys from the methods that know how to populate them
- Memoizing the result of fetching keys from memcached into a model instance
- Eager loading of associations

The crux of the biscuit is that you can fetch an object from memcached _plus_ all its related data. Suppose you've got a `Post` model and you're storing post counts per-author in memcached. Instead of loading that data like so:

    author = Author.get(14)
    post_count = author.post_count
    
You can fetch it like so, and use one memcached call instead of two:

    author = Author.get(14, :include => [:post_count])
    
If you're fetching enough ancillary data, wrapping everything into one read might help the amount of time you spend dealing with memcached.

Check out example.rb to see how this looks in your domain model. `get.rb` shows how to use eager includes. 

## Plot twist!

In fact, it seems one big read instead of multiple reads is slower. I'm either missing something or writing horribly slow code. Going to look into that sometime soon.

---
<pre>
~akk
May 31, 2010
</pre>