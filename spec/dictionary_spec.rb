# Author::    Robert Dormer (mailto:rdormer@gmail.com)
# Copyright:: Copyright (c) 2017 Robert Dormer
# License::   MIT

require File.dirname(__FILE__) + '/test_helper'

describe Yanbi::Dictionary do

  before(:each) do
    @corpus = Yanbi::Corpus.new
    @corpus.add_doc('zero one two three')
    @corpus.add_doc('four five six seven')
    @dictionary = @corpus.to_index
  end
 
  it 'should still return the same index if more documents are added' do
    indices = @dictionary.to_idx('one two three')
    expect(indices).to eq [1, 2, 3]
    @corpus.add_doc('eight nine ten eleven twelve')
    @dictionary = @corpus.to_index
    indices = @dictionary.to_idx('one two three')
    expect(indices).to eq [1, 2, 3]
  end

  it 'should return indices that map to their corresponding word' do
    indices = @dictionary.to_idx('five four three two one')
    expect(indices).to eq [5, 4, 3, 2, 1]
  end

  it 'should return nil for unknown words' do
    indices = @dictionary.to_idx('five four three two one charlie')
    expect(indices).to eq [5, 4, 3, 2, 1, nil]
  end

  describe 'file serialization' do

    it 'should be able to save itself as a file' do
      buffer = StringIO.new
      allow(File).to receive(:open).with('testfile.yml', 'w').and_yield(buffer)
      allow(buffer).to receive(:save).with(@dictionary.to_yaml)
      @dictionary.save('testfile')
    end

    it 'should be able to load itself as a file' do
      @buffer1 = StringIO.new(@dictionary.to_yaml)
      allow(File).to receive(:read).with('testfile1.yml').and_return( @buffer1 )
      loaded_dictionary = Yanbi::Dictionary.load('testfile1')
      indices = loaded_dictionary.to_idx('zero one two three')
      expect(indices).to eq [0,1,2,3] 
    end

    it 'should raise a load error if passed the wrong object' do
      @buffer1 = StringIO.new(@corpus.to_yaml)
      allow(File).to receive(:read).with('testfile1.yml').and_return( @buffer1 )
      expect { Yanbi::Dictionary.load('testfile1') }.to raise_error(LoadError)
    end
  end
end
