require 'rspec'
require_relative '../lib/model'

describe Model do
  let(:model) { Model.new }

  it 'should exist!' do
    expect(1).to eq 1
  end

  it 'can be initialized' do
    expect do 
      Model.new
    end.to_not raise_error
  end

  it 'has errors' do
    expect( model.errors ).to be_a(Hash)
  end

  it 'is valid' do
    expect( model ).to be_valid
  end

  it 'can be invalid' do
    model.send(:add_error, :foo, 'bar')
    expect( model ).to_not be_valid
  end
end
