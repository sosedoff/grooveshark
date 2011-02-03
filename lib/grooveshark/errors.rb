module Grooveshark
  class InvalidAuthentication < Exception ; end
  class ReadOnlyAccess < Exception ; end
  class GeneralError < Exception ; end
  
  class ApiError < Exception
    attr_reader :code
  
    def initialize(fault)
      @code = fault['code']
      @message = fault['message']
    end
  
    def to_s
      "#{@code} - #{@message}"
    end
  end
end