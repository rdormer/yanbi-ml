# YANBI-ML

Yet Another Naive Bayes Implementation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yanbi-ml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yanbi-ml

## Usage

A Naive Bayesian classifier based on the bag-of-words model so very popular in text classification literature.  Although primarily built around these bags, an interface to just train and classify raw text is also included.  This gem is written with an eye towards training and classifying large sets of documents as painlessly as possible.  I originally wrote this for an unpublished project of mine, and decided the interface might be useful for other people :)

## I want to keep it simple!

Okay, do this:

```ruby
classifier = Yanbi::Bayes.default(:even, :odd)
classifier.train_raw(:even, "two four six eight")
classifier.train_raw(:odd, "one three five seven")

classifier.classify_raw("one two three") => :odd
```

## Bags (of words)

A bag of words is a just a Hash of word counts (a multi-set of word frequencies, to ML folk).  This makes a useful abstraction because you can use it with more than one kind of classifier, and because the bag provides a natural location for various kinds of pre-processing you might want to do to the words (features) of the text before training with or classifying them.  

A handful of classes are provided:

<ul>
<li>WordBag - basic, default bag of words</li>
<li>StemmedWordBag - bag of words with lemmatization (stemming)</li>
<li>DiadBag - use with overlapping pairs of words</li>
<li>StemmedDiadBag - overlapping pairs of stemmed words</li>
</ul>

All of these classes will do the same basic standardization of text - lowercasing, punctuation and whitespace stripping, and so on.  Using one or the other of these will give you some flexibility with how you process and classify text:

```ruby
#I want to use stemmed words!
classifier = Yanbi::Bayes.new(Yanbi::StemmedWordBag, :even, :odd)
classifier.train_raw(:even, "two four six eight")
classifier.train_raw(:odd, "one three five seven")
classifier.classify_raw("one two three") => :odd
```

Or, if you want to deal with bags directly:

```ruby
classifier = Yanbi::Bayes.new(Yanbi::StemmedWordBag, :even, :odd)
classifier.train(:even, classifier.newdoc('two four six eight'))
classifier.train(:odd, classifier.newdoc('one three five seven'))
classifier.classify(classifier.newdoc('one two three')) => :odd
```

The newdoc method will create the type of bag associated with that classifier.  Although it's not strictly necessary to keep the type of word bag you use with a classifier consistent, it's recommended unless you have a good reason not to.  Using the newdoc method will help a great deal with that.  

Of course, you can also create word bags directly:

```ruby
bag = Yanbi::WordBag.new('this is a test, of the emergency broadcast system')
```

and query them:
```ruby
bag = Yanbi::WordBag.new('one two three')
bag.words => ["one", "two", "three"]
bag.word_counts => {"one"=>1, "two"=>1, "three"=>1}

bag = Yanbi::DiadBag.new('one two three four')
["one two", "two three", "three four"]
bag.word_counts => {"one two"=>1, "two three"=>1, "three four"=>1}

bag = Yanbi::StemmedWordBag.new
bag.empty? => true
```

You can also add text after the fact:
```ruby
bag = Yanbi::WordBag.new('one two three')
bag.add_text('four five six seven')
bag.words => ["one", "two", "three", "four", "five", "six", "seven"]
```

And remove words:
```ruby
bag = Yanbi::WordBag.new('one two three four five six seven')
bag.remove(%w(one three five))
bag.words => ["two", "four", "six", "seven"]
```

And see where bags of words overlap:
```ruby
first = Yanbi::WordBag.new('one two three four')
second = Yanbi::WordBag.new('three four five six')
first.intersection(second) => ["three", "four"]
```

## Corpora

A Corpus is a set of related documents, and naturally, a Corpus class is provided to process text and documents into a collection of word bags.  It can accept text directly, or from a file, and can optionally accept multiple documents concatenated together (this makes dealing with large numbers of documents a *lot* easier) and a RegEx specifying a comment pattern (for metadata or feature shaping).  The comment can either enclose (/*like this*/) or be a line comment (//like these), depending on which regex you choose.

A corpus is created with an associated word bag type.  By default, this is the basic WordBag.

```ruby
#Just make a basic corpus, no muss, no fuss
docs = Yanbi::Corpus.new

#I want to stem!
docs = Yanbi::Corpus.new(Yanbi::StemmedWordBag)
```

Once that's done, it's on to creating the actual corpus:
```ruby

#just load a file as a single document
docs.add_file('biglistofstuff.txt')

#to make things easier, I pasted a ton of documents into a
#text file and separated them with a **** delimiter
docs.add_file('biglistofstuff.txt', '****')

#to make things easier, I pasted a ton of documents into a
#text file and separated them with a **** delimiter, and 
#commented out noise like so: %%noise noise noise%%
docs.add_file('biglistofstuff.txt', '****', /\%\%.+\%\%/)
```

Of course you're not limited to files:

```ruby
array_of_strings.each do |current|
  docs.add_doc(current)
end

#wait, these have comments!
array_of_commented_strings.each do |current|
  docs.add_doc(current, /\%\%.+\%\%/)
end

```

Once you've started adding documents, they're available for iteration as word bags of the type you specified when you created the corpus:

```ruby
STOP_WORDS = %w(the a at in and of)

docs.each_doc do |d|
  d.remove(STOP_WORDS)
end
```

## Putting it all together

```ruby
classifier = Yanbi.default(:stuff, :otherstuff)

stuff = Yanbi::Corpus.new
stuff.add_file('biglistofstuff.txt', '****')

other = Yanbi::Corpus.new
other.add_file('biglistofotherstuff.txt', '@@@@')

stuff.each_doc {|d| classifier.train(:stuff, d)}
otherstuff.each_doc {|d| classifier.train(:otherstuff, d)}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rdormer/yanbi-ml.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
