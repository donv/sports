#!/usr/bin/env ruby

# Copyright (c) 2003, Zev Blut (zb@104.com)
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
#    * Neither the name of the UAProfToWURFL nor the names of its
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

require "getoptlong"
require "net/http"
require "fileutils"

require "uaproftowurfl"
require "wurfl/wurflhandset"
require "wurfl/wurflutils"
include WurflUtils

# An addition to the UAProf to Wurfl to generate a WurflHandset from the UAProf.      
class UAProfToWURLF
  def make_wurfl_handset
    hand = WurflHandset.new("UAProf",@wurfl["user_agent"])
    @wurflgroups.each do |group|
      @wurfl[group].sort.each do |key,value|
	hand[key] =  value
      end
    end
    return hand
  end

  # A method to change the value of a UAProf entry
  def change_wurfl_value(key,value)
    found = false
    @@group_key_mapping.each do |group,khash|
      if @wurfl[group].key?(key)
	found = true
      elsif khash.key?(key)
	found = true
      end
      if found
	@wurfl[group][key] = value
	return
      end
    end
    STDERR.puts "change_wurfl_value: Key Not found: #{key}"
  end

end

class WurflHandset
  def my_size
    @capabilityhash.size
  end
end

def parse_mapping_file(file)
  if !File.exists?(file)
    STDERR.puts "Mapping File does not exist.  File passed was #{file}."
    return Array.new
  end
  mappings = Array.new
  f = File.new(file)
  f.each do |line|
    if m = /^"(.*)" "(.*)"$/.match(line.strip)
      uaprof = strip_extra_quotes(m[1])
      useragent = strip_extra_quotes(m[2])
      mappings<< [uaprof,useragent]
    else
      STDERR.puts "Irregular format for line: #{line}" if line.strip != ""
    end
  end
  f.close

  return mappings
end

def strip_extra_quotes(value)
  if m = /^"(.*)"$/.match(value)
    return m[1]
  else
    return value
  end
end

def get_uaprofile(uaprof,profiledir,check=false)
  file = strip_uaprof(uaprof)
  if File.exists?("#{profiledir}/#{file}") && check
    return file
  end
  
  file = get_and_save_uaprof_file(uaprof,profiledir)
  return file
end

# Strip off the http headers so that we just have the URI
def strip_uaprof(uaprof)
  uaprof_file = nil
  if m = /(https?:\/\/)(.*)$/.match(uaprof)
    uaprof_file = m[2]
  else
    STDERR.puts "Cannot find the base UAProf file in URI: #{uaprof}"
  end
  return uaprof_file
end

def load_pstore(pstorefile)
  hands = Hash.new
  begin
    handsid, = load_wurfl_pstore(pstorefile)
    handsid.each { |id,val| hands[val.user_agent] = val }
  rescue => err
    STDERR.puts "Error: Cannot load PStore file. #{pstorefile}"
    STDERR.puts err.message
    exit 1
  end
  return hands
end

def get_and_save_uaprof_file(uaprof_url,savedirectory,limit=0)
  base,path,port = parse_url(uaprof_url)
  #STDERR.puts "DEBUG: BASE:#{base};PORT:#{port};PATH:#{path}"
  raise "Too many redirects from original url" if limit > 3
  raise "Unparseable URL: #{url}" if base.nil?

  port = 80 if port.nil?
  http = Net::HTTP.new(base,port)
  begin
    resp, data = http.get(path)
    # technically we should keep the original file for a 302, but
    # for the time being I am lumping it with a 301
    if resp.code == "301" || resp.code == "302"
      # get location and call self again
      http.finish if http.started?
      limit += 1
      return get_and_save_uaprof_file(resp['location'],savedirectory,limit)      
    elsif resp.code != "200"
      raise "Unexpected HTTP Response code:#{resp.code} for #{uaprof_url}"
    end
  rescue => err
    raise
  end

  # Make the directories, based upon the base, to save the uaprof into.
  tmppath = seperate_file_from_path(path)
  FileUtils.makedirs("#{savedirectory}/#{base}/#{tmppath}")
  f = File.new("#{savedirectory}/#{base}/#{path}","w")
  f.write(data)  
  f.close
  
  # return the file as it may change due to redirects
  "#{base}/#{path}"
