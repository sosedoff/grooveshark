require_relative 'helper'

describe 'String' do
  it 'should normalize attributes' do
    vars = %w(key_name keyName KeyName KeyNAME)
    target = 'key_name'
    vars.each { |s| expect(s.normalize_attribute).to eq(target) }
  end
end

describe 'Hash' do
  it 'should normalize simple keys' do
    h = { 'KeyName' => 'Value' }.normalize

    expect(h.key?('KeyName')).to be_falsy
    expect(h.key?('key_name')).to eq(true)
  end

  it 'should normalize symbol keys' do
    h = { KeyName: 'Value' }
    expect(h[:KeyName]).to eq('Value')
    expect(h.normalize.key?(:KeyName)).to be_falsy
    expect(h.normalize.key?('key_name')).to eq(true)
  end

  it 'should normalize nested data' do
    h = {
      'keyA' => { 'nestedKey' => 'Value' },
      'keyB' => [{ 'arrKey' => 'Value' }]
    }.normalize

    expect(h['key_a'].key?('nested_key')).to eq(true)
    expect(h['key_b']).to be_a(Array)
    expect(h['key_b'].first.key?('arr_key')).to eq(true)
  end
end
