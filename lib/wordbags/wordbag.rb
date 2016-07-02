# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

# Word bag class, implementing the bag of words / multi-set that is so popular in text
# classification literature.  A single bag can contain multiple documents if you want 
# it to, although for training a Bayes classifier this is probably not recommended.

$: << File.dirname(__FILE__)
require 'yaml'

module Yanbi

  class WordBag 
  
    attr_reader :words
    
    def initialize(corpus=nil)
      @words = []
      @counts = {}
      standardize(corpus) if corpus
    end
  
    def add_file(filename)
      raw = File.open(filename).read
      standardize(raw)
    end
  
    def add_text(text)
      standardize(text)
    end
  
    def save(filename)
      out = File.new(filename + ".yml", "w")
      out.write(@words.to_yaml)
      out.close
    end
  
    def load(filename)
      @words = YAML.load_file(filename + ".yml")
      update_counts(@words)
    end
  
    def self.load(filename)
      WordBag.new.load(filename)
    end
  
    def word_counts(min=1)
      @counts.select {|key, value| value >= min}
    end
  
    def remove(words)
      words.each do |word|
        @words.reject! {|x| x == word}
        @counts.delete(word)
      end
    end
  
    def between_counts(min, max=nil)
      counts = @counts.select{|key, value| value >= min}
      counts.select! {|key, value| value <= max} unless max.nil?
      @words.select {|word| counts.keys.include? word}
    end
  
    def intersection(other)
      self.words & other.words
    end
  
    def empty?
      @words.empty?
    end
  
    private
  
    def standardize(raw)
      process(raw)
    end
  
    def process(raw)
      processed = raw.downcase
      processed.gsub!(/[^\w\s'\-]/, ' ')
      words = processed.split
      words = words.map {|x| x.split /-/}.flatten
  
      if block_given?
        words.map! {|x| yield x}
      end
  
      update_counts(words)
      @words.concat(words)
    end
  
    def update_counts(data)
      data.each do |word|
        if @counts[word].nil?
          @counts[word] = 1
        else
          @counts[word] += 1
        end
      end
    end
  end

end
