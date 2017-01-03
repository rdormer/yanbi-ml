# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

# This is the class for managing a corpus of documents.  It's recommended, though not necessary,
# that all of the documents in a given corpus be in the same category, if you're using the corpus
# to train your classifier.  Can accept either raw strings through add_doc, or files through add_file.
# Files can be delimited so that you can have more than one document in them, and commenting is
# available

$: << File.dirname(__FILE__)
require 'yanbi'

module Yanbi

  class Corpus
  
    attr_reader :docs
    attr_reader :bags
    attr_reader :all
  
    def initialize(klass=WordBag)
      @all = klass.new
      @index = {}
      @docs = []
      @bags = []
    end

    def size
      @docs.size
    end
  
    def add_file(docpath, delim=nil, comment=nil)
      infile = File.open(docpath, 'r')
      raw = infile.read
      infile.close

      raw = raw.encode("UTF-8", invalid: :replace, replace: "")
  
      if delim
        docs = raw.split(delim) 
        docs.each {|d| add_doc(d, comment)} 
      else
        add_doc(raw, comment)
      end
    end
  
    def add_doc(doc, comment=nil)
      doc.gsub! comment, '' if comment
      doc.strip!
      
      unless doc.length.zero?
        @bags << @all.class.new(doc)
        @all.add_text doc
        @docs << doc
        @index = {}
      end
    end
  
    def each_doc
      @bags.each do |bag|
        yield bag
      end
    end

    def to_index(doc)
      if @index.empty?
        w = all.words.uniq
        i = (0..w.size).to_a
        w.zip(i).each { |x| @index[x.first] = x.last }
      end

      bag = @all.class.new(doc)
      bag.words.map { |w| @index[w] }
    end
  end

end
