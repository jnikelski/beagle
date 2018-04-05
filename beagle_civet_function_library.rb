# ==============================================================================
# Function: Library of functions to simplify accessing Civet files
# Purpose:
#     This library basically replicates the functions found in the rmincIO
#     R package (civet.R file).
#
# Args:
#     civet_keyname: subject keyname, as specified in the subject config file
#     civet_scanid: unique scan identifier -- often a date. Combined with the keyname to create civetScanDirectoryName
#     settings: Aggregated Beagle settings
#     opt: commandline options (e.g., verbose, debug, fake, etc)
#     checkExistence: Test whether the requested file/directory actually exists. This requires zugriff to the filesystem
#     resample: Whether to use resampled surfaces
#     inverted: Whether to use inverted xfm files
#
# Note 1: 
#     While the function names are mostly the same as the R counterparts,
#     the passed arguments have been changed to be more useful and 
#     specific to execution within the Beagle pipeline.
#
# Note 2:
#     R functions for which we have not yet created equivalents, because they involve much more complicated processing.
#     Prolley best to write an R script to call these, if needed
#     1. civet.readCivetDatFiles
#     2. civet.computeStxTissueVolumes
#     3. civet.computeNativeToStxRescalingFactor
#     4. civet.computeNativeTissueVolumes
#
# Function signatures by Civet directory:
#
# assorted useful functions
#rx = civet_getCivetRootDirectoryName(settings:, opt:, checkExistence:true)
#rx = civet_getScanDirectoryName(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:false, checkExistence:false)
#rx = civet_checkVersion(civet_version:, opt:)
#
#
# file/directory access functions
#
# /classify
#rx = civet_getDirnameClassify(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getFilenameClassify(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#rx = civet_getFilenameGrayMatterPve(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#rx = civet_getFilenameWhiteMatterPve(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#rx = civet_getFilenameCsfPve(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#
# /final
#rx = civet_getDirnameFinal(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getFilenameStxT1(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#
# /mask
#rx = civet_getDirnameMask(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getFilenameCerebrumMask(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#rx = civet_getFilenameSkullMask(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#
# /native
#rx = civet_getDirnameNative(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getFilenameNative(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#rx = civet_getFilenameNativeNUC(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#rx = civet_getFilenameSkullMaskNative(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#
# /surfaces
#rx = civet_getDirnameSurfaces(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rxLh, rxRh = civet_getFilenameGrayMatterSurfaces(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:true)
#rxLh, rxRh = civet_getFilenameWhiteMatterSurfaces(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:true)
#rxLh, rxRh = civet_getFilenameMidSurfaces(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:true)
#
# /thickness
#rx = civet_getDirnameThickness(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rxLh, rxRh = civet_getFilenameCorticalThickness(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:true)
#rxLh, rxRh = civet_getFilenameMeanSurfaceCurvature(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:true)
#
# /transforms/linear   & /transforms/nonlinear
#rx = civet_getDirnameTransforms(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getDirnameTransformsLinear(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getDirnameTransformsNonlinear(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getFilenameLinearTransform(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
#rxLh, rxRh = civet_getFilenameNonlinearTransform(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, inverted:false)
#
# assorted Civet directories
#rx = civet_getDirnameLogs(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getDirnameNative(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getDirnameVBM(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#rx = civet_getDirnameVerify(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
#
# Typical uses:
# [a]
#if !floopy=civet_getFilenameGrayMatterPve(civet_keyname:"zulu", civet_scanid:"20070703xxx", settings:settings, opt:opt, checkExistence:true) then
#   puts 'The file read DID NOT work!!!'
#   puts "And the result is: #{floopy}"
#   exit
#end
#puts "Fall through case: floppy value: #{floopy}"
#
# typical use case [b] -- much shorter, with no additional error messages ... just an exit
#if !civet_classify_volname_fullPath=civet_getFilenameGrayMatterPve(civet_keyname:"zulu", civet_scanid:"20070703xxx", settings:settings, opt:opt, checkExistence:true) then exit end
#
# ==============================================================================
#

