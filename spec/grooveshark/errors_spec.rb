require_relative '../helper'

require 'grooveshark'

describe 'Errors' do
  it 'should test ApiError' do
    fault = {
      'code' => '25',
      'message' => 'Something went wrong'
    }

    error = Grooveshark::ApiError.new(fault)
    expect(error.to_s).to eq('25 - Something went wrong')
  end
end
