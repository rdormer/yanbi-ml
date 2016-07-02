
shared_examples_for "A Diad Bag" do
  before(:each) do
    @bag = described_class.new
  end

  it 'should have an array of counts' do
    @bag.add_text('first second third fourth')
    expect(@bag.word_counts).to eq 'first second' => 1, 'second third' => 1, 'third fourth' => 1
  end

  it 'should drop the last individual word' do
    @bag.add_text('first second third')
    expect(@bag.word_counts).to eq 'first second' => 1, 'second third' => 1
  end

  it 'should allow removal of tokens' do
    @bag.add_text('good text stop word bad text')
    @bag.remove(['stop word'])
    expect(@bag.words).to eq ['good text', 'text stop', 'word bad', 'bad text'] 
  end

  it 'should allow to accept between two counts' do
    @bag.add_text('one')
    @bag.add_text('two two')
    @bag.add_text('three three three')
    expect(@bag.between_counts(2)).to eq ['three three', 'three three'] 
  end

  it 'should be able to compute the intersection of two bags' do
    other_bag = described_class.new
    @bag.add_text('one two three')
    other_bag.add_text('two three four')
    expect(@bag.intersection(other_bag)).to eq ['two three']
  end

  it 'should detect empty bag' do
    expect(@bag.empty?).to be true
  end

  it 'should remove punctuation' do
    @bag.add_text("what? is, that! there.")
    expect(@bag.word_counts).to eq 'what is' => 1, 'is that' => 1, 'that there' => 1
  end

  it 'should be able to serialize itself' do
    buffer = StringIO.new
    @bag.add_text('this is a document')
    allow(File).to receive(:new).with('testfile.yml', 'w').and_return(buffer)
    allow(buffer).to receive(:write).with(@bag.words.to_yaml)
    @bag.save('testfile')
  end

  it 'should be able to a saved version of itself' do
    data = %w(test first second third)
    allow(YAML).to receive(:load_file).with('testfile.yml').and_return(data)
    @bag.load('testfile')
    expect(@bag.words).to eq data 
  end
end
