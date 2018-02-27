module ConfigFileFunctions
   #
   # these libs are pointed to by the RUBYLIB env variable
   require 'beagle_civet_function_library'

   # ==============================================================================
   # Module: ConfigFileFunctions
   # Description:
   #     Contains functions common to the classes that read the various
   #     config files.
   #
   # ==============================================================================
   #

   def check_subject_info_file(info_file, nColumns)
      # Function: check_subject_info_file
      # Purpose:
      #     Loop thru a given subject info CSV file and check whether it's
      #     somewhat structurally sound, by ensuring that each line contains the
      #     required number of values.
      #
      # does the info file appear to be CSV -- check the file extension
      info_file = File.expand_path(info_file)
      info_file_ext = File.extname(info_file)
      info_file_basename = File.basename(info_file, info_file_ext)
      if ( info_file_ext != '.csv' ) then
         puts sprintf("\n*** Error: Control file [%s] needs to be in .csv format, with the appropriate file extension", info_file)
         puts opts
         exit
      end

      # file exists and is a regular file?
      if ( !File.exists?(info_file) || !File.file?(info_file) ) then
         puts sprintf("\n*** Error: The subject information file  [%s] is not readable", info_file)
         puts opts
         exit
      end

      # does each row have the expected number of fields?
      csv = File.open(info_file, 'r')
      csv.each_with_index{ |row, ndx|
         row.chomp!
         # is this a comment line? (i.e., starts with a hash?)
         next if row[0].to_s.eql?("#")

         csv_parts = row.split(',')
         #p csv_parts
         #puts sprintf("csv_parts has got %d parts", csv_parts.length)

         # end of file?
         if ( csv_parts.length ==  0 ) then break end

         if ( csv_parts.length != nColumns ) then
            puts sprintf("\n*** Error: Subject info file [%s] line %d contains incorrect number of fields.", info_file, ndx+1)
            puts sprintf("*** There should be %d fields, but I see %d", nColumns, csv_parts.length)
            puts row
            exit
         end
      }
      csv.close
   end   # check_subject_info_file()


   def select_entries_by_keyname_xxx(keynames, subject_entries)
      # Function: select_entries_by_keyname
      # Purpose:
      #     Given an array of one or more keynames, and an array of
      #     subject entries, return only the subset of entries reflecting
      #     the passed keynames.
      #

      # create new output array, then loop over all entries
      subjArray = Array.new
      subject_entries.each{ |entry|
         if ( keynames.include?(entry["keyname"]) ) then
            subjArray << entry
         end
      }
      return subjArray

   end # select_entries_by_keyname

end   # module



class TbrSubjects
   # ==============================================================================
   # Class: TbrSubjects
   # Description:
   #     Contains an array of subjects available (i.e. to be run) for processing 
   #     of some kind: anatomical, PiB, FDG, etc.
   #
   # ==============================================================================
   #
   #
   include ConfigFileFunctions
   
   # define accessors
   attr_accessor :subjectEntries

   def initialize(file_in, settings)
      print "Checking integrity of to-be-run subjects file [#{file_in}] ... " if settings.verbose
      check_subject_info_file(file_in, 1)
      puts "OK" if settings.verbose
      
      print "Loading file ... " if settings.verbose
      self.load_from_file(file_in)
      puts "OK" if settings.verbose
      
   end

   def load_from_file(file_in)
      #
      # return: 
      #     @subjectEntries:     an array of subject names
      #

      # define the return Array
      @subjectEntries = Array.new
      
      # Next, loop thru the subjects file
      csv = File.open(file_in, 'r')
      csv.each{ |row|

         # remove EOL and deal with a possible empty line
         row.strip!
         if ( row.empty? or row.length == 0 ) then next end

         # is this a comment line? (i.e., starts with a hash?)
         if ( row[0,1].to_s.eql?("#") ) then next end

         # add subject to array
         @subjectEntries << row
      }

      # done
      csv.close()
      
   end   # load_from_file()

end   # class



