# ==============================================================================
# Function: do_cmd
# Purpose:
#     Submit a command to the system, and check for error
#
#
# ==============================================================================
#
def do_cmd(cmd, verbose=false, fake=false, logfile="")
   if (!logfile.empty?) then
      cmd = cmd + "   >> " + logfile
   end
   puts "\n>>" + cmd if verbose
   if not fake
      if !system(cmd)
         puts "! Submitted OS call returned an error. Failed command looked like this ... "
         puts "! >>#{cmd}"
         puts "! Stopping execution."
         exit 1
      end
   end
end


# ==============================================================================
# Function: match_glob_in_dir
# Purpose:
#     Check for the existence of pattern-matching files within a directory
#     ... just checking for *any* match
#
# ==============================================================================
#
def match_glob_in_dir(dirname, pattern="", return_matches=false, verbose=false)
   if ( pattern.empty? ) then
      puts "*** Error in match_glob_in_dir: Please specify a non-empty glob pattern."
      exit 1
   end
   #
   dirname = File.expand_path(dirname)
   match = false
   matching_pattern_full = File.join(dirname, pattern)
   matching_files = Dir.glob(matching_pattern_full)
   if ( verbose ) then
      puts "directory: #{dirname}"
      puts "pattern: #{pattern}"
      puts "matching_pattern_full: #{matching_pattern_full}"
      puts "matching files: #{matching_files}"
   end
   if ( matching_files.size > 0 ) then match = true end

   # return either the actual matches or a logical
   if return_matches then
      return matching_files
   else
      return match
   end
end


# ==============================================================================
# Function: set_job_status
# Purpose:
#     Set a job's status by creating a file within a given directory, with
#     ... a file extension equal to the passed status value
#
# ==============================================================================
#
def set_job_status(dirname, jobname, status, verbose=false)

   # make sure that the directory exists
   dirname = File.expand_path(dirname)
   if !File.directory?(dirname) then
      puts sprintf("*** Error in set_job_status: Passed dirname \"%s\" does not exist", dirname)
      exit 1
   end

   # OK, directory is there
   # ... now, before we write out the current status file, let's make sure that all
   # ... other status files for this job are removed
   #
   current_status = get_job_status(dirname, jobname, verbose)
   if !current_status.empty? then
      current_status_filename = File.join(dirname, jobname)
      current_status_filename = current_status_filename + '.' + current_status
      puts sprintf("set_job_status: Deleting previous status file: %s", current_status_filename) if verbose
      File.delete(current_status_filename)
   end

   # OK, now let's write out a status file
   status_filename = File.join(dirname, jobname)
   status_filename = status_filename + '.' + status
   puts status_filename if verbose
   puts sprintf("set_job_status: setting status of job %s to %s ...", jobname, status) if verbose
   puts sprintf("set_job_status: ... writing status file %s", status_filename) if verbose
   statusFile = File.new(status_filename, "w")
   statusFile.close
end


# ==============================================================================
# Function: get_job_status
# Purpose:
#     Get a job's status given a directory and jobname
#     It's expected that his function be used in concert with then
#     ... set_job_status function that stores a job's run status
#     ... as a file extension appended to the name of the job.
#
# ==============================================================================
#
def get_job_status(dirname, jobname, verbose=false)

   # make sure that the directory exists
   dirname = File.expand_path(dirname)
   if !File.directory?(dirname) then
      puts sprintf("*** Error in get_job_status: Passed dirname \"%s\" does not exist", dirname)
      exit 1
   end

   # get all file extensions for this job name provided
   match_string = jobname + '.*'
   status_filenames = match_glob_in_dir(dirname, match_string, return_matches=true, verbose)
   puts sprintf("get_job_status: %d matches found",  status_filenames.size) if verbose
   puts status_filenames if verbose

   # return extension if there is one, else an empty string
   if status_filenames.size > 0 then
      # take the first filename if multiple are returned
      job_status = File.extname(status_filenames[0])
      # remove the leading '.' from the extension name
      job_status = job_status[1,job_status.length]
      return job_status
   else
      # no match found for this jobname
      return ""
   end
end

