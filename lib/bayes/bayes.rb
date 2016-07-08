# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

# Naive Bayesian classifier.  Training and classification are both done via passed in
# word bags, as opposed to raw text.  The first argument to new is the class of WordBag
# that you want newdoc to create.  From then on, you can use newdoc to process text instead
# of manually creating word bags yourself, which will help to keep the word bag type
# consistent for a given classifier object.  Note that if you really want to, you can train
# or classify with a different type of word bag then you passed in, although I can't imagine
# why you would want to.  There's also a default constructor if you just want to create a 
# classifier without being bothered about which word bag it uses.

module Yanbi

  class Bayes
  
    def initialize(klass, *categories)
      raise ArgumentError unless categories.size > 1
      @categories = categories
      @category_counts = {}
      @document_counts = {}
      @category_sizes = {}
  
      @categories.each do |category|
        cat = category.to_sym
        @category_counts[cat] = {}
        @document_counts[cat] = 0 
      end

      @bag_class = klass.to_s.split('::').last
    end

    def self.default(*categories)
      self.new(WordBag, *categories)
    end

    def self.load(fname)
      c = YAML::load(File.read(fname + ".obj"))
      raise LoadError unless c.is_a? self 
      c
    end

    def save(name)
      File.open(name + ".obj", 'w') do |out|
         YAML.dump(self, out)
      end
    end
 
    def train(category, document)
      cat = category.to_sym
      @document_counts[cat] += 1    
  
      document.words.uniq.each do |word|
        @category_counts[cat][word] ||= 0
        @category_counts[cat][word] += 1
      end

      @category_sizes[cat] = category_size(cat)
    end
  
    def classify(document)
      max_score(document) do |cat, doc|
        score(cat, doc)
      end
    end

    def train_raw(category, text)
      train(category, self.newdoc(text))
    end

    def classify_raw(text)
      classify(self.newdoc(text))
    end
  
    def set_significance(cutoff, category=nil)
      categories = (category.nil? ? @categories : [category])
      categories.each do |category|
        cat = category.to_sym
        @category_counts[cat].reject! {|k,v| v < cutoff}
        @category_sizes[cat] = category_size(cat)
      end
    end
  
    def newdoc(doc)
      Yanbi.const_get(@bag_class).new(doc)
    end
 
    private
  
    def score(cat, document)
      total_docs = @document_counts.values.reduce(:+).to_f
      document_prob = document.words.uniq.map {|word| word_prob(cat, word)}.reduce(:+)     
      document_prob + Math.log(@document_counts[cat] / total_docs) 
    end
  
    def word_prob(cat, word)
      count = @category_counts[cat].has_key?(word) ? @category_counts[cat][word].to_f : 0.1 
      Math.log(count / @category_sizes[cat])
    end
  
    def max_score(document)
      scores = [] 
  
      @categories.each do |c|
        score = yield c, document
        scores << score
      end

      i = scores.rindex(scores.max)
      @categories[i]
    end

    def category_size(cat)
      @category_counts[cat].values.reduce(&:+).to_i
    end
  end

end
