# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

shared_examples_for "A Word Bag" do
  before(:each) do
    @bag = described_class.new
  end

  it 'should have an array of counts' do
    @bag.add_text('first two two three three three')
    expect(@bag.word_counts).to eq 'first' => 1, 'two' => 2, 'three' => 3
  end

  it 'should allow removal of tokens' do
    @bag.add_text('good text stop word bad text')
    @bag.remove(%w(stop word))
    expect(@bag.word_counts).to eq 'good' => 1, 'text' => 2, 'bad' => 1
  end

  it 'should allow to accept between two counts' do
    @bag.add_text('one')
    @bag.add_text('two two')
    @bag.add_text('three three three')
    @bag.add_text('four four four four')
    expect(@bag.between_counts(2,3)).to eq %w(two two three three three)
  end

  it 'should be able to compute the intersection of two bags' do
    other_bag = described_class.new
    @bag.add_text('one two three')
    other_bag.add_text('two three four')
    expect(@bag.intersection(other_bag)).to eq %w(two three)
  end

  it 'should detect empty bag' do
    expect(@bag.empty?).to be true
  end

  it 'should remove punctuation' do
    @bag.add_text("what? is, that!")
    expect(@bag.word_counts).to eq 'what' => 1, 'is' => 1, 'that' => 1
  end

  it 'should be able to serialize itself' do
    buffer = StringIO.new
    @bag.add_text('this is a document')
    allow(File).to receive(:new).with('testfile.yml', 'w').and_return(buffer)
    allow(buffer).to receive(:write).with(@bag.words.to_yaml)
    @bag.save('testfile')
  end

  it 'should be able to load a saved version of itself' do
    data = %w(test first second third)
    allow(YAML).to receive(:load_file).with('testfile.yml').and_return(data)
    @bag.load('testfile')
    expect(@bag.words).to eq data 
  end
end
