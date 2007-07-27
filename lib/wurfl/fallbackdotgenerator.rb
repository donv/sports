#!/usr/bin/env ruby

# Copyright (c) 2005, Ubiquitous Business Technology (http://ubit.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#      with the distribution.
#
#    * Neither the name of the WURFL nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.
#
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# $Id: fallbackdotgenerator.rb,v 1.1 2005/06/09 15:49:18 zevblut Exp $
# Authors: Zev Blut (zb@ubit.com)
# General Idea: Keisuke Seki (keisuke@ubit.com)

require 'wurfl/wurflhandset'
require 'wurfl/wurflutils'
require 'stringio'

class FallbackDotGenerator
  attr_accessor :show_children, :count_children, :show_root, :size
  attr_accessor :fallbacks, :handsets, :show_url, :url_generator

  def initialize(handsets=nil)
    self.show_children = true
    self.count_children = false
    self.show_root = true
    if handsets.nil?
      self.handsets = Hash.new
      self.fallbacks = Hash.new
    else
      self.handsets = handsets
      self.fallbacks = reindex_fallbacks_by_wurfl_id(handsets)
    end
    self.size = nil
    self.show_url = false
    self.url_generator = Proc.new { |node| "" }
    @io = StringIO.new
  end

  def self.initialize_from_wurfl_db_file(db_path)
    handsets, = WurflUtils.load_pstore(db_path)
    dotcmd = FallbackDotGenerator.new(handsets)
    dotcmd
  end

  def dot_graph(base_id)
    @io = StringIO.new

    @io.puts "digraph G {"
    @io.puts " center=1;"
    @io.puts " rankdir=LR;"
    @io.puts " ratio=compress;"
    @io.puts " size=\"#{size}\";" if self.size
    @io.puts " edge [arrowtail=normal, arrowhead=none];"

    bloom(base_id)

    @io.puts "}"

    @io.string
  end

  private

  def bloom(base_id)
    if self.fallbacks[base_id].empty?
      @io.puts " \"#{base_id}\" [ label=\"#{base_id} not found.\"];"
      return
    else
      @io.puts " \"#{base_id}\" [shape=box, color=blue];"
    end

    children_graph(base_id)

    if self.show_root
      # Last dig down to the base/root
      hs = self.handsets[base_id]
      roots = get_roots(hs)
      while !roots.empty?
        rt, kd = roots.pop
        @io.puts " \"#{rt}\" -> \"#{kd}\";"
        display_node(rt)
      end
    end
  end


  def display_node(node)
    return if !self.show_url
    node_url = self.url_generator.call(node)
    @io.puts " \"#{node}\" [ URL=\"#{node_url}\"];"
  end

  def children_graph(base_id)
    return if self.fallbacks[base_id].empty?
    kids = self.fallbacks[base_id]

    # Output the bloom of children
    if self.count_children
      good_kids = Array.new
      count_kids = 0

      kids.each do |kid|
        if self.fallbacks[kid].empty?
          count_kids += 1
        else
          good_kids<< kid
        end
      end

      if self.show_children
        kids = good_kids
      else
        count_kids += good_kids.size
        kids = Array.new
      end

      if count_kids > 0
        @io.puts " \"#{base_id}\"[label=\"#{base_id}\\nKids[#{count_kids}]\"];"
      end
    end

    kids.each do |child_id|
      @io.puts " \"#{base_id}\" -> \"#{child_id}\";"
      display_node(child_id)
    end

    if self.show_children
      kids.each do |child_id|
        children_graph(child_id)
      end
    end
  end

  def get_roots(handset, roots=[])
    if handset.wurfl_id == "generic" || handset.wurfl_id.nil?
      return roots
    end

    roots<< [handset.fallback.wurfl_id, handset.wurfl_id]
    get_roots(handset.fallback, roots)
  end

  # Generate a hashtable of wurfl_ids that
  # then contain an array of wurfl_ids who use the
  # keyed wurfl_id as a fallback.
  def reindex_fallbacks_by_wurfl_id(handsets)
    fallbacks = Hash.new {|h,k| h[k] = Array.new }

    handsets.each do |hid, hset|
      fallbacks[hid]
      if hset.fallback && hset.fallback.wurfl_id
        fallbacks[hset.fallback.wurfl_id]<< hid
      end
    end

    fallbacks
  end

end


class FallbackConfigFromCommandLine

  def self.usage
    puts "Usage: fallbackdotgenerator.rb [-s -c -r -h] -d wurfl_db -b base_id"
    puts "       --db, -d (wurfl_db) : The path to a WURFL DB to use."
    puts "       --base_id, -b (base_id) : A WURFL id whose fallback heirachy is graphed."
    puts "       --count_children, -c : Count the children of a node, who do not have children, unless show children is not passed in which case it counts all children."
    puts "       --show_children, -s : Shows the all of the decendants of the base_id, if not passed only the immediate children of the node are shown."
    puts "       --show_root, -r : Shows the ancestry of the node up to generic."
    puts "       --help, -h : Prints this message."
    exit 1
  end

  def self.parse
    require 'getoptlong'


    db_path = base_id = show_children = show_root = count_children = nil

    begin
      options = GetoptLong.new(
                               ["-d", "--db", GetoptLong::REQUIRED_ARGUMENT],
                               ["-b", "--base_id", GetoptLong::REQUIRED_ARGUMENT],
                               ["-s", "--hide_children", GetoptLong::NO_ARGUMENT],
                               ["-c", "--count_children", GetoptLong::NO_ARGUMENT],
                               ["-r", "--show_root", GetoptLong::NO_ARGUMENT],
                               ["-h", "--help", GetoptLong::NO_ARGUMENT]
                               )
      options.each do |opt, arg|
        case opt
        when "-d"
          db_path = arg
        when "-b"
          base_id = arg
        when "-s"
          show_children = true
        when "-c"
          count_children = true
        when "-r"
          show_root = true
        when "-h"
          usage
        else
          STDERR.puts "Unknown argument #{opt}"
          usage
        end
      end
    rescue => err
      STDERR.puts "Error: #{err.message}"
      usage
    end

    if db_path.nil?
      STDERR.puts "A path to a wurfl db must be passed."
      usage
    end

    if base_id.nil?
      STDERR.puts "A base wurfl id must be passed."
      usage
    end

    dotcmd = FallbackDotGenerator.initialize_from_wurfl_db_file(db_path)
    dotcmd.show_root = show_root
    dotcmd.show_children = show_children
    dotcmd.count_children = count_children

    [dotcmd, base_id]
  end

end

if __FILE__ == $0
  dotcmd, base_id = FallbackConfigFromCommandLine.parse

  puts dotcmd.dot_graph(base_id)
end
