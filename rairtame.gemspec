# coding: utf-8
# Copyright (C) 2015 Hector Sanjuan

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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rairtame/version'

Gem::Specification.new do |spec|
  spec.name          = "rairtame"
  spec.version       = Rairtame::VERSION
  spec.authors       = ["Hector Sanjuan"]
  spec.email         = ["hector@convivencial.org"]
  spec.summary       = "CLI and Ruby wrapper around the 'airtame-streamer' JSON-RPC API."
  spec.description   = <<EOF
Rairtame is a Command-Line Interface and Ruby wrapper around the 'airtame-streamer' JSON-RPC API.

It allows to easily control the `airtame-streamer` daemon, which is in charge of capturing and streaming video to an AIRTAME dongle.
EOF
  spec.homepage      = "https://github.com/hsanjuan/rairtame"
  spec.license       = "GPLv3+"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "gli", "~> 2.13"
  spec.add_dependency "uuidtools", "~> 2.1"
  spec.add_dependency "colorize", "~> 0.7"
  spec.add_dependency "jsonrpctcp", "~> 0.2"
end
