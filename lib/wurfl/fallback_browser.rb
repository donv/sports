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

# $Id: fallback_browser.rb,v 1.1 2005/06/09 15:49:18 zevblut Exp $
# Authors: Zev Blut (zb@ubit.com)

require 'wurfl/fallbackdotgenerator'
require 'webrick'
require 'cgi'


class FallbackBrowser < WEBrick::HTTPServlet::AbstractServlet
  attr_reader :work_dir

  def self.get_instance(server, *options)
    self.new(server, *options)
  end

  def initialize(server, dotcommand, work_dir="./data")
    super(server)
    @dot = dotcommand.dup
    @dot.show_url = true
    @work_dir = work_dir
  end

  def do_GET(request, response)
    conf = config_from_request(request)
    if conf.base_id.nil?
      home_page(conf, response)
    else
      graph_page(conf, response)
    end
  end


  def config_from_request(request)
    conf = FallbackRequestConfig.new
    request.query.each do |key, val|
      case key
      when "base_id"
        conf.base_id = val
      when "graph"
        conf.graph_type = val
      when "show_children"
        conf.show_children = (val == "t")
      when "show_root"
        conf.show_root = (val == "t")
      when "count_children"
        conf.count_children = (val == "t")
      when "size"
        conf.size = val
      when "submit"
      else
        STDERR.puts "Unknown query : #{key}"
      end
    end

    conf
  end

  def home_page(conf, response)
    response['Content-Type'] = 'text/html'
    response.body = "<html><head><title>Fallback Browser</title></head><body>"
    response.body<< "<h2>Insert a WURFL ID for viewing.</h2>"
    response.body<< selectors(conf)
    response.body<< "</body></html>"
  end

  def graph_page(conf, response)
    response['Content-Type'] = 'text/html'
    response.body = "<html><head><title>Fallback Browser [#{conf.base_id}]</title></head><body>"
    response.body<< "<h2>Display parameters</h2>"
    response.body<< selectors(conf)
    response.body<< "<hr/>"
    response.body<< "<h2>Fallback graph for #{conf.base_id}</h2>"
    graph_fallback(conf, response)

  end

  def graph_fallback(conf, response)
    @dot.url_generator = conf.dot_url
    @dot.show_root = conf.show_root
    @dot.show_children = conf.show_children
    @dot.count_children = conf.count_children
    @dot.size = conf.size
    dotcmds = @dot.dot_graph(conf.base_id)


    dotfile = self.work_dir + "/" + conf.filename_pattern + ".dot"
    File.open(dotfile, "w") do |f|
      f.write(dotcmds)
    end
    cmap = self.work_dir + "/" + conf.filename_pattern + ".cmap"
    img = self.work_dir + "/" + conf.filename_pattern + ".png"

    execute_dot(conf.graph_type, cmap, img, dotfile)

    response.body<< "<map name=\"fallbackmap\">"
    response.body<< File.readlines(cmap).join
    response.body<< "</map>"
    response.body<< "<img border=\"0\" src=\"/img/#{conf.filename_pattern}.png\" usemap=\"\#fallbackmap\"/>"

  end


  def execute_dot(cmd, cmap, img, dot)
    res = `#{cmd} -Tcmap -o #{cmap} -Tpng -o #{img} #{dot}`
  end

  def selectors(conf)
    res = ["<table><form action=\"/\" method=\"GET\">"]
    res << "<tr><td><b>Base WURFL ID</b></td><td><input type=\"text\" name=\"base_id\" value=\"#{conf.base_id}\"></td>"
    res << "<td><b>View size</b> [w,h] (in inches)</td><td><input type=\"text\" name=\"size\" value=\"#{conf.size}\"></td>"
    res << "</tr>"
    res << "<tr><td><b>Graph type</b></td><td>"

    conf.graph_types.each do |type, name|
      if conf.graph_type == type
        chk = "checked=\"checked\""
      else
        chk = ""
      end
      res<< "<input type=\"radio\" name=\"graph\" value=\"#{type}\" #{chk}>#{name}"
    end

    res << "</td>"

    res<< "<tr><td><b>Node options</b></td>"
    res<< "<td>"
    [ [:show_root, "Show Root"],
      [:show_children, "Show Children"],
      [:count_children, "Count Children" ]
    ].each do |meth, name|

      if conf.send(meth)
        chk = "checked=\"checked\""
      else
        chk = ""
      end

      res << " <input type=\"checkbox\" name=\"#{meth}\" value=\"t\" #{chk}>#{name}"

    end
    res<< "</td>"
    res << "<td></td><td><input type=\"submit\" value=\"View\"></td></tr>"
    res << "</form></table>"
    res.join("\n")
  end

