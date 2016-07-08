# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2016 Robert Dormer
# License::   MIT

shared_examples_for "A Classifier" do
  before(:each) do
    @classifier = described_class.new(Yanbi::WordBag, :even, :odd)

    @evenbag = @classifier.newdoc('two four six')
    @oddbag = @classifier.newdoc('one three five')
    @classifier.train(:even, @evenbag)
    @classifier.train(:odd, @oddbag)
  end 

  it 'should raise if there are not enough categories' do
    expect{described_class.new(:onlyclass)}.to raise_error(ArgumentError)
  end

  it 'should allow default creation of a WordBag classifier' do
    c = described_class.default(:even, :odd)
    expect(c.newdoc('one two three').class).to eq Yanbi::WordBag
  end

  it 'should return word bags via newdoc' do
    expect(@classifier.newdoc('one').class).to eq Yanbi::WordBag

    classifier = described_class.new(Yanbi::StemmedWordBag, :even, :odd)
    expect(classifier.newdoc('one').class).to eq Yanbi::StemmedWordBag

    classifier = described_class.new(Yanbi::DiadBag, :even, :odd)
    expect(classifier.newdoc('one').class).to eq Yanbi::DiadBag
  end

  it 'should correctly classify disjoint classes' do
    text = @classifier.newdoc('one three')
    expect(@classifier.classify(text)).to eq :odd

    text = @classifier.newdoc('two six')
    expect(@classifier.classify(text)).to eq :even
  end

  it 'should classify correctly' do
    text = @classifier.newdoc('one two three')
    expect(@classifier.classify(text)).to eq :odd

    text = @classifier.newdoc('two three four')
    expect(@classifier.classify(text)).to eq :even
  end

  it 'should correctly classify intersecting classes' do
    noise = @classifier.newdoc('null nil nien')
    @classifier.train(:even, noise)
    @classifier.train(:odd, noise)
    
    text = @classifier.newdoc('one three null')
    expect(@classifier.classify(text)).to eq :odd

    text = @classifier.newdoc('two four null')
    expect(@classifier.classify(text)).to eq :even

    text = @classifier.newdoc('one three null nil')
    expect(@classifier.classify(text)).to eq :odd

    text = @classifier.newdoc('two four null nil')
    expect(@classifier.classify(text)).to eq :even

    text = @classifier.newdoc('one three null nil nien')
    expect(@classifier.classify(text)).to eq :odd

    text = @classifier.newdoc('two four null nil nien')
    expect(@classifier.classify(text)).to eq :even
  end

  it 'should correctly classify even with novel features' do
    text = @classifier.newdoc('two four this is testing')
    expect(@classifier.classify(text)).to eq :even

    text = @classifier.newdoc('one three this is testing')
    expect(@classifier.classify(text)).to eq :odd
  end

  it 'should classify correctly if using raw interface' do
    raw = described_class.new(Yanbi::WordBag, :even, :odd)
    raw.train_raw(:even, 'two four six')
    raw.train_raw(:odd, 'one three five')

    expect(@classifier.classify(@classifier.newdoc('one three'))).to eq :odd
    expect(raw.classify_raw('one three')).to eq :odd

    expect(@classifier.classify(@classifier.newdoc('two four'))).to eq :even
    expect(raw.classify_raw('two four')).to eq :even
  end

  it 'should be able to serialize itself' do
    buffer = StringIO.new
    allow(File).to receive(:open).with('testfile.obj', 'w').and_yield(buffer)
    allow(buffer).to receive(:write).with(@classifier.to_yaml)
    @classifier.save('testfile')
  end

  it 'should be able to deserialize itself' do
    buffer = StringIO.new(@classifier.to_yaml)
    allow(File).to receive(:read).with('testfile.obj').and_return(buffer)
    test = described_class.load('testfile')
    expect(test.to_yaml).to eq(@classifier.to_yaml)
  end

  it 'should raise an error if deserializing the wrong object' do
    buffer = StringIO.new(String.new.to_yaml)
    allow(File).to receive(:read).with('testfile.obj').and_return(buffer)
    expect{described_class.load('testfile')}.to raise_error(LoadError)
  end
end
