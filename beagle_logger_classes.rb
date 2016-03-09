module LoggerFunctions
   # ==============================================================================
   # Module: ConfigFileFunctions
   # Description:
   #     Contains functions common to the classes that read the various
   #     config files.
   #
   # ==============================================================================
   #

   def dummy(dArg)
      # Function: 
      # Purpose:
      #     Provide common methods, shared across classes.
      #
      dummy = "dummy"
   end   # dummy()

end   # module



class BeagleLogger
   # ==============================================================================
   # Class: BeagleLogger
   # Description:
   #     Define a Beagle logging class.
   #
   # ==============================================================================
   #
   #
   include LoggerFunctions
   
   # define accessors
   attr_accessor :log_entries

   def initialize(keyname, settings, eraseLog=false)
      #
      @keyname = keyname

      # create the filename for the logfile
      @filename = settings['LORIS_LOGFILE_PREFIX'] + "_run-" + settings['LORIS_RUN_IDENTIFIER'] + settings['LORIS_LOGFILE_EXTENSION']
      @filename_fullpath = File.join(settings['LORIS_ROOT_DIR'], @keyname, @filename)
      
      # hash used to store log entries
      @log_entries = nil
      
      # create an empty logfile (unless asked not to)
      if ( eraseLog || !File.exists?(@filename_fullpath) ) then
         create_logFile()
      else
         load_from_file()
      end
      
   end

      
   def create_logFile()
      #
      # write out an empty hash to the new json file
      File.open(@filename_fullpath, 'w') {|f| f.write(JSON.dump(Hash.new)); f.close}
      @log_entries = Hash.new
   end


   def load_from_file()
      #
      f = File.open(@filename_fullpath, 'r')
      jsonStr = f.read
      @log_entries = JSON.load(jsonStr)
      f.close
   end


   def save_to_file()
      #
      File.open(@filename_fullpath, 'w') {|f| f.write(JSON.dump(@log_entries)); f.close}
   end


   def log_message(progname, keyname, modality, scanDate, key, message)
      # eg., log_message('loris_run_initialization', keyname, 'NULL', 'NULL', 'init_message', 'Log file initialized')
      #        log_message(progname, opt.keyname, 'FDG', fdgScan_scanDate, 'civet_version', CIVET_VERSION)
      #
      full_key = progname + '|' + keyname + '|' + modality + '|' + scanDate + '|' + key
      @log_entries[full_key] = message
   end


   def log_start_message(progname, keyname, modality, scanDate)
      #
      # Note: message key = 'start_timestamp'
      full_key = progname + '|' + keyname + '|' + modality + '|' + scanDate + '|' + 'start_timestamp'
      @log_entries[full_key] = Time.new.strftime("%Y.%m.%d %H:%M:%S")
   end


   def log_stop_message(progname, keyname, modality, scanDate)
      #
      # Note: message key = 'stop_timestamp'
      full_key = progname + '|' + keyname + '|' + modality + '|' + scanDate + '|' + 'stop_timestamp'
      @log_entries[full_key] = Time.new.strftime("%Y.%m.%d %H:%M:%S")
   end


end   # class