class FdgSubjectDetails
   # ==============================================================================
   # Class: FdgSubjectDetails
   # Description:
   #     Contains an array of subject detail entries.
   #
   # ==============================================================================
   #
   include ConfigFileFunctions

   # define accessors
   attr_accessor :subjectEntries

   def initialize(file_in, opt, settings)
      print "\nChecking integrity of FDG config file [#{file_in}] ... " if opt.verbose
      check_subject_info_file(file_in, 4)
      puts "OK" if opt.verbose
      
      print "Loading file #{file_in} ... " if opt.verbose
      self.load_from_file(file_in, opt, settings)
      puts "OK" if opt.verbose
      
   end


   def load_from_file(file_in, opt, settings)
      #
      # return: 
      #     @subjectEntries:     an array of subject names
      #
      
      # define the return Array
      @subjectEntries = Array.new
      
      # loop over all lines in the file
      csv = File.open(file_in, 'r')
      csv.each_with_index{ |row, ndx|
         #
         # parse the line; if end-of-file?, break out
         entry = parse_subject_line(row, opt, settings)
         if ( entry["keyname"] ==  "eof" ) then break end
      
         # skip over comments
         if ( entry["keyname"] == "comment_line") then next end
         
         # looks OK; add entry to array
         @subjectEntries << entry

      }
      csv.close

   end


   def parse_subject_line(line_in, opt, settings)
   # ==============================================================================
   # Function: parse_fdg_subject_line
   # Purpose:
   #     Given a line read from the FDG subject info file, parse it and then
   #     return a hash containing:
   #
   #     keyname, scanId, scanDate, dicomOrEcat, scanFileLocation, civetScanId, civetScanDate
   #
   # Input line:
   #  field 1: keyname
   #  field 2: unique FDG scan-id
   #  field 3: Ecat/Dicom identifier and scan filename
   #  field 4: unique Civet scan-id ... usually a date
   #
   # Example:
   #  brynhild,brynhild-20100225,dicom;Dicom_PET,20100806
   #
   # ==============================================================================
   #

      # define the return Hash
      values = Hash.new
      
      # remove EOL and then split by comma
      # ... also deal with a possible empty line
      line_in.strip!
      if ( line_in.empty? or line_in.length == 0 ) then
         values["keyname"] = "comment_line"
         return values
      end
      csv_parts = line_in.split(',')

      # is this a comment line? (i.e., starts with a hash?)
      if csv_parts[0][0,1].to_s.eql?("#") then
         values["keyname"] = "comment_line"
         return values
      end

      # get contents of the 4 fields
      field_1 = csv_parts[0]
      field_2 = csv_parts[1]
      field_3 = csv_parts[2]
      field_4 = csv_parts[3]

      # fields 1,2,4 can be stored directly
      values["keyname"] = field_1
      values["scanDate"] = field_2
      values["civetScanDate"] = field_4
      values["civetScanDirectoryName"] = civet_getScanDirectoryName(values["keyname"], values["civetScanDate"], settings, opt, fullpath=false, checkExistence=false)
      
      # field 3 contains 2 subfields with a ";" separator:
      #     subfield 1: "ecat" or "dicom"
      #     subfield 2: ecat_filename (if an ecat file) or dicom_directory_name (if dicom) 
      field_3_parts = field_3.split(';')
      values["dicomOrEcat"] = field_3_parts[0]
      values["scanFileLocation"] = field_3_parts[1]

      # done. Return the extracted values
      return values

   end   # parse_subject_line()


   def select_entries_by_keyname(keynames)
      select_entries_by_keyname_xxx(keynames, @subjectEntries)
   end

end   # class FdgSubjectDetails