end

def parse_url(url)
  m = /(http:\/\/)?(.*?)(:(\d*))?\/(.*)/i.match(url.strip)
  
  return nil if m.nil?
  return m[2],"/#{m[5]}",m[4]
end

#Returns the path without the file
def seperate_file_from_path(path)
  res = path.split("/")
  if res.size == 1
    ""
  else
    res[0..res.size - 2].join("/")
  end
end

class UAProfToWURLF
@@group_key_mapping = {
  "sound_format" => {
    "amr" => true,
    "au" => true,
    "compactmidi" => true,
    "digiplug" => true,
    "imelody" => true,
    "midi_monophonic" => true,
    "midi_polyphonic" => true,
    "mld" => true,
    "mmf" => true,
    "mp3" => true,
    "nokia_ringtone" => true,
    "rmf" => true,
    "smf" => true,
    "sp_midi" => true,
    "voices" => true,
    "wav" => true,
    "xmf" => true,
  },
  "j2me" => {
    "backlight" => true,
    "bluetooth" => true,
    "calendar_access" => true,
    "cldc_10" => true,
    "download_limit" => true,
    "extra_graphics_api" => true,
    "extra_sounds_api" => true,
    "generate_sms_messages" => true,
    "imei" => true,
    "irda" => true,
    "j2me_colors" => true,
    "j2me_gif" => true,
    "j2me_greyscale" => true,
    "j2me_jpg" => true,
    "j2me_softkeys" => true,
    "midp_10" => true,
    "motorola_lwt_extensions" => true,
    "personal_java" => true,
    "phonebook_access" => true,
    "phonenumber" => true,
    "physical_memory_limit" => true,
    "runtime_memory_limit" => true,
    "screen_height" => true,
    "screen_width" => true,
    "socket" => true,
    "vibration" => true,
  },
  "security" => {
    "https_detectable" => true,
    "https_support" => true,
    "phone_id_provided" => true,
  },
  "object_download" => {
    "downloadfun_support" => true,
    "picture" => true,
    "picture_bmp" => true,
    "picture_colors" => true,
    "picture_gif" => true,
    "picture_greyscale" => true,
    "picture_max_height" => true,
    "picture_jpg" => true,
    "picture_png" => true,
    "picture_df_size_limit" => true,
    "picture_wbmp" => true,
    "picture_max_width" => true,
    "ringtone" => true,
    "ringtone_compactmidi" => true,
    "ringtone_digiplug" => true,
    "ringtone_imelody" => true,
    "ringtone_midi_monophonic" => true,
    "ringtone_midi_polyphonic" => true,
    "ringtone_df_size_limit" => true,
    "screensaver" => true,
    "screensaver_bmp" => true,
    "screensaver_colors" => true,
    "screensaver_gif" => true,
    "screensaver_greyscale" => true,
    "screensaver_max_height" => true,
    "screensaver_jpg" => true,
    "screensaver_png" => true,
    "screensaver_df_size_limit" => true,
    "screensaver_wbmp" => true,
    "screensaver_max_width" => true,
    "wallpaper" => true,
    "wallpaper_bmp" => true,
    "wallpaper_colors" => true,
    "wallpaper_gif" => true,
    "wallpaper_greyscale" => true,
    "wallpaper_max_height" => true,
    "wallpaper_jpg" => true,
    "wallpaper_png" => true,
    "wallpaper_df_size_limit" => true,
    "wallpaper_wbmp" => true,
    "wallpaper_max_width" => true,
  },
  "product_info" => {
    "brand_name" => true,
    "model_name" => true,
  },
  "cache" => {
    "time_to_live_support" => true,
    "total_cache_disable_support" => true,
  },
  "wta" => {
    "nokia_voice_call" => true,
    "wta_call_log" => true,
    "wta_gsm" => true,
    "wta_is136" => true,
    "wta_misc" => true,
    "wta_net_text" => true,
    "wta_pdc" => true,
    "wta_phonebook" => true,
    "wta_voice_call" => true,
  },
  "image_format" => {
    "bmp" => true,
    "colors" => true,
    "epoc_bmp" => true,
    "gif" => true,
    "greyscale" => true,
    "jpg" => true,
    "png" => true,
    "tiff" => true,
    "wbmp" => true,
  },
  "xhtml_ui" => {
    "xhtml_autoexpand_select" => true,
    "xhtml_display_accesskey" => true,
    "xhtml_honors_bgcolor" => true,
    "xhtml_select_as_dropdown" => true,
    "xhtml_select_as_popup" => true,
    "xhtml_select_as_radiobutton" => true,
    "xhtml_support_wml2_namespace" => true,
    "xhtml_supports_forms_in_table" => true,
  },
  "display" => {
    "columns" => true,
    "max_image_height" => true,
    "max_image_width" => true,
    "resolution_height" => true,
    "resolution_width" => true,
    "rows" => true,
  },
  "wml_ui" => {
    "access_key_support" => true,
    "break_list_of_links_with_br_element_recommended" => true,
    "built_in_back_button_support" => true,
    "card_title_support" => true,
    "deck_prefetch_support" => true,
    "elective_forms_recommended" => true,
    "icons_on_menu_items_support" => true,
    "image_as_link_support" => true,
    "insert_br_element_after_widget_recommended" => true,
    "menu_with_list_of_links_recommended" => true,
    "menu_with_select_element_recommended" => true,
    "numbered_menus" => true,
    "proportional_font" => true,
    "softkey_support" => true,
    "table_support" => true,
    "times_square_mode_support" => true,
    "wizards_recommended" => true,
    "wrap_mode_support" => true,
  },
  "mms" => {
    "built_in_camera" => true,
    "built_in_recorder" => true,
    "mms_amr" => true,
    "mms_bmp" => true,
    "mms_gif_animated" => true,
    "mms_gif_static" => true,
    "mms_jad" => true,
    "mms_jar" => true,
    "mms_jpeg_baseline" => true,
    "mms_jpeg_progressive" => true,
    "mms_max_height" => true,
    "mms_max_size" => true,
    "mms_max_width" => true,
    "mms_midi_monophonic" => true,
    "mms_midi_polyphonic" => true,
    "mms_midi_polyphonic_voices" => true,
    "mms_mmf" => true,
    "mms_mp3" => true,
    "mms_nokia_3dscreensaver" => true,
    "mms_nokia_operatorlogo" => true,
    "mms_nokia_ringingtone" => true,
    "mms_nokia_wallpaper" => true,
    "mms_ota_bitmap" => true,
    "mms_png" => true,
    "mms_rmf" => true,
    "mms_spmidi" => true,
    "mms_symbian_install" => true,
    "mms_vcard" => true,
    "mms_wav" => true,
    "mms_wbmp" => true,
    "mms_wbxml" => true,
    "mms_wml" => true,
    "mms_wmlc" => true,
    "mms_xmf" => true,
    "receiver" => true,
    "sender" => true,
  },
  "wap_push" => {
    "ascii_support" => true,
    "connectionless_cache_operation" => true,
    "connectionless_service_indication" => true,
    "connectionless_service_load" => true,
    "connectionoriented_confirmed_cache_operation" => true,
    "connectionoriented_confirmed_service_indication" => true,
    "connectionoriented_confirmed_service_load" => true,
    "connectionoriented_unconfirmed_cache_operation" => true,
    "connectionoriented_unconfirmed_service_indication" => true,
    "connectionoriented_unconfirmed_service_load" => true,
    "expiration_date" => true,
    "iso8859_support" => true,
    "utf8_support" => true,
    "wap_push_support" => true,
  },
  "markup" => {
    "html_wi_imode_html_1" => true,
    "html_wi_imode_html_2" => true,
    "html_wi_imode_html_3" => true,
    "html_wi_imode_html_4" => true,
    "html_wi_imode_html_5" => true,
    "html_wi_imode_htmlx_1" => true,
    "html_web_3_2" => true,
    "html_web_4" => true,
    "voicexml" => true,
    "wml_1_1" => true,
    "wml_1_2" => true,
    "wml_1_3" => true,
    "wmlscript_1_0" => true,
    "wmlscript_1_1" => true,
    "wmlscript_1_2" => true,
    "wmlscript_1_3" => true,
    "html_wi_w3_xhtmlbasic" => true,
    "html_wi_oma_xhtmlmp_1_0" => true,
    "multipart_support" => true,
  },
  "storage" => {
    "max_deck_size" => true,
    "max_length_of_password" => true,
    "max_length_of_username" => true,
    "max_no_of_bookmarks" => true,
    "max_no_of_connection_settings" => true,
    "max_object_size" => true,
    "max_url_length_bookmark" => true,
    "max_url_length_cached_page" => true,
    "max_url_length_homepage" => true,
    "max_url_length_in_requests" => true,
  },
  "bugs" => {
    "basic_authentication_support" => true,
    "empty_option_value_support" => true,
    "emptyok" => true,
    "post_method_support" => true,
  },
  "chtml_ui" => {
    "chtml_display_accesskey" => true,
    "emoji" => true,
  },
}

