require 'ipaddr'
require 'socket'
require 'pp'

require 'rairtame/config'
require 'rairtame/json_rpc_client'

module Rairtame

  class ClientException < Exception
    attr_reader :code, :message
    def initialize(message, code=nil)
      @code = code
      @message = message
    end
  end

  class Client
    STREAMER_CMDS_PORT = "8004"
    RECEIVER_PORT = "8002"

    def initialize(opts={})
      @config = Rairtame::Config.new(opts)
      @verbose = opts[:verbose]
      @streamer_host = opts[:streamer_host] || 'localhost'
      @streamer_uri = "http://#{@streamer_host}:#{STREAMER_CMDS_PORT}/"
      @json_rpc_client = JsonRpcClient.new(@streamer_host, STREAMER_CMDS_PORT)
    end

    def rpc_call(method, *params)
      begin
        log_command(method, params)
        r = @json_rpc_client[method.to_s, *params]
        log_response(r)
        return r
      rescue JsonRpcClientException
        log_response($!.hash)
        raise $!
      rescue StandardError
        msg = "Cannot connect to streamer: is it running?: #{$!.message}"
        puts $!.backtrace
        raise ClientException.new(msg)
      rescue Exception
        msg = "An error occurred while talking to the streamer: #{$!.message}"
        raise ClientException.new(msg)
      end
    end

    def init_streamer
      rpc_call(:initStreamer)
    end

    def connect(host)
      ip = resolve(host)
      rpc_call(:connect, ip, RECEIVER_PORT)
    end

    def disconnect(host)
      ip = resolve(host)
      rpc_call(:disconnect, ip, RECEIVER_PORT)
    end

    def close_streamer
      rpc_call(:closeStreamer)
    end

    def state
      rpc_call(:getState)
    end

    def pretty_state
      rpc_call(:getState)
    end

    def framerate=(v)
      rpc_call(:setStreamerSettings, 'framerate', v.to_s)
    end

    def quality=(v)
      rpc_call(:setStreamerSettings, 'quality', v.to_s)
    end

    def buffer=(v)
      rpc_call(:setStreamerSettings, 'buffer', v.to_s)
    end

    def mode=(v)
      rpc_call(:setStreamerSettings, 'streaming_mode', v)
    end

    def audio=(v)
      # TODO: Read av flags first and keep the video flag
      value = case v
              when "on" then "3"
              when "off" then "1"
              end
      rpc_call(:setStreamerSettings, 'av_flags', value)

    end

    def video=(v)
      # TODO: Read av flags first and keep the audio
      value = case v
              when "on" then "1"
              when "off" then "0"
              end
      rpc_call(:setStreamerSettings, 'av_flags', value)
    end

    # fluent video
    def video_jitterbuffer=(v)
      value = case v
              when "on" then "1"
              when "off" then "0"
              end
      rpc_call(:setStreamerSettings, 'video_jb_flags', value)
    end

    # unused
    def audio_jitterbuffer=(v)
      warn "Not implemented"
      nil
    end

    # unknown
    def jitterbuffer_delay=(v)
      rpc_call(:setStreamerSettings, 'jb_delay', v.to_s)
    end

    def reliable_transport=(v)
      warn "Not implemented"
      nil
    end

    private

    def log_command(method, params)
      return unless @verbose
      puts "Sending command: [#{method} | #{params}]"
    end

    def log_response(r)
      # log anyway
      return unless @verbose
      is_error = JsonRpcClient.is_error?(r)
      if is_error then warn "Received error:"
      else puts "Received response:" end
      pp r
    end

    def resolve(host)
      begin 
        IPAddr.new(host).to_s
      rescue IPAddr::InvalidAddressError
        Socket.getaddrinfo(host, nil)[0][3]
      end
    end
  end
end
