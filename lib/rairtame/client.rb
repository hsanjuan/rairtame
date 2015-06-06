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

require 'ipaddr'
require 'jsonrpctcp'
require 'socket'
require 'pp'

require 'rairtame/config'

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
      @json_rpc_client = Jsonrpctcp::Client.new(@streamer_host,
                                                STREAMER_CMDS_PORT)
    end

    def rpc_call(method, *params)
      begin
        log_command(method, params)
        r = @json_rpc_client[method.to_s, *params]
        log_response(r)
        return r
      rescue Jsonrpctcp::RPCException
        raise $!
      rescue Jsonrpctcp::RPCError
        log_response($!.source_object)
        raise $!
      rescue StandardError
        msg = "Cannot connect to streamer: is it running?: #{$!.message}"
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

    def status
      rpc_call(:getState)
    end
    alias :state :status

    def pretty_status
      puts
      puts "AIRTAME status:"
      puts "---------------"
      state = rpc_call(:getState)['result']
      if state['state'] == 'not initialized'
        puts "Not initialized"
      elsif state['current_mode']
        mode_str = case state['current_mode']
                   when 0 then "video"
                   when 1 then "work"
                   when 2 then "present"
                   when 3 then "manual"
                   else "unknown"
                   end
        fluent = state['remote_settings']['video_jb_flags'] == '1' ? "yes" : "no"
        reliable = state['reliable_transport'] == '1' ? "yes" : "no"
        puts "Mode: #{mode_str}"
        puts "FPS: #{state['video_fps']}"
        puts "Reliability: #{reliable}"
        puts "Fluent playback: #{fluent}"
        puts "Clients:"
        puts "  -- No clients connected" if state['clients'].empty?
        state['clients'].each do |client|
          c = client['channel']
          str = "#{c['IP']}: "
          str << "Sent #{(c['bytes_sent'] / 1024.0 / 1024.0).round(2)} MB. "
          str << "Recv: #{(c['bytes_received'] / 1024.0).round(2)} KB. "
          str << "Packet loss: #{c['packet_loss'].to_f.round(2)}. "
          str << "Avg latency: #{c['avg_latency']}"
          puts "  -- #{str}"
        end
        state
      else
        puts "Unkown response"
      end
      puts
      puts "(run with -v to see the raw response)"
      state
    end
    alias :pretty_state :pretty_status

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
      rpc_call(:setStreamerSettings, 'av_flags', on_off_to_1_0(v))
    end

    # fluent video
    def video_jitterbuffer=(v)
      rpc_call(:setStreamerSettings, 'video_jb_flags', on_off_to_1_0(v))
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
      rpc_call(:setStreamerSettings, 'reliable_transport',
               on_off_to_true_false(v))
    end

    private

    def on_off_to_1_0(value)
      case value
      when "off" then "0"
      when "on" then "1"
      else value
      end
    end

    def on_off_to_true_false(value)
      case value
      when "off" then "false"
      when "on" then "true"
      else value
      end
    end

    def log_command(method, params)
      return unless @verbose
      puts "Sending command: [#{method} | #{params}]"
    end

    def log_response(r)
      # log anyway
      return unless @verbose
      is_error = Jsonrpctcp::Client.is_error?(r)
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
