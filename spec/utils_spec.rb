require File.expand_path("./helper", File.dirname(__FILE__))

describe 'String' do
  it 'should normalize attributes' do
    vars = ['key_name', 'keyName', 'KeyName', 'KeyNAME']
    target = 'key_name'
    vars.each { |s| s.normalize_attribute.should == target }
  end
end

describe 'Hash' do
  it 'should normalize simple keys' do
    h = {'KeyName' => 'Value'}.normalize
    
    h.key?('KeyName').should == false
    h.key?('key_name').should == true
  end
  
  it 'should normalize symbol keys' do
    h = {:KeyName => 'Value'}.normalize
    h.key?(:KeyName).should == false
    h.key?('key_name').should == true
  end
  
  it 'should normalize nested data' do
    h = {
      'keyA' => {'nestedKey' => 'Value'},
      'keyB' => [{'arrKey' => 'Value'}]
    }.normalize
    
    h['key_a'].key?('nested_key').should == true
    h['key_b'].class.should == Array
    h['key_b'].first.key?('arr_key').should == true
  end
end