end

class FallbackRequestConfig
  DOT = "dot"
  CIRCO = "circo"
  TWOPI = "twopi"

  attr_accessor :show_root, :show_children, :count_children
  attr_accessor :base_id, :graph_type
  attr_reader :size

  def initialize
    self.show_root = false
    self.show_children = false
    self.count_children = false
    self.graph_type = DOT
    self.base_id = nil
    self.size = "20, 20"
  end

  def size=(val)
    val = val.to_s.strip
    if val.empty?
      @size = nil
    else
      if m = /((\d+)\.?(\d*))\s*,\s*((\d+)\.?(\d*))/.match(val)
        @size = "#{m[1]}, #{m[2]}"
      else
        # Error in input, so just use a default
        @size = "8.5, 11"
      end
    end
  end

  def graph_types
    [ [DOT, "Tree"],
      [CIRCO, "Circular"],
      [TWOPI, "Radial"] ]
  end

  def dot_url
    cmds = Array.new
    cmds<< "graph=#{CGI.escape(self.graph_type)}"
    cmds<< "show_children=t" if self.show_children
    cmds<< "show_root=t" if self.show_root
    cmds<< "count_children=t" if self.count_children
    cmds<< "size=#{CGI.escape(self.size)}" if self.size
    Proc.new do |node|
      "/?base_id=#{CGI.escape(node)}&#{cmds.join("&")}"
    end
  end

  def filename_pattern
    cmds = Array.new
    cmds<< self.graph_type.upcase
    cmds<< "s" if self.show_children
    cmds<< "r" if self.show_root
    cmds<< "c" if self.count_children
    if self.size
      cmds<< "d_#{self.size.gsub(".","_").gsub(",","x").gsub(" ","")}"
    end
    self.base_id + "_" + cmds.join("")
  end

end


if __FILE__ == $0
  require 'getoptlong'

  def usage
    puts "Usage: fallback_browser.rb [-w directory -p port] -d wurfl_db"
    puts "       --db, -d (wurfl_db) : The path to a WURFL DB to use."
    puts "       --work, -w (directory) : Path to a directory to hold all of the generated files."
    puts "       If not set it makes a directory called fallback_browser_data in the current directory."
    puts "       --port, -p (number) : A port to listen for requests on.  Defaults to 2005"
    exit 1
  end

  db_path = work_dir = nil
  port = 2005
  begin
    options = GetoptLong.new(
                             ["-d", "--db", GetoptLong::REQUIRED_ARGUMENT],
                             ["-w", "--work", GetoptLong::REQUIRED_ARGUMENT],
                             ["-p", "--port", GetoptLong::REQUIRED_ARGUMENT],
                             ["-h", "--help", GetoptLong::NO_ARGUMENT]
                             )
    options.each do |opt, arg|
      case opt
      when "-d"
        db_path = arg
      when "-w"
        work_dir = arg
      when "-p"
        port = arg.to_i
      when "-h"
        usage
      else
        STDERR.puts "Unknown argument #{opt}"
        usage
      end
    end
  rescue => err
    STDERR.puts "Error: #{err.message}"
  end

  if db_path.nil?
    STDERR.puts "A path to a wurfl db must be passed."
    usage
  end

  work_dir = "./fallback_browser_data" if work_dir.nil?

  if !File.exists?(work_dir)
    Dir.mkdir(work_dir)
  end

  dotcmd = FallbackDotGenerator.initialize_from_wurfl_db_file(db_path)
  server = WEBrick::HTTPServer.new( :Port => port )
  server.mount("/", FallbackBrowser, dotcmd, work_dir)
  server.mount("/img", WEBrick::HTTPServlet::FileHandler, work_dir)

  trap("INT") { server.shutdown }
  server.start
end