def civet_checkVersion(civet_version:, opt:)
    #
    print ("Entering method *civet_checkVersion* ...\n") if opt.debug
    
    versions = ["1.1.7", "1.1.9", "1.1.11"]
    if !versions.include?(civet_version) then
        sprintf("This function has not been tested with Civet version %s. Use at your own risk.", civet_version)
    end
    #
    print ("Exiting method *civet_checkVersion* ...\n") if opt.debug
end


def civet_getCivetRootDirectoryName(settings:, opt:, checkExistence:true)
   #
   print ("Entering method *civet_getCivetRootDirectoryName* ...\n") if opt.debug

   civetScanDirname = settings['CIVET_ROOT_DIR']

   # check for file existence if requested
   if ( checkExistence ) then
      if ( !File.exists?(civetScanDirname) ) then
         puts sprintf("\n*** Error: Required directory does not exist\n")
         puts sprintf("*********: Fullpath of directory: [%s]\n\n", civetScanDirname)
         civetScanDirname = false
      end
   end

   print ("Exiting method *civet_getCivetRootDirectoryName* ...\n") if opt.debug
   return civetScanDirname
end


def civet_getScanDirectoryName(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:false, checkExistence:false)
   #
   print ("Entering method *civet_getScanDirectoryName* ...\n") if opt.debug

   # allow for the naming of the Civet output directories in 2 different ways:
   # 1. just the subjects keyname [e.g. 0640-F-NC -- used in the ADNI output]
   # 2. subject keyname and scan identifier (usually scan date) [e.g. AF008-20141027]
   if ( settings['CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME'] == 'ON' ) then
      civetScanDirname = civet_keyname + '-' + civet_scanid
   else
      civetScanDirname = civet_keyname
   end

   if fullpath then
      civetScanDirname = File.join(settings['CIVET_ROOT_DIR'], civetScanDirname)
   end

   # check for file existence if requested
   if ( checkExistence && fullpath) then
      if ( !File.exists?(civetScanDirname) ) then
         puts sprintf("\n*** Error: Required directory does not exist\n")
         puts sprintf("*********: Fullpath of directory: [%s]\n\n", civetScanDirname)
         civetScanDirname = false
      end
   end

   print ("Exiting method *civet_getScanDirectoryName* ...\n") if opt.debug
   return civetScanDirname
end


