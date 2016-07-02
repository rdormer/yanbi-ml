load File.dirname(__FILE__) + "/../test_helper.rb"

describe Yanbi::StemmedWordBag do
  it_behaves_like 'A Word Bag'

  it 'should stem words' do
    @bag = described_class.new
    @bag.add_text('owning owns owned')
    expect(@bag.word_counts).to eq 'own' => 3
  end
end
