#!/usr/bin/env ruby
# ==============================================================================
# Purpose:
#     This script is used in the devel process to test bits of code,
#  such as functions, etc.
# ==============================================================================

#require 'optparse'
require 'ostruct'
#require 'pathname'
require 'fileutils'
#require 'tmpdir'            # needed for Dir::tmpdir

# load ruby gems
#require 'rubygems'
#require 'json'
#require 'pp'

# these libs are pointed to by the RUBYLIB env variable
#require 'hclab_function_library'
require 'beagle_function_library'
require 'beagle_civet_function_library'
#require 'beagle_configFile_classes'
#require 'beagle_build_run_commands'

# setup the opt packet with whatever we need for this test
opt                     = OpenStruct.new{}   # store input options
opt.verbose             = false
opt.debug               = true
opt.fake                = false
opt.settingsFile        = "/home/jnikelski/exported_home/devel/beagle-git/main/beagle_pipeline.settings"
opt.runConfigFile       = ""

# print the Ruby version
puts "Ruby version: #{RUBY_VERSION}" if opt.debug

# configuration file processing
   #
   # run configuration file has been entered?
   if ( opt.settingsFile.empty? ) then
    puts "\n*** Error: Fullpath to Beagle settings file must be specified"
    puts opts
    exit
 end


 # read both the permanent settings file and the run configuration
 # file, and then merge them
 # ... load the Loris settings
 settings = load_beagle_settings(opt.settingsFile, verbose=opt.verbose)



## run the test
#params = {civet_keyname:"0139-F-AD", civet_scanid:"00000000", settings:settings, opt:opt, fullpath:true, checkExistence:true}
#params = {civet_keyname:"sinbad", civet_scanid:"20030729", settings:settings, opt:opt, fullpath:true, checkExistence:true}

#rx =  civet_getFilenameClassify(params)
#puts "---> #{rx}"
#rx = civet_getFilenameGrayMatterPve(params)
#puts "---> #{rx}"
#rx = civet_getFilenameWhiteMatterPve(params)
#puts "---> #{rx}"
#rx = civet_getFilenameCsfPve(params)
#puts "---> #{rx}"
#rx = civet_getFilenameStxT1(params)
#puts "---> #{rx}"
#rx = civet_getFilenameCerebrumMask(params)
#puts "---> #{rx}"
#rx = civet_getFilenameSkullMask(params)
#puts "---> #{rx}"
#rxLh, rxRh = civet_getFilenameGrayMatterSurfaces(params.merge({:resampled => true}))
#puts "---> #{rxLh}"
#puts "---> #{rxRh}"
#rxLh, rxRh = civet_getFilenameWhiteMatterSurfaces(params.merge({:resampled => true}))
#puts "---> #{rxLh}"
#puts "---> #{rxRh}"
#rxLh, rxRh = civet_getFilenameMidSurfaces(params.merge({:resampled => true}))
#puts "---> #{rxLh}"
#puts "---> #{rxRh}"
#rxLh, rxRh = civet_getFilenameCorticalThickness(params.merge({:resampled => true}))
#puts "---> #{rxLh}"
#puts "---> #{rxRh}"
#rxLh, rxRh = civet_getFilenameMeanSurfaceCurvature(params.merge({:resampled => true}))
#puts "---> #{rxLh}"
#puts "---> #{rxRh}"
#rx = civet_getFilenameLinearTransform(params)
#puts "---> #{rx}"
#rxLh, rxRh = civet_getFilenameNonlinearTransform(params.merge({:inverted => false}))
#puts "---> #{rxLh}"
#puts "---> #{rxRh}"
#rxLh, rxRh = civet_getFilenameNonlinearTransform(params)
#puts "---> #{rxLh}"
#puts "---> #{rxRh}"
#
#typical use case [a]
#if !floopy=civet_getFilenameGrayMatterPve(civet_keyname:"0139-F-AD", civet_scanid:"00000000", settings:settings, opt:opt) then
#   puts 'The file read DID NOT work!!!'
#   puts "And the result is: #{floopy}"
#   exit
#end
#puts "Fall through case: Returned filename value: #{floopy}"

# typical use case [b]
#if !civet_classify_volname_fullPath=civet_getFilenameGrayMatterPve(civet_keyname:scan_item["keyname"], civet_scanid:scan_item["civetScanId"], settings:settings, opt:opt) then exit end
   



# test getting Civet directory names
#params = {civet_keyname:"0139-F-AD", civet_scanid:"00000000", settings:settings, opt:opt, fullpath:true, checkExistence:true}
#params = {civet_keyname:"sinbad", civet_scanid:"20030729", settings:settings, opt:opt, checkExistence:true}
#
#rx = civet_getDirnameClassify(params); puts "---> #{rx}"
#rx = civet_getDirnameFinal(params); puts "---> #{rx}"
#rx = civet_getDirnameLogs(params); puts "---> #{rx}"
#rx = civet_getDirnameMask(params); puts "---> #{rx}"
#rx = civet_getDirnameNative(params); puts "---> #{rx}"
#rx = civet_getDirnameSurfaces(params); puts "---> #{rx}"
#rx = civet_getDirnameThickness(params); puts "---> #{rx}"
#rx = civet_getDirnameTransforms(params); puts "---> #{rx}"
#rx = civet_getDirnameTransformsLinear(params); puts "---> #{rx}"
#rx = civet_getDirnameTransformsNonlinear(params); puts "---> #{rx}"
#rx = civet_getDirnameVBM(params); puts "---> #{rx}"
#rx = civet_getDirnameVerify(params); puts "---> #{rx}"