def civet_getFilename(civet_keyname:, civet_scanid:, civet_subdir:, civet_suffix:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("civet_getFilename() -->Start ...\n") if opt.debug
   
   # validated version of Civet?
   civet_checkVersion(civet_version:settings['CIVET_VERSION'], opt:opt)

   # get the scan's directory name (not the fullpath, unless explicitly requested)
   civet_scan_dirname = civet_getScanDirectoryName(civet_keyname:civet_keyname, civet_scanid:civet_scanid, settings:settings, opt:opt, fullpath:false, checkExistence:false)
   civet_scan_dirname_fullpath = civet_getScanDirectoryName(civet_keyname:civet_keyname, civet_scanid:civet_scanid, settings:settings, opt:opt, fullpath:true, checkExistence:false)

   # define the Civet-generated  volume name
   civet_volname = settings['CIVET_PREFIX'] + '_' + civet_scan_dirname + civet_suffix

   # construct a full path name
   civet_volname_fullPath = File.join(civet_scan_dirname_fullpath, civet_subdir, civet_volname)
   
   # check for file existence if requested
   if ( checkExistence ) then
      print "Checking existence ..." if opt.debug
      if ( !File.exists?(civet_volname_fullPath) ) then
         puts sprintf("\n*** Error: Required volume does not exist\n")
         puts sprintf("*********: Fullpath filename: [%s]\n\n", civet_volname_fullPath)
         civet_volname_fullPath = false
      end
      msg = civet_volname_fullPath ? "EXISTS" : "DOES NOT EXIST"
      puts msg if opt.debug
   end

   # if we pass the existence check, return fullpath or not (as requested)
   if civet_volname_fullPath then
      civet_volname_rtn = fullpath ? civet_volname_fullPath : civet_volname
   else
      civet_volname_rtn = false
   end

   print ("civet_getFilename(): Returning result: #{civet_volname_rtn} \n")  if opt.debug
   print ("civet_getFilename() -->Exit ...\n") if opt.debug
   
   # we ruturn either the full filename or Boolean false if file does not exist
   return civet_volname_rtn
end


def civet_getFilenameClassify(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("Entering method *civet_getFilenameClassify* ...\n") if opt.debug
   civet_subdir = 'classify'

   # there was a name change in the name of the classify volume, *after* 
   # Civet version 1.1.9 -- so, construct the name according to the specified version
   if ( settings['CIVET_VERSION'] == '1.1.9') then
      civet_suffix = '_classify.mnc'
   else
      civet_suffix = '_pve_classify.mnc'
   end

   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameClassify* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameGrayMatterPve(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("Entering method *civet_getFilenameGrayMatterPve* ...\n")  if opt.debug
   civet_subdir = 'classify'
   civet_suffix = '_pve_gm.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameGrayMatterPve* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameWhiteMatterPve(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("Entering method *getFilenameWhiteMatterPve* ...\n")  if opt.debug
   civet_subdir = 'classify'
   civet_suffix = '_pve_wm.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *getFilenameWhiteMatterPve* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameCsfPve(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("Entering method *civet_getFilenameCsfPve* ...\n")  if opt.debug
   civet_subdir = 'classify'
   civet_suffix = '_pve_csf.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameCsfPve* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameStxT1(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("Entering method *civet_getFilenameStxT1* ...\n")  if opt.debug
   civet_subdir = 'final'
   civet_suffix = '_t1_final.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameStxT1* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameCerebrumMask(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   # Note: The brain mask does NOT include the cerebellum
   print ("Entering method *civet_getFilenameCerebrumMask* ...\n")  if opt.debug
   civet_subdir = 'mask'
   civet_suffix = '_brain_mask.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameCerebrumMask* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameSkullMask(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   # Note: The skull mask DOES include the cerebellum
   print ("Entering method *civet_getFilenameSkullMask* ...\n")  if opt.debug
   civet_subdir = 'mask'
   civet_suffix = '_skull_mask.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameSkullMask* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameNative(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("Entering method *civet_getFilenameNative* ...\n")  if opt.debug
   civet_subdir = 'native'
   civet_suffix = '_t1.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameNative* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameNativeNUC(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("Entering method *civet_getFilenameNative* ...\n")  if opt.debug
   civet_subdir = 'native'
   civet_suffix = '_t1_nuc.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameNative* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameSkullMaskNative(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   # Note: The skull mask DOES include the cerebellum
   print ("Entering method *civet_getFilenameSkullMaskNative* ...\n")  if opt.debug
   civet_subdir = 'mask'
   civet_suffix = '_skull_mask_native.mnc'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameSkullMaskNative* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameGrayMatterSurfaces(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:)
   print ("Entering method *civet_getFilenameGrayMatterSurfaces* ...\n")  if opt.debug
   civet_subdir = 'surfaces'
   civet_suffix = '_gray_surface'

   # if rsl requested, append to suffix
   rsl = resampled ? '_rsl' : ''

   # get LH/RH surfaces
   civet_suffix_lh = civet_suffix + rsl + '_left' + '_81920.obj'
   rxLh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_lh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   #
   civet_suffix_rh = civet_suffix + rsl + '_right' + '_81920.obj'
   rxRh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_rh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   
   print ("Exiting method *civet_getFilenameGrayMatterSurfaces* ...\n")  if opt.debug
   return [rxLh, rxRh]
end   


def civet_getFilenameWhiteMatterSurfaces(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:)
   print ("Entering method *civet_getFilenameWhiteMatterSurfaces* ...\n")  if opt.debug
   civet_subdir = 'surfaces'
   civet_suffix = '_white_surface'
   
   # if rsl requested, append to suffix
   rsl = resampled ? '_rsl' : ''

   # get LH/RH surfaces
   civet_suffix_lh = civet_suffix + rsl + '_left' + '_calibrated_81920.obj'
   rxLh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_lh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   #
   civet_suffix_rh = civet_suffix + rsl + '_right' + '_calibrated_81920.obj'
   rxRh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_rh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)

   print ("Exiting method *civet_getFilenameWhiteMatterSurfaces* ...\n")  if opt.debug
   return [rxLh, rxRh]
end   


def civet_getFilenameMidSurfaces(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:)
   print ("Entering method *civet_getFilenameMidSurfaces* ...\n")  if opt.debug
   civet_subdir = 'surfaces'
   civet_suffix = '_mid_surface'

   # if rsl requested, append to suffix
   rsl = resampled ? '_rsl' : ''

   # get LH/RH surfaces
   civet_suffix_lh = civet_suffix + rsl + '_left' + '_81920.obj'
   rxLh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_lh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   #
   civet_suffix_rh = civet_suffix + rsl + '_right' + '_81920.obj'
   rxRh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_rh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)

   print ("Exiting method *civet_getFilenameMidSurfaces* ...\n")  if opt.debug
   return [rxLh, rxRh]
end   


def civet_getFilenameCorticalThickness(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:)
   print ("Entering method *civet_getFilenameCorticalThickness* ...\n")  if opt.debug
   civet_subdir = 'thickness'
   civet_suffix = '_native_rms'

   # if rsl requested, append to suffix
   rsl = resampled ? '_rsl' : ''
   
   # get LH/RH surfaces
   civet_suffix_lh = civet_suffix + rsl + '_tlink_20mm_left.txt'
   rxLh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_lh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   #
   civet_suffix_rh = civet_suffix + rsl + '_tlink_20mm_right.txt'
   rxRh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_rh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)

   print ("Exiting method *civet_getFilenameCorticalThickness* ...\n")  if opt.debug
   return [rxLh, rxRh]
   end   
   

