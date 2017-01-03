# ==============================================================================
# Function: load_beagle_settings
# Purpose:
#     Load the Loris settings, what else?
#
# ==============================================================================
#
def load_beagle_settings(settings_file, verbose=false, debug=false)
   #
   # has a nil value been passed?
   #     i.e., the LORIS_SETTINGS_FILE env var has not been set
   if ( settings_file.nil? ) then
      puts sprintf("\n*** Error: Loris environmental variable [LORIS_SETTINGS_FILE] has not been set")
      exit
   end

   # file exists?
   if ( !File.exists?(settings_file) or !File.file?(settings_file) ) then
      puts sprintf("\n*** Error: Loris settings file [%s] is not readable.", settings_file)
      exit
   end

   # OK, so file is readable.
   settings = Hash.new
   File.readlines(settings_file).each { |line|
      line = line.strip
      #
      # skip this line if a comment or if it's empty
      if ( line[0,1] == "#" or line.empty? )  then next end
      #
      var,val = line.chomp.split("=")

      # strip the double-quotes from all input strings
      # ... these are needed for R to know that they're to be read
      # ... as strings, but it messes up Ruby, who includes the
      # ... double-quotes within the strings themselves
      val = val.delete '"'
      #
      settings[var] = val
      puts(sprintf("Debug: setting %s ---> %s", var, val)) if debug
   }
   nSettings = settings.length

   # have we read the correct number of settings?
   if ( settings['NBR_SETTINGS'].nil? or settings['NBR_SETTINGS'].to_i != nSettings  ) then
      puts sprintf("*** Error: Loris settings file [%s] does not have the correct number of settings.", settings_file)
      puts sprintf("*** Expected: %d", settings['NBR_SETTINGS'].to_i)
      puts sprintf("*** Read: %d", nSettings)
      exit
   end

   # settings file is structurally valid. Let's look at it (if desired) ...
   if ( verbose ) then
      puts sprintf("\n*** Loris settings in file: %s ", settings_file)
      #
      # loop over all settings
      settings.each { |key, value|
         puts sprintf("*** SETTING: %s VALUE: %s", key, value)
      }
   end

   return settings
end





# ==============================================================================
# Function: load_beagle_runConfig
# Purpose:
#     Load the Loris run configuration values.
#     These values are different from settings in that run config values
#     are likely to change from run to run, whereas the settings will
#     be more static.
#
# ==============================================================================
#
def load_beagle_runConfig(config_file, verbose=false, debug=false)
   #
   # has a nil value been passed?
   #     i.e., the config filename has not been set
   if ( config_file.empty? ) then
      puts sprintf("\n*** Error: Fullpath to Loris run configuration file must be specified")
      exit
   end

   # file exists?
   if ( !File.exists?(config_file) or !File.file?(config_file) ) then
      puts sprintf("\n*** Error: Loris run configuration file [%s] is not readable.", config_file)
      exit
   end

   # OK, so file is readable.
   settings = Hash.new
   File.readlines(config_file).each { |line|
      line = line.strip
      #
      # skip this line if a comment or if it's empty
      if ( line[0,1] == "#" or line.empty? )  then next end
      #
      var,val = line.chomp.split("=")

      # strip the double-quotes from all input strings
      # ... these are needed for R to know that they're to be read
      # ... as strings, but it messes up Ruby, who includes the
      # ... double-quotes within the strings themselves
      val = val.delete '"'
      #
      settings[var] = val
      puts(sprintf("Debug: setting %s ---> %s", var, val)) if debug
   }
   nSettings = settings.length

   # have we read the correct number of settings?
   if ( settings['NBR_SETTINGS'].nil? or settings['NBR_SETTINGS'].to_i != nSettings  ) then
      puts sprintf("*** Error: Loris settings file [%s] does not have the correct number of settings.", config_file)
      puts sprintf("*** Expected: %d", settings['NBR_SETTINGS'].to_i)
      puts sprintf("*** Read: %d", nSettings)
      exit
   end

   # settings file is structurally valid. Let's look at it (if desired) ...
   if ( verbose ) then
      puts sprintf("\n*** Loris settings in file: %s ", config_file)
      #
      # loop over all settings
      settings.each { |key, value|
         puts sprintf("*** SETTING: %s VALUE: %s", key, value)
      }
   end

   return settings
end



# ==============================================================================
# Function: load_beagle_aggregated_settings
# Purpose:
#     Load the Loris aggregated settings.
#     Recall that these are created by the Loris run initialization
#     script and stored in the Loris output root directory.
#     Also note that, since these values have already been validated,
#     there is no need to perform much validation here.
#
#     Finally, note that the aggregated values are stored in the 
#     .json format, since both R/Ruby have no trouble reading this
#     format.
#
# ==============================================================================
#
def load_beagle_aggregated_settings(settings_file, verbose=false, debug=false)
   #
   # has a nil value been passed?
   #     i.e., the config filename has not been set
   if ( settings_file.empty? ) then
      puts sprintf("\n*** Error: Fullpath to Loris aggregate settings file must be specified")
      exit
   end

   # file exists?
   if ( !File.exists?(settings_file) or !File.file?(settings_file) ) then
      puts sprintf("\n*** Error: Loris aggregate settings file [%s] does not exist.", settings_file)
      exit
   end

   # load the settings
   f = File.open(settings_file, 'r')
   jsonStr = f.read
   settings = JSON.load(jsonStr)
   f.close

   # settings file is structurally valid. Let's look at it (if desired) ...
   if ( verbose ) then
      puts sprintf("\n*** Loris aggregate settings in file: %s ", settings_file)
      #
      # loop over all settings
      settings.each { |key, value|
         puts sprintf("*** SETTING: %s VALUE: %s", key, value)
      }
   end

   return settings
end








