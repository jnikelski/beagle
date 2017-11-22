# ==============================================================================
# Function: load_beagle_settings
# Purpose:
#     Load the Loris settings, what else?
#
# ==============================================================================
#
def civet_getFilenameClassify(civet_scan_id, settings, opt)
    #
    print ("Entering method *civet_getFilenameClassify* ...\n") if opt.debug
     
   # define the Civet-generated tissue classification volume
   civetId_dir_fullPath = File.join(settings['CIVET_ROOT_DIR'], civet_scan_id)

   if ( settings['CIVET_VERSION'] == '1.1.9') then
      civet_suffix = settings['CIVET_CLASSIFY_DISCRETE_VOLUME_SUFFIX_v9']
   else
      civet_suffix = settings['CIVET_CLASSIFY_DISCRETE_VOLUME_SUFFIX_v11']
   end
   civet_classify_volname = settings['CIVET_PREFIX'] + '_' + civet_scan_id + civet_suffix

   civet_classify_volname_fullPath = File.join(civetId_dir_fullPath, 'classify', civet_classify_volname)
   
   print ("Exiting method *civet_getFilenameClassify* ...\n")  if opt.debug
   return civet_classify_volname_fullPath

end

