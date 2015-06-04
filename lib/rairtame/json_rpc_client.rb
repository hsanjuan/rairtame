require 'socket'
require 'json'

module Rairtame
  class JsonRpcClientException < Exception
    attr_reader :code, :message, :hash
    def initialize(hash, message, code=nil)
      @code = code
      @message = message
      @hash = hash
    end

    def self.from_rpc_response(r)
      return JsonRpcClientException.new(r,
                                        r['error']['message'],
                                        r['error']['code'])
    end
  end

  class JsonRpcClient
    def initialize(host, port)
      @host = host
      @port = port
    end

    def self.success?(response)
      return !JsonRpcClient.is_error?(response)
    end

    def self.is_error?(response)
      return response.has_key?('error')
    end

    # def method_missing(sym, *args)
    #   return process_call(method, args)
    # end

    def [](method, *args)
      return process_call(method, args)
    end

    private

    def process_call(method, args)
      call_obj = {
        'jsonrpc' => '2.0',
        'method' => method,
        'params' => args,
        'id' => Time.now.to_i
      }

      obj_json = call_obj.to_json
      response = TCPSocket.open(@host, @port) do |s|
        s.write(obj_json)
        s.close_write()
        s.read()
      end
      parsed_response = JSON.load(response)
      if JsonRpcClient.is_error?(parsed_response)
        raise JsonRpcClientException.from_rpc_response(parsed_response)
      else
        return parsed_response
      end
    end
  end
end
