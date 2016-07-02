# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

# A word bag that stores the words as diads instead of individual words.
# i.e. "the quick brown fox" becomes "the quick", "quick brown", "brown fox".
# This type of shingling is often recommended as a way to boost the accuracy
# of Bayes classifiers

$: << File.dirname(__FILE__)
require 'wordbag'

module Yanbi

  class DiadBag < WordBag
    def process(raw)
      processed = raw.downcase
      processed.gsub!(/[^\w\s'\-]/, ' ')
      words = processed.split
      words = words.map {|x| x.split /-/}.flatten
  
      if block_given?
        words.map! {|x| yield x}
      end
  
      diads = []
      words.each_with_index {|w, i| diads << [w, words[i+1]]}
      diads.delete_at(-1)
      
      words = diads.map {|x| "#{x.first} #{x.last}"}
      update_counts(words)
      @words.concat(words)
    end
  end

end
