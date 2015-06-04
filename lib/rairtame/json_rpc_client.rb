# coding: utf-8
# This file is part of Rairtame.

# Rairtame is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Rairtame is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Rairtame.  If not, see <http://www.gnu.org/licenses/>

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