end

if __FILE__ == $0

  def usage
    puts "Usage: uaprofwurflcomparator.rb  -d profiledirectory -f mappingfile [-w wurfldb] [-c] [-h | --help] "
    puts "Examples:"
    puts "uaprofwurflcomparator.rb -d ./profiles -f all-profile.2003-08.log -c -w wurfl.db"
    exit 1
  end
  
  def help
    puts "-d --directory : The directory to store the UA Profiles found in the log file."
    puts "-f --file : The log file that has a UAProfile to User-Agent mapping per line."
    puts "-c --check : A flag that will make sure to check if the profile is already in the directory or not.  If it is not then it will download it."
    puts "-w --wurfldb : A Ruby PStore Database of the WURFL, that is used to compare against the UAProfiles."
    puts "-g --hide-generic : A flag that will hide differences that come from a WURFL's generic setting."
    puts "-m --merge : A flag that merges the UAProf and WURFL handset to output a standalone WURFL XML entry."
    puts "             Defaults to only outputing the differences in a WURFL XML format."
    puts "-o --wurfl-wins : When doing a merge output, and if the difference is coming from the direct WURFL"
    puts "                  entry or if the entry has no setttings (as it is just a User-Agent record) then "
    puts "                  its' direct fallback, the WURFL's value will win and thus be output instead of "
    puts "                  the UAProf's value."
    puts "-h --help : This message."
    exit 1
  end

  profiledirectory = mappingfile = pstorefile = nil
  existancecheck = false
  hide_generic = false
  merge_output = false
  wurfl_wins = false
  begin
    opt = GetoptLong.new(
			 ["-d","--directory", GetoptLong::REQUIRED_ARGUMENT],
			 ["-f","--file", GetoptLong::REQUIRED_ARGUMENT],
			 ["-c","--check", GetoptLong::NO_ARGUMENT],
			 ["-h","--help", GetoptLong::NO_ARGUMENT],
			 ["-w","--wurfldb", GetoptLong::REQUIRED_ARGUMENT],
			 ["-g","--hide-generic", GetoptLong::NO_ARGUMENT],
			 ["-m","--merge", GetoptLong::NO_ARGUMENT],
			 ["-o","--wurfl-wins", GetoptLong::NO_ARGUMENT]
			 )
    
    opt.each { |arg,val|
      case arg
      when "-d"
	profiledirectory = val.strip
      when "-f"
	mappingfile = val.strip
      when "-c"
	existancecheck = true
      when "-h"
	help
      when "-w"
	pstorefile = val.strip
      when "-g"
	hide_generic = true
      when "-m"
	merge_output = true
      when "-o"
	wurfl_wins = true
      else
	usage
      end
    }
    usage if mappingfile.nil? || profiledirectory.nil?
  rescue => err
    usage
  end

  profiles = Hash.new
  duplicates = Hash.new
  mappings = parse_mapping_file(mappingfile)
  mappings.each do |uaprof,useragent|
    begin
      prof_file = get_uaprofile(uaprof,profiledirectory,existancecheck)
      uaprof_mapper = UAProfToWURLF.new
      uaprof_mapper.uaprof_url = uaprof
      if profiles.key?(useragent)
	duplicates[useragent] = Array.new if !duplicates.key?(useragent)
	duplicates[useragent]<<uaprof
	next
      end
      uaprof_mapper.parse_UAProf("#{profiledirectory}/#{prof_file}")
      profiles[useragent] = uaprof_mapper
    rescue Exception => err
      STDERR.puts "Error: File #{uaprof}; User-Agent:#{useragent}"
      STDERR.puts "Error:#{err.message}"      
      STDERR.puts err.backtrace      
    end  
  end

  duplicates.each do |key,profs|
    STDERR.puts "Duplicates exist for #{key}"
    profs.each {|prof| STDERR.puts "-- #{prof}" }
  end

  exit 0 if !pstorefile

  wurflhandsets = load_pstore(pstorefile)
  
  puts "Comparing WURFL Handsets"
  profiles.each do |key,val|
    puts "",""
    
    if !wurflhandsets.key?(key)
      puts "UAProf has a new Handset: #{key}"
      puts "--------------------------------"
      val.output_WURFL(nil,key)
      puts "--------------------------------"
    else
      uahand = val.make_wurfl_handset   
      uahand.user_agent = key
      uahand.wurfl_id = wurflhandsets[key].wurfl_id
      res = uahand.compare(wurflhandsets[key])
      # Set the fallback afterwards to make the differnces match the UAProf output.
      uahand.fallback = wurflhandsets[key].fallback
      if res.size > 0
	puts "#{key} : For UAProf and WURFL differ"
	res.each do |dkey,dval,did|
	  next if did == "generic" && hide_generic
	  #Key UAPROF Value WURFL Value WURFL source id
	  puts "  Key:#{dkey}; UVAL:#{uahand[dkey]}; WVAL:#{dval}; WSRCID:#{did}"
	end
	#val["user_agent"] = key
	puts ""
	puts "WURFL Changes are:"
	puts ""	  

	filters = nil
	if merge_output && wurfl_wins

	  # Do not filter out the items that are set from the main WURFL entry
	  res.each do |dkey,wval,wid|	
	    if wurflhandsets[key].my_size != 0
	      if wid == uahand.wurfl_id 
		#filters<< key if !wval.
		#else
		#set the value 
		val.change_wurfl_value(dkey, wval)
	      end
	    elsif wurflhandsets[key].fallback.my_size != 0
	      if wid == wurflhandsets[key].fallback.wurfl_id 
		val.change_wurfl_value(dkey, wval)
	      end
	    end	  
	  end

	elsif merge_output && !wurfl_wins
	  wurflhandsets[key].each do |whkey, whval|
	    if uahand[whkey].nil?
	      # The UAProf does not define the value so we set it
	      val.change_wurfl_value(whkey, whval)
	    end
	  end
	else
	  #Only output the differences
	  filters = uahand.keys
	  res.each { |dk,x,y| filters.delete(dk) }
	end
	

	val.output_WURFL(filters,uahand.user_agent,uahand.wurfl_id,uahand.fallback.wurfl_id)

      else
	puts "#{key} : For UAProf and WURFL match"
      end
    end
  end
  
end
