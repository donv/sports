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

require "rexml/document"

# A class to handle reading a UAProfile and generating an equivalent 
# WURFL entry.
# See http://wurfl.sourceforge.net/ for more details about the WURFL.
# Author: Zev Blut
# Version: 1.1 Additional mappings added from Andrea Trasatti
# Version: 1.2 More mappings added from Andrea Trasatti
# Version: 1.3 more mappings and a few changes for error handling.
class UAProfToWURLF

  # The url that has UAProf xml
  attr_accessor :uaprof_url

  def initialize
    # The WURFL is considered a hashtable of hashtables for all the
    # wurfl groups.
    @wurfl = Hash.new
    #Initialize all of the sub hashes
    @wurflgroups = [
      "product_info","wml_ui","chtml_ui","xhtml_ui",
      "markup","cache","display","image_format","bugs",
      "wta","security","storage","object_download","wap_push",
      "j2me","mms","sound_format","streaming","sms","drm"
    ]
    @wurflgroups.each do |key|
      @wurfl[key] = Hash.new
    end    
    @wurfl["user_agent"] = ""
    @uaprof_url = nil
    @bits_per_pixel = nil # This is used to store the UAProf value.
  end

  # Takes a UAProfile file (in the future could also take a URL)
  # and then calls the method named after each UAProfile entry.
  # This then maps the UAProfile component entry to a WURFL entry.
  # This method can be called multiple times to create patched WURFL
  # entry.
  def parse_UAProf(uaproffile)
    file = File.new(uaproffile)
    begin
      doc = REXML::Document.new(file)
    rescue Exception => err
      STDERR.puts "Exception while parsing the UAProfile RDF file #{uaproffile}."
      STDERR.puts "This UAProfToWurfl instance is invalid."
      STDERR.puts err.class
      STDERR.puts err.message
      STDERR.puts err.backtrace
      return
    end

    # Decide XPath based upon UAProf XML style.
    # The most common XPath for the RDFs.
    xpath = "rdf:RDF/rdf:Description/prf:component/rdf:Description/*"
    paths = [
      # A catch for a Samsung RDF
      "rdf:RDF/prf:component/*",      
      # A catch for an LG-G3100 handset
      "rdf:RDF/rdf:Description/prf:Component/rdf:Description/*",      
    ].each do |test_path|
      if !doc.elements[test_path].nil?
	# Then set the xpath to the exceptional case.
	xpath = test_path 
	break
      end
    end

    #get rdf:Description ID as that says the profile of phone..?
    doc.elements.each(xpath) do |element|
      #doc.elements.each("//rdf:Description/*") do |element|
      next if element.expanded_name == "rdf:type" #ignore the type value
      methodname = make_method_name(element.name)
      if self.respond_to?(methodname)
	begin
	  method = self.method(methodname)
	  method.call(element)
	rescue Exception => err
	  STDERR.puts "Uncaught exception calling #{element.name}"
	  STDERR.puts err.class
	  STDERR.puts err.message
	  STDERR.puts err.backtrace
	end
      else
	STDERR.puts "Undefined UAProf component: #{element.name}"
      end
    end
  end

  # Generates a WURFL entry.
  # For now simply outputs the XML to Standard Out.  
  # filters: are keys to leave out when printing the WURFL
  # user_agent: is an explicit user-agent to use for output
  # wurfl_id: an explicit id for the entry
  def output_WURFL(filters=nil,user_agent=nil,wurfl_id="UAProf",fallback="generic")
    user_agent = @wurfl["user_agent"] if user_agent.nil?    
    puts "		<!-- UAProf: #{@uaprof_url} -->" if @uaprof_url
    puts "		<device user_agent=\"#{user_agent}\" fall_back=\"#{fallback}\" id=\"#{wurfl_id}\">"
    #GF
    # It would be best if the id is set to the model name (removing any spaces) and prepending '_verNew' after it. 
    # This will elimiate duplicated "UAProf" ids.
    @wurflgroups.each do |group|
      next if @wurfl[group].size == 0 || (!filters.nil? && (@wurfl[group].keys - filters.to_a).size == 0)
      puts "			<group id=\"#{group}\">"
      @wurfl[group].sort.each do |key,value|
	next if !filters.nil? && filters.include?(key)
	puts "				<capability name=\"#{key}\" value=\"#{value}\"/>"
      end
      puts "			</group>"
    end
    puts "		</device>"
  end


  ######################################################################
  # UAProfile Mappings
  # Each entry below is an item in the UAProfile.
  # The element is the XML entry that contains the data about the 
  # UAProfile item.  It is used to then create a mappings to the WURFL.
  ######################################################################


  def BitsPerPixel(element)
    bits = element.text.to_i
    @bits_per_pixel = bits # Save the bits for usage in other color fields.
    bits = 2 ** bits if bits !=2 
    @wurfl["image_format"]["colors"] = bits
  end

  def ColorCapable(element)
    if element.text == "No"
      if @wurfl["image_format"].key?("colors")
	if @wurfl["image_format"]["colors"] > 2      
	  @wurfl["image_format"]["greyscale"] = true
	end
      else
	STDERR.puts "ColorCapable called before BitsPerPixel, thus unable to determine if greyscale."
      end
    end
  end

  def CPU(element)
  end

  def ImageCapable(element)
  end
  
  def InputCharSet(element)
  end

  def Keyboard(element)
  end
  
  def Model(element)
    @wurfl["product_info"]["model_name"] = element.text
  end

  def NumberOfSoftKeys(element)
    num = element.text.to_i
    if num > 0
      @wurfl["wml_ui"]["softkey_support"] = true
      # in theory we should only check this if j2me support exists
      @wurfl["j2me"]["j2me_softkeys"] = num 
    end
  end

  def OutputCharSet(element)
  end

  def PixelAspectRatio(element)
  end

  def PointingResolution(element)
  end

  def ScreenSize(element)
    width, height = break_num_x_num(element.text)
    @wurfl["display"]["resolution_width"] = width
    @wurfl["display"]["resolution_height"] = height
    # GF
    # Default the max_image_* to the resolution_* as the best guess instead 
    # of allowing to default to the generic capability?   
    @wurfl["display"]["max_image_width"] = width
    # Andrea and GF would like the max_image_width to 20 pixels
    # less that the UAProf due to the tendancy of the handsets to
    # have title bars and other headers that make the browsing image
    # height smaller.  This is should probably be a preferred settting...
    @wurfl["display"]["max_image_height"] = (height > 20) ? (height - 20) : height
    # Java would be the same?
    @wurfl["j2me"]["screen_width"] = width
    @wurfl["j2me"]["screen_height"] = height
  end
  
  def ScreenSizeChar(element)
    columns,rows = break_num_x_num(element.text)
    @wurfl["display"]["columns"] = columns
    @wurfl["display"]["rows"] = rows
  end

  def StandardFontProportional(element)
  end

  def SoundOutputCapable(element)
  end

  def TextInputCapable(element)
  end
  
  def VoiceInputCapable(element)
  end

  def Vendor(element)
    @wurfl["product_info"]["brand_name"] = element.text
  end

  ########## SoftwarePlatform
  def AcceptDownloadableSoftware(element)
    #?good to know?
  end
  
  def AudioInputEncoder(element)
  end
  
  # This one does a large amount of mapping
  def CcppAccept(element)   
    items = get_items_from_bag(element)
    items.each do |type|
      # Use regular expression comparisons to deal with values
      # that sometimes contain q or Type that we do not need
      # to bother with.
      case type
      when /^image\/jpeg/,"image/jpg"
	@wurfl["image_format"]["jpg"] = true 
	#GF
      when /^image\/gif/, "image/x-gif"
	@wurfl["image_format"]["gif"] = true
      when /image\/vnd\.wap\.wbmp/
	@wurfl["image_format"]["wbmp"] = true
      when /^image\/bmp/,"image/x-bmp","image/x-ms-bmp"
	@wurfl["image_format"]["bmp"] = true
	#GF
      when /^image\/png/, "image/x-png"
 	@wurfl["image_format"]["png"] = true
 	#GF   Need to add capabilities for Scaler Vector Graphic capabilities
      when "image/svg", "image/svg+xml"
	# svg capability to be added in image_format, object_download and mms
      when "application/smil"
	#GF  Need to add an mms capability smil
      when "application/vnd.smaf","application/x-smaf","application/smaf"
	@wurfl["sound_format"]["mmf"] = true
	#Andrea2005
	@wurfl["object_download"]["ringtone"] = true
	@wurfl["object_download"]["ringtone_mmf"] = true
      when "audio/x-beatnik-rmf","audio/x-rmf","audio/rmf","audio/x-beatnik-rmf"
	@wurfl["sound_format"]["rmf"] = true
	#Andrea2005
	@wurfl["object_download"]["ringtone"] = true
	@wurfl["object_download"]["ringtone_rmf"] = true
      when "audio/vnd.qcelp"
	#This is QUALCOMM's PureVoice format
      when "application/x-pmd"
	@wurfl["sound_format"]["compactmidi"] = true
      when "audio/amr","audio/x-amr"
	@wurfl["sound_format"]["amr"] = true
	#Andrea2005
	@wurfl["object_download"]["ringtone"] = true
	@wurfl["object_download"]["ringtone_amr"] = true
      when "audio/midi","audio/mid","audio/x-midi","audio/x-mid"
	@wurfl["sound_format"]["midi_monophonic"] = true
	# We can play it safe an say mono. what about poly?
      when "audio/sp-midi"
	@wurfl["sound_format"]["sp_midi"] = true  
      when "audio/wav","audio/x-wav","application/wav","application/x-wav"
	@wurfl["sound_format"]["wav"] = true  
      when "image/tiff"
	@wurfl["image_format"]["tiff"] = true
      when /^audio\/imelody/i,"audio/x-imy",/^text\/x-iMelody/i,/^text\/iMelody/i,/^audio\/x-imelody/i, "application/x-imy", "audio/vnd.ttc.imelody"
	@wurfl["sound_format"]["imelody"] = true
	#Andrea2005
	@wurfl["object_download"]["ringtone"] = true
	@wurfl["object_download"]["ringtone_imelody"] = true
      when "application/vnd.nokia.ringing-tone"
	@wurfl["sound_format"]["nokia_ringtone"] = true  
      when "audio/mpeg3", "audio/mp3", "audio/mpg3", "audio/x-mp3", "audio/x-mpeg3"
	@wurfl["sound_format"]["mp3"] = true
	#Andrea2005
	@wurfl["object_download"]["ringtone"] = true
	@wurfl["object_download"]["ringtone_mp3"] = true
      when "text/x-eMelody"
      when "text/x-vMel"
      when /^text\/plain/
      when "text/x-vCard"
      when "text/x-vCalendar"
      when "application/vnd.wap.mms-message"
      when "application/vnd.wap.multipart.mixed"
      when "application/vnd.wap.multipart.related"
	@wurfl["markup"]["multipart_support"] = true  
      when "application/octet-stream"
      when "application/vnd.eri.thm"
      when "application/vnd.openwave.pp"
      when "application/vnd.phonecom.im"
      when "application/vnd.phonecom.mmc-wbxml"
      when "application/vnd.phonecom.mmc-wbxml;Type=4364"
      when "application/vnd.phonecom.mmc-xml"
      when "application/vnd.syncml-xml-wbxml"
      when "application/vnd.uplanet.alert"
      when "application/vnd.uplanet.alert-wbxml"
      when "application/vnd.uplanet.bearer-choice"
      when "application/vnd.uplanet.bearer-choice-wbxml"
      when "application/vnd.uplanet.cacheop"
      when "application/vnd.uplanet.cacheop-wbxml"
      when "application/vnd.uplanet.channel"
      when "application/vnd.uplanet.channel-wbxml"
      when "application/vnd.uplanet.list"
      when "application/vnd.uplanet.listcmd"
      when "application/vnd.uplanet.listcmd-wbxml"
      when "application/vnd.uplanet.list-wbxml"
      when "application/vnd.uplanet.provisioning-status-uri"
      when "application/vnd.uplanet.signal"
      when "application/vnd.wap.coc"
	@wurfl["wap_push"]["connectionless_cache_operation"] = true
	@wurfl["wap_push"]["connectionoriented_unconfirmed_cache_operation"] = true
	@wurfl["wap_push"]["connectionoriented_confirmed_cache_operation"] = true
      when "text/vnd.wap.co"
	@wurfl["wap_push"]["connectionless_cache_operation"] = true
	@wurfl["wap_push"]["connectionoriented_unconfirmed_cache_operation"] = true
      when "application/vnd.wap.multipart.header-set"
      when "application/vnd.wap.sia"
	# service indication a?
      when "application/vnd.wap.sic"
	@wurfl["wap_push"]["connectionoriented_confirmed_service_indication"] = true
      when "application/vnd.wap.slc"
	@wurfl["wap_push"]["connectionoriented_confirmed_service_load"] = true
      when "application/vnd.wap.si","text/vnd.wap.si"
	# if the device supports connection oriented will also support
	# connectionless
	@wurfl["wap_push"]["connectionoriented_unconfirmed_service_indication"] = true
	@wurfl["wap_push"]["connectionless_service_indication"] = true
      when "application/vnd.wap.sl","text/vnd.wap.sl"
	@wurfl["wap_push"]["connectionoriented_unconfirmed_service_load"] = true
	@wurfl["wap_push"]["connectionless_service_load"] = true
      when "application/vnd.wap.wbxml"
      when /^application\/vnd\.wap\.wmlc/i
	#"application/vnd.wap.wmlc;Level=1.3"
	#"application/vnd.wap.wmlc;Type=1108"
	#"application/vnd.wap.wmlc;Type=4360"
	#"application/vnd.wap.wmlc;Type=4365"
      when /application\/vnd\.wap\.wml(.)?scriptc/i
      when "application/vnd.wap.wtls-ca-certificate"
      when "application/vnd.wap.wtls-user-certificate"
      when "application/vnd.wap.xhtml+xml","application/xhtml+xml",
	  "application/xhtml+xml;profile=\"http://www.wapforum.org/xhtml\""
      when "application/xml"
      when "application/vnd.wap.multipart.related", "application/vnd.wap.multipart.mixed"
        @wurfl["markup"]["multipart_support"] = true
      when "application/vnd.oma.drm.message"
      when "application/vnd.oma.dd+xml"
        @wurfl["object_download"]["oma_support"] = true
      when /application\/x-mmc\./
        @wurfl["object_download"]["downloadfun_support"] = true
        # There is much Download Fun logic to do here
        # A few examples of what we may get are included

        val = parse_download_fun_accept(type)
        if val.nil?
          next
          # Then we probably received one of these what to do about them?
          #  when "application/x-mmc.title;charset=us-ascii;size=255"
          #  when "application/x-mmc.title;charset=us-ascii;size=30"
          #  when "application/x-mmc.title;charset=UTF-8;size=80"
        end
        
        case val["object-type"]
        when "audio","ringtone"
          #application/x-mmc.audio;Content-Type=audio/midi;size=25600;voices=16
          #application/x-mmc.ringtone;Content-Type=audio/x-sagem1.0;size=1000
          #application/x-mmc.ringtone;Content-Type=audio/x-sagem2.0;size=5500
          #application/x-mmc.ringtone;Content-Type=audio/x-wav;codec=pcm;samp=8000;res=16;size=200000
          #application/x-mmc.ringtone;Content-Type=audio/x-wav;codec=pcm;samp=8000;res=8,16;size=200000
          @wurfl["object_download"]["ringtone"] = true
          case val["content-type"]
          when "audio/midi","audio/mid","audio/x-midi","audio/x-mid"
            @wurfl["object_download"]["ringtone_midi_monophonic"] = true
          when "audio/imelody","audio/x-imy","text/x-iMelody","text/iMelody","text/x-imelody"
            @wurfl["object_download"]["ringtone_imelody"] = true
          else
            STDERR.puts "CcppAccept unknown download fun audio Content-Type: #{val["content-type"]}"
          end

          if val.key?("voices")
            set_value_if_greater(@wurfl["sound_format"],"voices",val["voices"].to_i)
            # determine if it has multiple voices and does midi to set 
            # the polyphonic value
            if val["voices"].to_i > 1 && val["content-type"] =~ /midi/
              @wurfl["object_download"]["ringtone_midi_polyphonic"] = true
              @wurfl["sound_format"]["midi_polyphonic"] = true
            end
          end
          if val.key?("size")
            set_value_if_greater(@wurfl["object_download"],"ringtone_df_size_limit",val["size"].to_i)
          end
          
        when "picture"
          #application/x-mmc.picture;Content-Type=image/bmp;size=25600;color=8;h=120;w=136
          #application/x-mmc.picture;Content-Type=image/bmp;size=38000;color=16M;h=96;w=128
          #application/x-mmc.picture;Content-Type=image/gif;size=16000;color=256;h=96;w=128
          #application/x-mmc.picture;Content-Type=image/vnd.wap.wbmp;size=25600;gray=1;h=120;w=136
          #application/x-mmc.picture;Content-Type=image/wbmp;size=2000;gray=1;h=96;w=128
          @wurfl["object_download"]["picture"] = true
          case val["content-type"]
          when "image/bmp","image/x-bmp"
            @wurfl["object_download"]["picture_bmp"] = true
	    #GF
          when "image/gif","image/x-gif"
            @wurfl["object_download"]["picture_gif"] = true
          when /wbmp/
            @wurfl["object_download"]["picture_wbmp"] = true
          when "image/jpeg","image/jpg"
            @wurfl["object_download"]["picture_jpg"] = true
	    #GF
          when "image/png","image/x-png"
            @wurfl["object_download"]["picture_png"] = true
          else
            STDERR.puts "CcppAccept unknown download fun picture content-type: #{val["content-type"]}"
          end

          if val.key?("gray")
            @wurfl["object_download"]["picture_greyscale"] = true
          end
          if val.key?("h")
            set_value_if_greater(@wurfl["object_download"],"picture_max_height",val["h"].to_i)
          end
          if val.key?("w")
            set_value_if_greater(@wurfl["object_download"],"picture_max_width",val["w"].to_i)
          end
          if val.key?("size")
            set_value_if_greater(@wurfl["object_download"],"picture_df_size_limit",val["size"].to_i)
          end
          if val.key?("color")
            val["color"]  = convert_download_fun_color(val["color"])
            set_value_if_greater(@wurfl["object_download"],"picture_colors",pixels_to_bits(val["color"].to_i))
          end
        when "screensaver"
          #application/x-mmc.screensaver;Content-Type=image/png;size=25600;color=8;h=120;w=136
          #application/x-mmc.screensaver;Content-Type=image/png;size=32000;color=16M;h=96;w=128
          @wurfl["object_download"]["screensaver"] = true
          case val["content-type"]
          when "image/bmp","image/x-bmp"
            @wurfl["object_download"]["screensaver_bmp"] = true
	    #GF
          when "image/gif", "image/x-gif"
            @wurfl["object_download"]["screensaver_gif"] = true
          when /wbmp/
            @wurfl["object_download"]["screensaver_wbmp"] = true
          when "image/jpeg","image/jpg"
            @wurfl["object_download"]["screensaver_jpg"] = true
	    #GF
          when "image/png","image/x-png"
            @wurfl["object_download"]["screensaver_png"] = true
          else
            STDERR.puts "CcppAccept unknown download fun screensaver content-type: #{val["content-type"]}"
          end

          if val.key?("gray")
            @wurfl["object_download"]["screensaver_greyscale"] = true
          end
          if val.key?("h")
            set_value_if_greater(@wurfl["object_download"],"screensaver_max_height",val["h"].to_i)
          end
          if val.key?("w")
            set_value_if_greater(@wurfl["object_download"],"screensaver_max_width",val["w"].to_i)
          end
          if val.key?("size")
            set_value_if_greater(@wurfl["object_download"],"screensaver_df_size_limit",val["size"].to_i)
          end
          if val.key?("color")
            val["color"]  = convert_download_fun_color(val["color"])
            set_value_if_greater(@wurfl["object_download"],"screensaver_colors",pixels_to_bits(val["color"].to_i))
          end
        when "wallpaper"
          #application/x-mmc.wallpaper;Content-Type=image/bmp;size=38000;color=16M;h=96;w=128
          #application/x-mmc.wallpaper;Content-Type=image/vnd.wap.wbmp;size=10240;gray=1;h=120;w=136
          #application/x-mmc.wallpaper;Content-Type=image/wbmp;size=2000;gray=1;h=96;w=128
          #application/x-mmc.wallpaper;type=image/bmp;size=2000;gray=1;w=101;h=64
          @wurfl["object_download"]["wallpaper"] = true
          case val["content-type"]
          when "image/bmp","image/x-bmp"
            @wurfl["object_download"]["wallpaper_bmp"] = true
	    #GF
          when "image/gif", "image/x-gif"
            @wurfl["object_download"]["wallpaper_gif"] = true
          when /wbmp/
            @wurfl["object_download"]["wallpaper_wbmp"] = true
          when "image/jpeg","image/jpg"
            @wurfl["object_download"]["wallpaper_jpg"] = true
	    #GF
          when "image/png","image/x-png"
            @wurfl["object_download"]["wallpaper_png"] = true
          else
            STDERR.puts "CcppAccept unknown download fun wallpaper content-type: #{val["content-type"]}"
          end

          if val.key?("gray")
            @wurfl["object_download"]["wallpaper_greyscale"] = true
          end
          if val.key?("h")
            set_value_if_greater(@wurfl["object_download"],"wallpaper_max_height",val["h"].to_i)
          end
          if val.key?("w")
            set_value_if_greater(@wurfl["object_download"],"wallpaper_max_width",val["w"].to_i)
          end
          if val.key?("size")
            set_value_if_greater(@wurfl["object_download"],"wallpaper_df_size_limit",val["size"].to_i)
          end
          if val.key?("color")
            val["color"]  = convert_download_fun_color(val["color"])
            set_value_if_greater(@wurfl["object_download"],"wallpaper_colors",pixels_to_bits(val["color"].to_i))
          end

        else
          STDERR.puts "CcppAccept unknown download fun accept Object-Type: #{type}"
        end
        
      when "application/x-NokiaGameData"
      when "application/x-up-alert"
      when "application/x-up-cacheop"
      when "application/x-up-device"         
      when "image/vnd.nok-wallpaper"
      when "image/vnd.wap.wml" 
      when "image/vnd.wap.wmlscript"
        # the two above seem like errors
      when "image/x-MS-bmp"
      when "image/x-up-wpng"
      when "image/x-xbitmap"
      when "text/css"
      when "text/html"
      when "text/vnd.sun.j2me.app-descriptor"
	#Andrea2005
	@wurfl["j2me"]["midp_10"] = true
      when "text/vnd.wap.wml"
      when "text/vnd.wap.wmlc"
      when "text/vnd.wap.wmlscript"
      when "text/vnd.wap.wmlscriptc"
      when "text/x-co-desc"
      when "text/x-hdml"
      when "text/xml"
      when "text/x-wap.wml"
      when "video/x-mng"
      when "image/*"
      when "*/*"	
      when "application/java","application/java-archive"
	#Andrea2005
	@wurfl["j2me"]["midp_10"] = true
	@wurfl["j2me"]["cldc_10"] = true
      when "application/wml+xml","text/wml"
	#Andrea2005
	@wurfl["markup"]["wml_1_1"] = true
      when "video/x-ms-wmv"
	#Andrea2005
	@wurfl["object_download"]["video"] = true
	@wurfl["object_download"]["video_wmv"] = true
      when "audio/amr-wb"
	#Andrea2005
	@wurfl["sound_format"]["awb"] = true
	@wurfl["object_download"]["ringtone"] = true
	# GF  (AMR implies AMR-NarrowBand)
	@wurfl["object_download"]["ringtone_amr"] = true  
	@wurfl["object_download"]["ringtone_awb"] = true
      when "audio/au", "audio/basic", "audio/bas"
	#Andrea2005; GF updated
	@wurfl["sound_format"]["au"] = true
      when "audio/aac"
	#Andrea2005
	@wurfl["sound_format"]["aac"] = true
	#GF 
	@wurfl["object_download"]["ringtone_aac"] = true
      when "video/3gpp"
	#Andrea2005
	@wurfl["object_download"]["video"] = true
	@wurfl["object_download"]["video_3gpp"] = true
	# Note: if video/3gpp  and audio/amr is ["object_download"]["video_acodec_amr"] true? 
	# Same with video/3gpp and audio/aac is ["object_download"]["video_acodec_aac"] true?
	# ZB: I will need to add some logic at the end of parsing
	# to be able to accurately set this.  This is a ToDo.
      when "video/3gpp2"
	#Andrea2005
	@wurfl["object_download"]["video"] = true
	# @wurfl["object_download"]["video_3gpp"] = true
	@wurfl["object_download"]["video_3gpp2"] = true
	#GF
      when "audio/3gpp"
	# Capture embedded audio type of video.  Create a video_acodec_3gpp capability
      when "video/mp4", "video/mp4-es", "video/mp4v-se", "video/mpeg", "video/mpeg4", "video/x-mpeg4"
	#Andrea2005; GF Updated
	@wurfl["object_download"]["video"] = true
	@wurfl["object_download"]["video_mp4"] = true
	# Note: if video/mp4  and audio/amr is ["object_download"]["video_acodec_amr"] true? 
	# Same with video/mp4 and audio/aac is ["object_download"]["video_acodec_aac"] true?
      when "video/x-mpeg4aac"
      when "video/x-mpeg4amr"
      when "image/x-epoc-mbm"
	#Andrea2005
	@wurfl["image_format"]["epoc_bmp"] = true
      else
	STDERR.puts "CcppAccept unknown accept type: #{type}"
      end
    end
  end

  def CcppAccept_Charset(element)
  end

  def CcppAccept_Encoding(element)
  end

  def CcppAccept_Language(element)
  end

  def DownloadableSoftwareSupport(element)
    #=> "bagMapping"
  end

  def JavaEnabled(element)
    #=> "j2me",
  end
  
  def JavaPlatform(element)
    items = get_items_from_bag(element)
    items.each do |platform|
      # Cheat and ignore the Versions for now
      case platform
      when /CLDC/i
	@wurfl["j2me"]["cldc_10"] = true
      when /MIDP/i
	@wurfl["j2me"]["midp_10"] = true
      when /Pjava/i
        @wurfl["j2me"]["personal_java"] = true
      else         
	STDERR.puts "JavaPlatform Mapping unknown for: #{platform}"
      end
    end
  end

  def JVMVersion(element)
  end

  def MExEClassmarks(element)
    #has some interesting possibilitesfor matching MIDP/WAP Java...
  end

  def MexeSpec(element)
  end
  
  def MexeSecureDomains(element)
  end

  def OSName(element)
  end
  
  def OSVendor(element)
  end

  def RecipientAppAgent(element)
  end

  def SoftwareNumber(element)
  end
  
  def VideoInputEncoder(element)
  end
  
  def Email_URI_Schemes(element)
  end

  def JavaPackage(element)
    STDERR.puts "JavaPackage:#{element.text}"
    # Would show the Motorola extension etc???
  end
  
  def JavaProtocol(element)
    # Perhaps details SMS support etc?
    STDERR.puts "JavaProtocol:#{element.text}"
  end

  def CLIPlatform(element)
  end

  ############### NetworkCharacteristics
  def SupportedBluetoothVersion(element)
  end

  def CurrentBearerService(element)
  end

  def SecuritySupport(element)
    items = get_items_from_bag(element)
    items.each do |secure|
      if /WTLS/.match(secure)
	#check and just assume that this means https?
	#@wurfl["security"]["https_support"] = true
      end
    end
  end

  def SupportedBearers(element)
  end

  ############### BrowserUA

  # These two can sometimes make the user agent?
  def BrowserName(element)
    @wurfl["user_agent"]<< element.text
  end

  def BrowserVersion(element)
    @wurfl["user_agent"]<< element.text
  end

  def DownloadableBrowserApps(element)
    # This might have some good information to work with
  end

  def HtmlVersion(element)
    version = element.text.to_i
    if version == 4
      @wurfl["markup"]["html_web_4_0"] = true
    elsif version < 4 && version >= 3
      @wurfl["markup"]["html_web_3_2"] = true      
    else
      STDERR.puts "HtmlVersion unknown version mapping:#{version}"
    end
  end

  def JavaAppletEnabled(element)
  end
  
  def JavaScriptEnabled(element)
  end

  def JavaScriptVersion(element)
  end

  def PreferenceForFrames(element)
  end

  def TablesCapable(element)
    value = convert_value(element.text)
    @wurfl["wml_ui"]["table_support"] = value
  end

  def XhtmlVersion(element)
    version = element.text.to_i
    if version >= 1
      if version != 1
	STDERR.puts "XhtmlVersion that might map to a new WURFL trait. Version:#{version}" 
      end
      @wurfl["markup"]["html_wi_w3_xhtmlbasic"] = true
    end
  end

  def XhtmlModules(element)
    #What does the mobile profile module look like?
    STDERR.puts "XhtmlModules items are:"
    items = get_items_from_bag(element)
    items.each do |mods|
      STDERR.puts "XhtmlModules item: #{mods}"
      if mods =~ /mobile*profile/i
	#Wow this worked?!
	@wurfl["markup"]["html_wi_oma_xhtmlmp_1_0"] = true
      elsif mods =~ /xhtml-basic10/i
	@wurfl["markup"]["html_wi_w3_xhtmlbasic"] = true	
      end
    end
  end
  
  ################# WapCharacteristics
  def SupportedPictogramSet(element)
    # There could be WAP ones, but no list?
    #=> "chtml_ui/emoji",
  end

  def WapDeviceClass(element)
  end

  def WapVersion(element)
  end

  def WmlDeckSize(element)
    @wurfl["storage"]["max_deck_size"] = element.text.to_i
  end

  def WmlScriptLibraries(element)
  end

  def WmlScriptVersion(element)
    items = get_items_from_bag(element)
    items.each do |version|
      case version.strip
      when "1.0"
	@wurfl["markup"]["wmlscript_1_0"] = true
      when "1.1"
	@wurfl["markup"]["wmlscript_1_1"] = true
      when /1\.2/i
        @wurfl["markup"]["wmlscript_1_2"] = true
      when /1\.3/i, "June/2000"
        @wurfl["markup"]["wmlscript_1_3"] = true
      else
	STDERR.puts "WmlScriptVersion unknown version mapping: #{version}"
      end
    end
  end

  def WmlVersion(element)
    items = get_items_from_bag(element)
    items.each do |version|
      case version.strip
      when "1.0"
	# It appears we do not care about this one
      when "1.1"
	@wurfl["markup"]["wml_1_1"] = true
      when "1.2"
	@wurfl["markup"]["wml_1_2"] = true
	# WML 1.2.1 appears in the WAP 1.2.1 which is WML 1.3 ???
      when "1.3", "1.2.1", "1.2.1/June 2000", "June/2000"
	@wurfl["markup"]["wml_1_3"] = true
      when "2.0"
	# Or could it be mobile profile?
	@wurfl["markup"]["html_wi_w3_xhtmlbasic"] = true
      else
	STDERR.puts "WmlVersion unknown version mapping: [#{version}]"
      end
    end
  end

  #Conversions needed on Bag
  def WtaiLibraries(element)
    items = get_items_from_bag(element)
    items.each do |lib|
      case lib
      when "WTAVoiceCall"
	@wurfl["wta"]["wta_voice_call"] = true
      when "WTANetText"
	@wurfl["wta"]["wta_net_text"] = true
      when "WTAPhoneBook"
	@wurfl["wta"]["wta_phonebook"] = true
      when "WTACallLog"
	@wurfl["wta"]["wta_call_log"] = true
      when "WTAMisc"
	@wurfl["wta"]["wta_misc"] = true
      when "WTAGSM"
	@wurfl["wta"]["wta_gsm"] = true
      when "WTAIS136"
	@wurfl["wta"]["wta_is136"] = true
      when "WTAPDC"
	@wurfl["wta"]["wta_pdc"] = true
      when "AddPBEntry"
        @wurfl["wta"]["wta_phonebook"] = true
      when "MakeCall"
        @wurfl["wta"]["nokia_voice_call"] = true
      when "WTAIGSM"
        @wurfl["wta"]["wta_gsm"] = true
      when "WTAIPublic.makeCall"
        @wurfl["wta"]["nokia_voice_call"] = true
      when "WTA.Public.addPBEntry", "WTAPublic.addPBEntry"
        @wurfl["wta"]["wta_phonebook"] = true
      when "WTA.Public.makeCall"
        @wurfl["wta"]["nokia_voice_call"] = true
      when "WTAPublic.makeCall"
        @wurfl["wta"]["nokia_voice_call"] = true
      when "SendDTMF","WTA.Public.sendDTMF"
        # Not in WURFL
      when "WTAPublic", "WTA.Public"
        # Not enough information      
      else
	STDERR.puts "WtaiLibraries unknown mapping: #{lib}"
      end
    end
  end

  def WtaVersion(element)
  end

  # add the proposals to WURFL for download methods
  def DrmClass(element)
    items = get_items_from_bag(element)
    # This is to catch the case where the DRM item is not a bag.
    items = [element.text] if items.empty?
    items.each do |drm|
      case drm
      when "ForwardLock"
	@wurfl["drm"]["oma_v_1_0_forwardlock"] = true
      when "CombinedDelivery"
	@wurfl["drm"]["oma_v_1_0_combined_delivery"] = true
      when "SeparateDelivery"
	@wurfl["drm"]["oma_v_1_0_separate_delivery"] = true
      else
	STDERR.puts "OMA DRM unknown mapping: #{drm}"
      end
    end
  end
  def DrmConstraints(element)
  end
  def OmaDownload(element)
    # "download_methods/OMAv1_download"
    if element.text =~ /yes/i
      @wurfl["object_download"]["oma_support"] = true
    end
  end
  
  ############### PushCharacteristics
  def Push_Accept(element)
    set_wap_push
    items = get_items_from_bag(element)
    items.each do |type|
      STDERR.puts "Push_Accept unknown type: #{type}"
    end
  end

  def Push_Accept_Charset(element)
    set_wap_push
    items = get_items_from_bag(items)
    items.each do |charset|     
      if charset =~ /utf8/i
	@wurfl["wap_push"]["utf8_support"] = true
      elsif charset =~ /iso8859/i
	@wurfl["wap_push"]["iso8859_support"] = true
      end
    end
  end
  def Push_Accept_Encoding(element)
    set_wap_push
  end
  def Push_Accept_Language(element)
    set_wap_push
  end
  def Push_Accept_AppID(element)
    set_wap_push
    #!! maps to confirmed and unconfirmed service indication/loads? !!
  end
  def Push_MsgSize(element)
    set_wap_push
    # Feels like the WURFL PUSH data is lacking in some items
  end
  def Push_MaxPushReq(element)
    set_wap_push
  end

  #Need MMS Mappings taken from Siemens example
  ############MmsCharacteristics
  def MmsMaxMessageSize(element)
    size = element.text.to_i
    @wurfl["mms"]["mms_max_size"] = size
  end

  def MmsMaxImageResolution(element)
    width,height = break_num_x_num(element.text)
    @wurfl["mms"]["mms_max_width"] = width
    @wurfl["mms"]["mms_max_height"] = height
  end
  
  def MmsCcppAccept(element)
    # Andrea: if we are here the device certainly can receive MMS Messages
    @wurfl["mms"]["receiver"] = true 
    # Andrea: I assume a device that can receive can also send. Only the very
    # first devices could receive but not send
    @wurfl["mms"]["sender"] = true 
    items = get_items_from_bag(element)
    items.each do |type|
      case type
      when "image/jpeg","image/jpg"
	@wurfl["mms"]["mms_jpeg_baseline"] = true 
	#what about progressive?
	# Andrea: is there any way to determine from the content type?
      when "image/gif", "image/x-gif" 
	@wurfl["mms"]["mms_gif_static"] = true
	#animated?
      when "image/vnd.wap.wbmp" 
	@wurfl["mms"]["mms_wbmp"] = true
      when "image/bmp", "image/x-bmp", "image/x-ms-bmp"
	@wurfl["mms"]["mms_bmp"] = true
      when "image/png", "image/x-png"
	@wurfl["mms"]["mms_png"] = true
      when "application/smil"
	# Need to add smil capability
      when "application/x-sms"
      when "application/vnd.3gpp.sms"
      when "application/vnd.smaf", "application/x-smaf", "audio/smaf"
	@wurfl["mms"]["mms_mmf"] = true
      when "audio/amr","audio/x-amr"
	@wurfl["mms"]["mms_amr"] = true
      when "audio/amr-wb"
	#Andrea2005
	# We should add mms_awb!
      when "audio/aac"
	#GF
	#  We should add mms_aac	     
	@wurfl["mms"]["mms_amr"] = true
      when "audio/midi","audio/mid","audio/x-midi","audio/x-mid"
	@wurfl["mms"]["mms_midi_monophonic"] = true
	# We can play it safe an say mono. what about poly?
      when "audio/sp-midi"
	@wurfl["mms"]["mms_spmidi"] = true
      when "audio/wav","audio/x-wav","application/wav","application/x-wav"
        @wurfl["mms"]["mms_wav"] = true
      when "audio/mp3", "audio/mpeg3", "audio/x-mp3", "audio/x-mpeg3","audio/mpg3"
	#Andrea2005
	@wurfl["sound_format"]["mp3"] = true
	@wurfl["object_download"]["ringtone"] = true
	@wurfl["object_download"]["ringtone_mp3"] = true
	@wurfl["mms"]["mms_mp3"] = true
      when "text/plain"
      when "text/x-vCard","text/x-vcard"
	@wurfl["mms"]["mms_vcard"] = true
      when "text/x-vCalendar","text/x-vcalendar"
	@wurfl["mms"]["mms_vcalendar"] = true
      when "application/vnd.nokia.ringing-tone"
	@wurfl["mms"]["mms_nokia_ringingtone"] = true
      when "image/vnd.nok-wallpaper"
	@wurfl["mms"]["mms_nokia_wallpaper"] = true
      when "audio/x-beatnik-rmf","audio/x-rmf","audio/rmf","audio/x-beatnik-rmf"
	@wurfl["mms"]["mms_rmf"] = true
      when "application/vnd.symbian.install"
	@wurfl["mms"]["mms_symbian_install"] = true
      when "application/java-archive","application/x-java-archive"
	@wurfl["mms"]["mms_jar"] = true
      when "text/vnd.sun.j2me.app-descriptor"
	@wurfl["mms"]["mms_jad"] = true
      when "application/vnd.wap.wmlc"
	@wurfl["mms"]["mms_wmlc"] = true
      when "application/vnd.wap.wml"
	#Andrea2005
	@wurfl["markup"]["wml_1_1"] = true
      when "audio/au", "audio/basic", "audio/bas"
	#Andrea2005; GF Updated
	# mms_au?
	@wurfl["sound_format"]["au"] = true
      when "audio/xmf", "audio/mobile-xmf"
	#Andrea2005, GF Updated
	# We should probably add mms_xmf
	@wurfl["sound_format"]["xmf"] = true
	@wurfl["object_download"]["ringtone"] = true
	@wurfl["object_download"]["ringtone_xmf"] = true
      when "video/3gpp"
	#Andrea2005
	@wurfl["object_download"]["video"] = true
	@wurfl["object_download"]["video_3gpp"] = true
	@wurfl["mms"]["mms_video"] = true
	@wurfl["mms"]["mms_3gpp"] = true
      when "video/3gpp2"
	#Andrea2005; GF Updated
	@wurfl["object_download"]["video"] = true
	# Question does 3gpp2 mean the handset will also do 3gpp?
	#@wurfl["object_download"]["video_3gpp"] = true
	@wurfl["object_download"]["video_3gpp2"] = true
	@wurfl["mms"]["mms_video"] = true
	# Same 3ggp2 question
	#@wurfl["mms"]["mms_3gpp"] = true
	@wurfl["mms"]["mms_3gpp2"] = true
	#GF
      when "video/mp4", "video/mp4-es", "video/mp4v-se", "video/mpeg", "video/mpeg4", "video/x-mpeg4"
	@wurfl["object_download"]["video"] = true
	@wurfl["object_download"]["video_mp4"] = true
	@wurfl["mms"]["mms_video"] = true
	@wurfl["mms"]["mms_mp4"] = true
	#GF
      when "audio/3gpp"
      when "application/vnd.wap.mms-message"
      when "application/vnd.wap.multipart.mixed"
      when "application/vnd.wap.multipart.related"
      else
	STDERR.puts "MmsCcppAccept unknown accept type: #{type}"
      end
    end
  end

  def MmsCcppAcceptCharset(element)
  end
  
  def MmsVersion(element)
  end

  ############### Extra Components found from running on profs
  def BluetoothProfile(element)
  end

  def FramesCapable(element)
  end

  def OSVersion(element)
  end

  def MmsCcppAcceptEncoding(element)
  end

  def MmsCcppAcceptLanguage(element)
  end

  def MmsMaxAudio(element)
  end

  def MmsMaxComponents(element)
  end

  def MmsMaxImage(element)
    # examples have Values of -1...
  end

  def MmsMaxText(element)
  end

  def WapPushMsgPriority(element)
  end

  def WapPushMsgSize(element)
  end

  def WapSupportedApplications(element)
  end


  ############## Alias to methods already defined. 
  alias :AudioInputEncorder :AudioInputEncoder
  alias :MexeClassmark :MExEClassmarks
  alias :MexeClassmarks :MExEClassmarks
  alias :MmsCcppAccept_Charset :MmsCcppAcceptCharset
  alias :MmsCcppAcceptCharSet :MmsCcppAcceptCharset
  alias :OutputCharset :OutputCharSet
  alias :PixelsAspectRatio :PixelAspectRatio
  alias :SofwareNumber :SoftwareNumber
  alias :SupportedBearer :SupportedBearers
  alias :TableCapable :TablesCapable
  alias :WmlscriptLibraries :WmlScriptLibraries
  alias :wtaVersion :WtaVersion
  

  #############################################################
  # Utility methods
  #############################################################

  def set_wap_push
    # if Push items exist then set wap_push/wap_push_support = true
    @wurfl["wap_push"]["wap_push_support"] = true
  end

  # escape the passed method name to something valid for Ruby
  def make_method_name(method)
    # should do more, but will add them as errors occur
    method.gsub(/-/,"_")
  end

  def break_num_x_num(val)
    width = height = 0
    if m = /(\d*)x(\d*)/.match(val)
      width, height = m[1],m[2]
    end
    return width.to_i,height.to_i 
  end

  def get_items_from_bag(element)
    items = Array.new
    return items if element.nil?
    element.elements.each("rdf:Bag/rdf:li") do |se|
      items<< se.text
    end    
    return items
  end

  # used to convert Yes/No to true false
  def convert_value(value)
    if value =~ /Yes/i
      return true
    elsif value =~ /No/i
      return false 
    end
    begin
      # try to convert to an integer
      return value.to_i
    rescue
    end
    # just leave it alone
    return value
  end

  def set_value_if_greater(wurflhash,key,value)
    if wurflhash.key?(key)
      if value.is_a?(Fixnum)
        if wurflhash[key] < value
          wurflhash[key] = value
        end
      else
        # Should probably just overwrite the entry then.
        STDERR.puts "set_value_if_greater called with something that is not a number.Key:#{key};Value:#{value}"
      end
    else
      # it is not set so set it
      wurflhash[key] = value
    end
  end

  def convert_download_fun_color(color)
    res = color
    if color =~ /M$/i
      # multiply it by a million
      res = color.to_i * 1000000
    elsif color =~ /K$"/i
      # multiply it by ten thousand
      res = color.to_i * 10000
    end
    return res
  end

  def parse_download_fun_accept(accept)
    #application/x-mmc.object_type;content-type=format;size=n;other=y
    m = /application\/x-mmc\.(.*);(content-)?type=(.*);size=(\d*);(.*)/i.match(accept)
    return nil if m.nil? # no match

    res = Hash.new
    res["object-type"] = m[1]
    res["content-type"] = m[3]
    res["size"] = m[4]
    if m[5]
      others = m[5].split(";")
      others.each do |keypair|
        key,value = keypair.split("=")
        res[key] = value
      end
    end

    return res
  end

  def pixels_to_bits(pixels)
    if @bits_per_pixel.nil?
      #Try to find what power of 2 it is.
      log2(pixels.to_i)
    else
      # Just assume that the handset's bits_per_pixel matches pixels.
      # If not then we need to always call the above.
      @bits_per_pixel
    end    
  end
  
  def log2(num)
    # If Ruby had a lg method, by default, I would use it instead of this hash.
    log2_idx = {
      2 => 1,      4 => 2,      8 => 3,      16 => 4,      32 => 5,
      64 => 6,      128 => 7,      256 => 8,      512 => 9,
      1024 => 10,      2048 => 11,      4096 => 12,      8192 => 13,
      16384 => 14,      32768 => 15,      65536 => 16,
      131072 => 17,      262144 => 18,      524288 => 19,
      1048576 => 20,      2097152 => 21,      4194304 => 22,
      8388608 => 23,      16777216 => 24,      33554432 => 25,
      67108864 => 26,      134217728 => 27,      268435456 => 28,
      536870912 => 29,      1073741824 => 30,      2147483648 => 31,
      4294967296 => 32,
    }
    # For now just log that the idx is not large enough...
    STDERR.puts "Unable to determine the log2 of #{num}." if !log2_idx.key?(num)
    log2_idx[num]    
  end
  
end


if $0 == __FILE__
  # The code below is called if this file is executed from the command line.

  def usage    
    puts "Usage: usaprofparser.rb uaprof_files"
    puts "No files passed to parse."
    exit 1
  end

  if ARGV.size == 0
    usage
  end

  uaprof = UAProfToWURLF.new
  
  # Parse all the files and merge them into one UAProf.
  # Following profs take precedence of previous ones
  ARGV.each do |file|
    uaprof.parse_UAProf(file)
  end

  # Now output the mapped WURFL to standard out
  uaprof.output_WURFL
  
end
