require File.dirname(__FILE__) + '/test_helper'

testfile1 = <<-EOS
testing 1
##
testing 2
##
testing 3
##
testing 4
EOS

testfile2 = <<-EOS
testing 5
##
testing 6
EOS

describe Yanbi::Corpus do

  before(:each) do
    @corpus = described_class.new
  end
  
  it 'should count loaded documents correctly' do
    @corpus.add_doc("first")
    @corpus.add_doc("second")
    @corpus.add_doc("third")
    expect(@corpus.size).to eq(3)
  end

  it 'should raise on non-existent file' do
    expect{@corpus.add_file('idontexist.txt')}.to raise_error(Errno::ENOENT)
  end

  describe 'Delimited files' do
    before(:each) do
      @buffer1 = StringIO.new(testfile1)
      @buffer2 = StringIO.new(testfile2)
      allow(File).to receive(:open).with('testfile1.txt', 'r').and_return( @buffer1 )
      allow(File).to receive(:open).with('testfile2.txt', 'r').and_return( @buffer2 )
    end
 
    it 'should load a single delimited file' do
      @corpus.add_file('testfile1.txt', '##')
      expect(@corpus.size).to eq(4)
    end
  
    it 'should load multiple delimited files correctly' do
      @corpus.add_file('testfile1.txt', '##')
      @corpus.add_file('testfile2.txt', '##')
      expect(@corpus.size).to eq(6)
    end

    it 'should process files identically to add_doc' do
      @corpus.add_file('testfile2.txt', '##')
      expect(@corpus.docs.first).to eq('testing 5') 
      expect(@corpus.docs.last).to eq('testing 6') 
      expect(@corpus.size).to eq(2)

      @corpus = described_class.new
      @corpus.add_doc('testing 5')
      @corpus.add_doc('testing 6')
      expect(@corpus.docs.first).to eq('testing 5') 
      expect(@corpus.docs.last).to eq('testing 6') 
      expect(@corpus.size).to eq(2)
    end
  end

  it 'should comment out enclosing comments' do
    input_string = "this is a test$$ of how the$$ comments"
    @corpus.add_doc(input_string, /\$\$.+\$\$/)
    expect(@corpus.docs.first).to eq("this is a test comments")
  end

  it 'should comment out line comments' do
    input_string = "this is a test@ of line comments"
    @corpus.add_doc(input_string, /@.+$/)
    expect(@corpus.docs.first).to eq("this is a test")
  end

  it 'should drop empty documents' do
    expect{@corpus.add_doc('')}.to change(@corpus, :size).by(0)
    expect{@corpus.add_doc(' ')}.to change(@corpus, :size).by(0)
    expect{@corpus.add_doc("\t\t\t")}.to change(@corpus, :size).by(0)
    expect{@corpus.add_doc("\r\r\r")}.to change(@corpus, :size).by(0)
    expect{@corpus.add_doc("\n\n\n")}.to change(@corpus, :size).by(0)
  end

  it 'should build the right wordbag' do
    @corpus.add_doc("testing")
    expect(@corpus.bags.first.class).to eq Yanbi::WordBag

    @corpus = Yanbi::Corpus.new(Yanbi::StemmedWordBag)
    @corpus.add_doc("testing")
    expect(@corpus.bags.first.class).to eq Yanbi::StemmedWordBag

    @corpus = Yanbi::Corpus.new(Yanbi::DiadBag)
    @corpus.add_doc("testing")
    expect(@corpus.bags.first.class).to eq Yanbi::DiadBag
  end
end
