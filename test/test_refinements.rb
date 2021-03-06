#!/usr/bin/env ruby
#
# encoding: utf-8

# Copyright (c) [2016] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "storage"
require "storage/yaml_writer"
require "storage/fake_device_factory"

module Yast
  module Storage
    # Refinements to make the rspec tests more readable
    module TestRefinements
      refine ::Storage::Devicegraph do
        # String to represent the whole devicegraph
        #
        # The format is deterministic (always equal for equivalent devicegraphs)
        # and based in the structure generated by YamlWriter
        # @see Storage::YamlWriter
        #
        # @return [::Storage::Actiongraph]
        def to_str
          recursive_to_a(device_tree).to_s
        end

      private

        # Copy of a device tree where hashes have been substituted by sorted
        # arrays to ensure consistency
        #
        # @see YamlWriter#yaml_device_tree
        def recursive_to_a(tree)
          case tree
          when Array
            tree.map { |element| recursive_to_a(element) }
          when Hash
            tree.map { |key, value| [key, recursive_to_a(value)] }.sort_by(&:first)
          else
            tree
          end
        end

        def device_tree
          writer = Yast::Storage::YamlWriter.new
          writer.yaml_device_tree(self)
        end
      end

      refine ::Storage::Devicegraph.singleton_class do
        def new_from_file(filename)
          devicegraph = ::Storage::Devicegraph.new
          Yast::Storage::FakeDeviceFactory.load_yaml_file(devicegraph, filename)
          devicegraph
        end
      end
    end
  end
end
