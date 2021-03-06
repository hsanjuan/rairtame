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

require 'fileutils'
require 'uuidtools'
require 'json'


module Rairtame
  class Config
    def initialize(opts={})
      set_paths(opts[:config_file])
      @config = read_config()
    end

    def [](key)
      @config[key]
    end

    def []=(key, value)
      @config[key] = value
    end

    private

    def set_paths(config_file)
      if config_file.nil?
        home = Dir.respond_to?(:home) ? Dir.home : File.expand_path('~')
        @cfg_folder = File.join(home, '.config', 'rairtame')
        @cfg_file = File.join(@cfg_folder, 'config')
      else
        @cfg_file = config_file
        @cfg_folder = File.dirname(@cfg_file)
      end
    end

    def read_config
      begin
        @config = JSON.load(File.read(@cfg_file))
        @uuid = @config['uuid']
        # We really need an uuid
        if @uuid.nil?
          create_uuid
        end
      rescue 
        initialize_config()
        retry
      end
    end

    def save_config
      begin
        File.write(@cfg_file, @config.to_json)
      rescue
        warn 'Cannot save configuration!!'
        raise $!
      end
    end

    def initialize_config
      begin
        puts "Initialize configuration at #{@cfg_file}"
        FileUtils.mkdir_p(@cfg_folder) if !File.exists?(@cfg_folder)
        FileUtils.touch(@cfg_file) if !File.exists?(@cfg_file)
        File.write(@cfg_file, '{}')
      rescue
        warn 'Cannot initialize configuration!!'
        raise $!
      end
    end

    def create_uuid
      @uuid = UUIDTools::UUID.random_create.to_s
      @config['uuid'] = @uuid
      save_config
    end
  end
end