class PiBSubjectDetails
   # ==============================================================================
   # Class: PiBSubjectDetails
   # Description:
   #     Contains an array of subject detail entries.
   #
   # ==============================================================================
   #
   #
   include ConfigFileFunctions
   
   # define accessors
   attr_accessor :subjectEntries

   def initialize(file_in, opt, settings)
      print "\nChecking integrity of PiB config file [#{file_in}] ... " if opt.verbose
      check_subject_info_file(file_in, 4)
      puts "OK" if opt.verbose
      
      print "Loading file #{file_in} ... " if opt.verbose
      self.load_from_file(file_in, opt, settings)
      puts "OK" if opt.verbose
      
   end


   def load_from_file(file_in, opt, settings)
      #
      # return: 
      #     @subjectEntries:     an array of subject names
      #
      
      # define the return Array
      @subjectEntries = Array.new
      
      # loop over all lines in the file
      csv = File.open(file_in, 'r')
      csv.each_with_index{ |row, ndx|
         #
         # parse the line; if end-of-file?, break out
         entry = parse_subject_line(row, opt, settings)
         if ( entry["keyname"] ==  "eof" ) then break end
      
         # skip over comments
         if ( entry["keyname"] == "comment_line") then next end
         
         # looks OK; add entry to array
         @subjectEntries << entry

      }
      csv.close

   end


   def parse_subject_line(line_in, opt, settings)
   # ==============================================================================
   # Function: parse_subject_line
   # Purpose:
   #     Given a line read from the PiB subject info file, parse it and then
   #     return a hash containing:
   #
   #     keyname, scanId, scanDate, ecatFilename, civetScanId, civetScanDate
   #
   # Input line:
   #  field 1: keyname
   #  field 2: unique PiB scan-id
   #  field 3: Ecat scan filename
   #  field 4: unique Civet scan-id ... usually a date
   #
   # Example:
   #  brynhild,brynhild-20101030,Archambault_Gilles_20f8_14349_de7.v,brynhild-20100806
   #
   # ==============================================================================
   #

      # define the return Hash
      values = Hash.new
      
      # remove EOL and then split by comma
      # ... also deal with a possible empty line
      line_in.strip!
      if ( line_in.empty? or line_in.length == 0 ) then
         values["keyname"] = "comment_line"
         return values
      end
      csv_parts = line_in.split(',')

      # is this a comment line? (i.e., starts with a hash?)
      if csv_parts[0][0,1].to_s.eql?("#") then
         values["keyname"] = "comment_line"
         return values
      end

      # all fields can be stored directly
      values["keyname"] = csv_parts[0]
      values["scanDate"] = csv_parts[1]
      values["ecatFilename"] = csv_parts[2]
      values["civetScanDate"] = csv_parts[3]
      values["civetScanDirectoryName"] = civet_getScanDirectoryName(values["keyname"], values["civetScanDate"], settings, opt, fullpath=false, checkExistence=false)
      

      # done. Return the extracted values
      return values

   end   # parse_subject_line()


   def select_entries_by_keyname(keynames)
      select_entries_by_keyname_xxx(keynames, @subjectEntries)
   end

end   # class PiBSubjectDetails




class CivetSubjectDetails
   # ==============================================================================
   # Class: CivetSubjectDetails
   # Description:
   #     Contains an array of subject detail entries.
   #
   # ==============================================================================
   #
   #
   include ConfigFileFunctions
   
   # define accessors
   attr_accessor :subjectEntries

   def initialize(file_in, opt, settings)
      print "\nChecking integrity of Civet config file [#{file_in}] ... " if opt.verbose
      check_subject_info_file(file_in, 2)
      puts "OK" if opt.verbose
      
      print "Loading file #{file_in} ... " if opt.verbose
      self.load_from_file(file_in, opt, settings)
      puts "OK" if opt.verbose
      
   end


   def load_from_file(file_in, opt, settings)
      #
      # return: 
      #     @subjectEntries:     an array of subject names
      #
      
      # define the return Array
      @subjectEntries = Array.new
      
      # loop over all lines in the file
      csv = File.open(file_in, 'r')
      csv.each_with_index{ |row, ndx|
         #
         # parse the line; if end-of-file?, break out
         entry = parse_subject_line(row, opt, settings)
         if ( entry["keyname"] ==  "eof" ) then break end
      
         # skip over comments
         if ( entry["keyname"] == "comment_line") then next end
         
         # looks OK; add entry to array
         @subjectEntries << entry

      }
      csv.close

   end


   def parse_subject_line(line_in, opt, settings)
   # ==============================================================================
   # Function: parse_subject_line
   # Purpose:
   #     Given a line read from the Civet subject info file, parse it and then
   #     return a hash containing:
   #
   #     keyname, scan identifier
   #
   # Input line:
   #  field 1: keyname
   #  field 2: unique (within keyname) Civet scan-id (e.g., scan date, etc)
   #
   # Example:
   #  brynhild,20100806
   #
   # ==============================================================================
   #
      #print "\n*** in method parse_subject_line ... \n" if opt.debug
      
      # define the return Hash
      values = Hash.new
      
      # remove EOL and then split by comma
      # ... also deal with a possible empty line
      line_in.strip!
      if ( line_in.empty? or line_in.length == 0 ) then
         values["keyname"] = "comment_line"
         return values
      end
      csv_parts = line_in.split(',')

      # is this a comment line? (i.e., starts with a hash?)
      if csv_parts[0][0,1].to_s.eql?("#") then
         values["keyname"] = "comment_line"
         return values
      end

      # get contents of the 2 fields
      values["keyname"] = csv_parts[0]
      values["civetScanDate"] = csv_parts[1]
      values["civetScanDirectoryName"] = civet_getScanDirectoryName(values["keyname"], values["civetScanDate"], settings, opt, fullpath=false, checkExistence=false)
      
      # done. Return the extracted values
      return values

   end   # parse_subject_line()


   def select_entries_by_keyname(keynames)
      select_entries_by_keyname_xxx(keynames, @subjectEntries)
   end

end   # class CivetSubjectDetails






