load File.dirname(__FILE__) + "/../test_helper.rb"

describe Yanbi::Bayes do
  it_behaves_like "A Classifier"
end
