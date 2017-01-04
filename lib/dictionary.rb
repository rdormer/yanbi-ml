# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

# Class for storing word dictionaries created from wordbags
# and corpuses.  Includes methods to encode strings as integer
# index arrays into the dictionary.

$: << File.dirname(__FILE__)
require 'yaml'

module Yanbi
  class Dictionary
    attr_accessor :bag_class
  
    def initialize(w, klass)
      @index = {}
      @klass = klass
      i = (0..w.size).to_a
      w.zip(i).each { |x| @index[x.first] = x.last }
    end
  
    def to_idx(doc)
      bag = @klass.new(doc)
      bag.words.map { |w| @index[w] }
    end
  
    def self.load(fname)
      c = YAML.load(File.read(fname + '.yml'))
      raise LoadError unless c.is_a? self
      c
    end
  
    def save(name)
      File.open(name + '.yml', 'w') do |out|
        YAML.dump(self, out)
      end
    end
  end
end