def civet_getFilenameMeanSurfaceCurvature(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, resampled:)
   # Note: These files do not appear to exist in Civet > 1.1.9
   print ("Entering method *civet_getFilenameMeanSurfaceCurvature* ...\n")  if opt.debug
   civet_subdir = 'thickness'
   civet_suffix = '_native_mc'

   # if rsl requested, append to suffix
   rsl = resampled ? '_rsl' : ''
   
   # get LH/RH surfaces
   civet_suffix_lh = civet_suffix + rsl + '_20mm_left.txt'
   rxLh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_lh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   #
   civet_suffix_rh = civet_suffix + rsl + '_20mm_right.txt'
   rxRh = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_rh, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)

   print ("Exiting method *civet_getFilenameMeanSurfaceCurvature* ...\n")  if opt.debug
   return [rxLh, rxRh]
end   
   

def civet_getFilenameLinearTransform(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true)
   print ("Entering method *civet_getFilenameLinearTransform* ...\n")  if opt.debug
   civet_subdir = 'transforms/linear'
   civet_suffix = '_t1_tal.xfm'
   rx = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   print ("Exiting method *civet_getFilenameLinearTransform* ...\n")  if opt.debug
   return rx
end   


def civet_getFilenameNonlinearTransform(civet_keyname:, civet_scanid:, settings:, opt:, fullpath:true, checkExistence:true, inverted:false)
   # Note: The inverted xfm/grid files don't appear to exist in  Civet > 1.1.9
   print ("Entering method *civet_getFilenameNonlinearTransform* ...\n")  if opt.debug
   civet_subdir = 'transforms/nonlinear'

   civet_suffix_xfm = inverted ? '_nlfit_invert.xfm' : '_nlfit_It.xfm'
   rxXfm = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_xfm, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   

   civet_suffix_grid = inverted ? '_nlfit_invert_grid_0.mnc' : '_nlfit_It_grid_0.mnc'
   rxGrid = civet_getFilename(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, civet_suffix:civet_suffix_grid, settings:settings, opt:opt, fullpath:fullpath, checkExistence:checkExistence)
   
   print ("Exiting method *civet_getFilenameNonlinearTransform* ...\n")  if opt.debug
   return [rxXfm, rxGrid]
