# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

load File.dirname(__FILE__) + "/../test_helper.rb"

describe Yanbi::Bayes do
  it_behaves_like "A Classifier"
end
