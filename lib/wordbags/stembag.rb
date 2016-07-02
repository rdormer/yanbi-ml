# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

# This is a word bag with a post-processing step to stem (lemmatize)
# the words in the bag

$: << File.dirname(__FILE__)
require 'fast_stemmer'
require 'wordbag'

module Yanbi

  class StemmedWordBag < WordBag
    def standardize(raw)
      process(raw) {|word| word.stem}
    end
  end

end