end   



# define methods to return Civet directory names
def civet_getDirname(civet_keyname:, civet_scanid:, civet_subdir:, settings:, opt:, checkExistence:true)
   #
   print ("Entering method *civet_getDirname* ...\n") if opt.debug
   
   # validated version of Civet?
   civet_checkVersion(civet_version:settings['CIVET_VERSION'], opt:opt)
   
   # allow for the naming of the Civet output directories in 2 different ways:
   # 1. just the subjects keyname [e.g. 0640-F-NC -- used in the ADNI output]
   # 2. subject keyname and scan identifier (usually scan date) [e.g. AF008-20141027]
   if ( settings['CIVET_SCANID_APPEND_SCANDATE_TO_KEYNAME'] == 'ON' ) then
      civetScanDirname = civet_keyname + '-' + civet_scanid
   else
      civetScanDirname = civet_keyname
   end

  # construct the fullpath to the Civet subdir of interest
  civetDir_fullPath = File.join(settings['CIVET_ROOT_DIR'], civetScanDirname, civet_subdir)
  
  # check for file existence if requested
  if ( checkExistence ) then
     if ( !File.exists?(civetDir_fullPath) ) then
        puts sprintf("\n*** Error: Requested Civet path does not exist\n")
        puts sprintf("*********: Fullpath of dir name: [%s]\n\n", civetDir_fullPath)
        civetDir_fullPath = false
     end
  end
  print ("Returning result: #{civetDir_fullPath} \n")  if opt.debug

  print ("Exiting method *civet_getDirname* ...\n")  if opt.debug
  # we ruturn either the full filename or Boolean false if file does not exist
  return civetDir_fullPath
end


def civet_getDirnameClassify(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameClassify* ...\n")  if opt.debug
   civet_subdir = 'classify'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameClassify* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameFinal(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameFinal* ...\n")  if opt.debug
   civet_subdir = 'final'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameFinal* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameLogs(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameLogs* ...\n")  if opt.debug
   civet_subdir = 'logs'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameLogs* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameMask(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameMask* ...\n")  if opt.debug
   civet_subdir = 'mask'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameMask* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameNative(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameNative* ...\n")  if opt.debug
   civet_subdir = 'native'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameNative* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameSurfaces(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameSurfaces* ...\n")  if opt.debug
   civet_subdir = 'surfaces'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameSurfaces* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameThickness(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameThickness* ...\n")  if opt.debug
   civet_subdir = 'thickness'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameThickness* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameTransforms(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameTransforms* ...\n")  if opt.debug
   civet_subdir = 'transforms'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameTransforms* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameTransformsLinear(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameTransformsLinear* ...\n")  if opt.debug
   civet_subdir = 'transforms/linear'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameTransformsLinear* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameTransformsNonlinear(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameTransformsNonlinear* ...\n")  if opt.debug
   civet_subdir = 'transforms/nonlinear'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameTransformsNonlinear* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameVBM(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameVBM* ...\n")  if opt.debug
   civet_subdir = 'VBM'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameVBM* ...\n")  if opt.debug
   return rx
end   

def civet_getDirnameVerify(civet_keyname:, civet_scanid:, settings:, opt:, checkExistence:true)
   print ("Entering method *civet_getDirnameVerify* ...\n")  if opt.debug
   civet_subdir = 'verify'
   rx = civet_getDirname(civet_keyname:civet_keyname, civet_scanid:civet_scanid, civet_subdir:civet_subdir, settings:settings, opt:opt, checkExistence:checkExistence)
   print ("Exiting method *civet_getDirnameVerify* ...\n")  if opt.debug
   return rx
end   

