# ==============================================================================
# Purpose:
#     Build the run commands for all of the scripts executed via the 
#     Beagle pipeline.
#
# ==============================================================================
#

#
# Initialization -- by Subject
#
def buildCmd_beagle_run_initialization(keyname, opt, settings, verbose=false, debug=false)
   cmd = "beagle_run_initialization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{keyname} "
   cmd << "--eraseLog  "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  


#
# Initialization -- by Subject/Scan
#
def buildCmd_beagle_anatomical_initialization(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_anatomical_initialization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  

   
#
# Labels
#
def buildCmd_beagle_labels_fit_AAL(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_labels_fit_AAL   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  

   
#
# Masks
#
def buildCmd_beagle_masks_generate_from_labels(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_masks_generate_from_labels   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   
   # define the Loris-generated AAL labelled input volume
   aal_label_volume_suffix = '_t1_final_' + settings['AAL_LABELS_VERSION'] + 'Labels.mnc'
   keyname_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item["keyname"])
   loris_labelled_volname = scan_item["keyname"] + aal_label_volume_suffix
   aal_dir = 'AAL-' + scan_item["scanDate"]
   loris_labelled_volname_fullPath = File.join(keyname_dir_fullPath, aal_dir, loris_labelled_volname)
   cmd << "--labelledAALvolume #{loris_labelled_volname_fullPath} "
   
   # define the Civet-generated tissue classification volume
   civetId_dir_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item["scanId"])
   civet_classify_volname = settings['CIVET_PREFIX'] + '_' + scan_item["scanId"] + settings['CIVET_CLASSIFY_DISCRETE_VOLUME_SUFFIX']
   civet_classify_volname_fullPath = File.join(civetId_dir_fullPath, 'classify', civet_classify_volname)
   cmd << "--classifyVolume #{civet_classify_volname_fullPath} "
   
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  


   
#
# VBM
#
def buildCmd_beagle_vbm_compute_individ_VBM(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_vbm_compute_individ_VBM.Rscript   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate  #{scan_item['scanDate']}  "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  

   
def buildCmd_beagle_vbm_quantification(scan_item, opt, settings, verbose=false, debug=false)
   # set some required derived values
   vbm_dir = 'VBM-' + scan_item["scanDate"]
   keyname_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item["keyname"])
   vbm_dir_fullPath = File.join(keyname_dir_fullPath, vbm_dir)

   cmd = "beagle_vbm_quantification.Rscript   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate  #{scan_item['scanDate']}  "
   cmd << "--settingsFile #{opt.settingsFile} "
         
   # GM z-score volume
   gm_zScore_volume = scan_item['keyname'] + settings['VBM_GM_ZSCORE_VOLUME_SUFFIX'] + ".mnc"
   gm_zScore_volume_fullPath = File.join(vbm_dir_fullPath, gm_zScore_volume)
   cmd << "#{gm_zScore_volume_fullPath}  "                        
   
   # WM z-score volume
   wm_zScore_volume = scan_item['keyname'] + settings['VBM_WM_ZSCORE_VOLUME_SUFFIX'] + ".mnc"
   wm_zScore_volume_fullPath = File.join(vbm_dir_fullPath, wm_zScore_volume)
   cmd << "#{wm_zScore_volume_fullPath}  "                        
   return cmd
end  

   
def buildCmd_beagle_vbm_volumetric_visualization(scan_item, opt, settings, verbose=false, debug=false)
   # set some required derived values
   vbm_dir = 'VBM-' + scan_item["scanDate"]
   keyname_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item["keyname"])
   vbm_dir_fullPath = File.join(keyname_dir_fullPath, vbm_dir)

   cmd = "beagle_vbm_volumetric_visualization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate  #{scan_item['scanDate']}  "
   cmd << "--settingsFile #{opt.settingsFile} "
   
   # t1 anatomical underlay volume
   civetId_dir_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item["scanId"])
   t1Volume = settings['CIVET_PREFIX'] + "_" + scan_item["scanId"] + settings['CIVET_FINAL_T1_VOLUME_SUFFIX']
   t1Volume_fullPath = File.join(civetId_dir_fullPath, 'final', t1Volume)
   cmd << "--t1UnderlayVol #{t1Volume_fullPath} "
      
   # GM z-score volume
   gm_zScore_volume = scan_item['keyname'] + settings['VBM_GM_ZSCORE_VOLUME_SUFFIX'] + ".mnc"
   gm_zScore_volume_fullPath = File.join(vbm_dir_fullPath, gm_zScore_volume)
   cmd << "#{gm_zScore_volume_fullPath}  "
      
   # WM z-score volume
   wm_zScore_volume = scan_item['keyname'] + settings['VBM_WM_ZSCORE_VOLUME_SUFFIX'] + ".mnc"
   wm_zScore_volume_fullPath = File.join(vbm_dir_fullPath, wm_zScore_volume)
   cmd << "#{wm_zScore_volume_fullPath} "
   return cmd
end  

 
   
#
# Cortical Thickness
#
def buildCmd_beagle_thickness_compute_zscores(scan_item, opt, settings, verbose=false, debug=false)
   # set some required derived values
   civetScanId_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item["scanId"])
   civetScanId_thicknessDir_fullPath = File.join(civetScanId_fullPath, settings['CIVET_THICKNESS_DIR'])
   #
   civet_thickness_values_left_suffix = settings['CIVET_THICKNESS_VALUES_RSL_LEFT_SUFFIX']
   civet_thickness_values_right_suffix = settings['CIVET_THICKNESS_VALUES_RSL_RIGHT_SUFFIX']

   cmd = "beagle_thickness_compute_zscores   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate  #{scan_item['scanDate']}  "
   cmd << "--settingsFile #{opt.settingsFile} "
   
   # CTA input vector files (left and right hemispheres) from Civet
   filename = settings['CIVET_PREFIX'] + '_' + scan_item["scanId"] + civet_thickness_values_left_suffix
   thicknessLh_filename_fullPath = File.join(civetScanId_thicknessDir_fullPath, filename)
   cmd << "--lhThicknessVectorFile #{thicknessLh_filename_fullPath}  "
   
   filename = settings['CIVET_PREFIX'] + '_' + scan_item["scanId"] + civet_thickness_values_right_suffix
   thicknessRh_filename_fullPath = File.join(civetScanId_thicknessDir_fullPath, filename)
   cmd << "--rhThicknessVectorFile #{thicknessRh_filename_fullPath}  "
   return cmd
end  


def buildCmd_beagle_thickness_extract_surface_labels(scan_item, opt, settings, verbose=false, debug=false)
   
   # define full civet directory name
   civetId_dir_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['scanId'])
   civet_surfaces_dir = File.join(civetId_dir_fullPath, 'surfaces')

   cmd = "beagle_thickness_extract_surface_labels   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate  #{scan_item['scanDate']}  "
   cmd << "--settingsFile #{opt.settingsFile} "

   # set surface object filenames
   filename = settings['CIVET_PREFIX'] + '_' + scan_item['scanId'] + settings['CIVET_SURFACE_MID_LEFT_SUFFIX']
   civet_surfaceLh_fullPath = File.join(civet_surfaces_dir, filename)
   cmd << "--surfaceLh #{civet_surfaceLh_fullPath}  "
    
   filename = settings['CIVET_PREFIX'] + '_' + scan_item['scanId'] + settings['CIVET_SURFACE_MID_RIGHT_SUFFIX']
   civet_surfaceRh_fullPath = File.join(civet_surfaces_dir, filename)
   cmd << "--surfaceRh #{civet_surfaceRh_fullPath}  "
   
   keyname_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item['keyname'])
   aal_dir = 'AAL-' + scan_item['scanDate']
   aal_dir_fullPath = File.join(keyname_dir_fullPath, aal_dir)
   #
   aal_labelled_volume_suffix = "_t1_final_" + settings['AAL_LABELS_VERSION'] + "Labels_gmMask.mnc"
   filename = scan_item['keyname'] + aal_labelled_volume_suffix
   aal_lblVolume_fullPath = File.join(aal_dir_fullPath, filename)
   cmd << "--aalLblVolume #{aal_lblVolume_fullPath}  "
   return cmd
end  


def buildCmd_beagle_thickness_compute_roi_statistics(scan_item, opt, settings, verbose=false, debug=false)
   #
   # define some handy constants
   thickness_file_suffix = "_thickness_lhrh.txt"
   thickness_zscores_file_suffix = "_thickness_zscores.txt"
   thickness_surface_labels_file_suffix = "_extracted_aal_surface_labels.txt"
   
   # define some handy paths
   keyname_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item['keyname'])
   cta_dir = 'THICKNESS-' + scan_item['scanDate']
   cta_dir_fullPath = File.join(keyname_dir_fullPath, cta_dir)

   cmd = "beagle_thickness_compute_roi_statistics.Rscript   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate  #{scan_item['scanDate']}  "
   cmd << "--settingsFile #{opt.settingsFile} "

   # subject's aggregated thickness vector file
   filename = scan_item['keyname'] + thickness_file_suffix
   thickness_vector_file_fullPath = File.join(cta_dir_fullPath, filename)
   cmd << "--thicknessVectorFile #{thickness_vector_file_fullPath}  "

   # subject's zscores vector file
   filename = scan_item['keyname'] + thickness_zscores_file_suffix
   zscores_vector_file_fullPath = File.join(cta_dir_fullPath, filename)
   cmd << "--zscoresVectorFile #{zscores_vector_file_fullPath}  "
   
   # subject's extracted AAL surface labels
   filename = scan_item['keyname'] + thickness_surface_labels_file_suffix
   extracted_surface_labels_fullPath = File.join(cta_dir_fullPath, filename)
   cmd << "--surfaceLabelsVectorFile #{extracted_surface_labels_fullPath}  "
   return cmd
end  


def buildCmd_beagle_thickness_surface_visualization(scan_item, opt, settings, verbose=false, debug=false)
   #
   # define some handy constants
   color_map = 'hot'             # color map to use in rendering
   
   cmd = "beagle_thickness_surface_visualization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate  #{scan_item['scanDate']}  "
   cmd << "--settingsFile #{opt.settingsFile} "

   cmd << "--colorMap #{color_map}  "
   
   # avg surfaces -- LH/RH; averaged surfaces to be used for visualization
   adni_surfaces_dir = settings['ADNI_SURFACES_DIR']
   adni_lh_gm_surface = settings['ADNI_LH_GM_SURFACE']
   adni_lh_gm_surface_fullpath = File.join(adni_surfaces_dir, adni_lh_gm_surface)
   cmd << "--avgLhSurface #{adni_lh_gm_surface_fullpath}  "
   #
   adni_rh_gm_surface = settings['ADNI_RH_GM_SURFACE']
   adni_rh_gm_surface_fullpath = File.join(adni_surfaces_dir, adni_rh_gm_surface)
   cmd << "--avgRhSurface #{adni_rh_gm_surface_fullpath}  "
   
   # individual surfaces -- LH/RH
   indivLhSurface = settings['CIVET_PREFIX'] + '_' + scan_item['scanId'] + settings['CIVET_SURFACE_GRAY_LEFT_SUFFIX']
   indivLhSurface_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['scanId'], 'surfaces', indivLhSurface)
   cmd << "--indivLhSurface #{indivLhSurface_fullPath}  "   
   #
   indivRhSurface = settings['CIVET_PREFIX'] + '_' + scan_item['scanId'] + settings['CIVET_SURFACE_GRAY_RIGHT_SUFFIX']
   indivRhSurface_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['scanId'], 'surfaces', indivRhSurface)
   cmd << "--indivRhSurface #{indivRhSurface_fullPath}  "

   return cmd
end  

   
#
# PiB
#
def buildCmd_beagle_pib_initialization(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_initialization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanId #{scan_item['civetScanId']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  


def buildCmd_beagle_pib_convert_ecat2mnc(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_convert_ecat2mnc   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanId #{scan_item['civetScanId']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   
   # fullpath to input ecat file
   ecat_filename_fullPath = File.join(settings['PIB_ECAT_DIR'], scan_item['ecatFilename'])
   cmd << "#{ecat_filename_fullPath}  "
   return cmd
end  

   
def buildCmd_beagle_pib_preprocess(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_preprocess   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--xfmToNativeMRI  --xfmToIcbmMRI  "
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanId #{scan_item['civetScanId']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   
   keyname_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item['keyname'])
   pib_dir = 'PiB-' + scan_item['scanDate']
   pib_dir_fullPath = File.join(keyname_dir_fullPath, pib_dir)
   pibNative_dir_fullPath = File.join(pib_dir_fullPath, 'native')
   #
   minc_in = scan_item["keyname"] + '.mnc'
   minc_in_fullPath = File.join(pibNative_dir_fullPath, minc_in)
   cmd << "#{minc_in_fullPath}  "
   return cmd
end  


def buildCmd_beagle_pib_generate_masks(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_generate_masks   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  


def buildCmd_beagle_pib_preprocess_verification(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_preprocess_verification   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  

   
def buildCmd_beagle_pib_compute_ratios(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_compute_ratios.Rscript   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  

   
def buildCmd_beagle_pib_compute_SUVR(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_compute_SUVR.Rscript    ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  

   
def buildCmd_beagle_pib_volumetric_visualization(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_volumetric_visualization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   
   # gray matter mask volume
   derived_gm_mask_volume = 'wholeBrain_gray_matter_mask.mnc'
   masks_dir = 'MASKS-' + scan_item['civetScanDate']
   masks_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item['keyname'], masks_dir)
   gmMaskVol_fullPath = File.join(masks_dir_fullPath, derived_gm_mask_volume)
   cmd << "--gmMaskVol #{gmMaskVol_fullPath} "                 
   
   # t1 anatomical underlay volume
   t1Volume = settings['CIVET_PREFIX'] + '_' + scan_item['civetScanId'] + settings['CIVET_FINAL_T1_VOLUME_SUFFIX']
   t1Volume_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['civetScanId'], 'final', t1Volume)
   cmd << "--t1UnderlayVol #{t1Volume_fullPath} "
   return cmd
end  

   
def buildCmd_beagle_pib_surface_visualization(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_pib_surface_visualization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "

   # color map to use in rendering
   color_map = 'hot'             
   cmd << "--colorMap #{color_map}  "
   
   # avg surfaces -- LH/RH; averaged surfaces to be used for visualization
   adni_surfaces_dir = settings['ADNI_SURFACES_DIR']
   adni_lh_gm_surface = settings['ADNI_LH_GM_SURFACE']
   adni_lh_gm_surface_fullpath = File.join(adni_surfaces_dir, adni_lh_gm_surface)
   cmd << "--avgLhSurface #{adni_lh_gm_surface_fullpath}  "
   #
   adni_rh_gm_surface = settings['ADNI_RH_GM_SURFACE']
   adni_rh_gm_surface_fullpath = File.join(adni_surfaces_dir, adni_rh_gm_surface)
   cmd << "--avgRhSurface #{adni_rh_gm_surface_fullpath}  "
   
   # individual surfaces -- LH/RH
   indivLhSurface = settings['CIVET_PREFIX'] + '_' + scan_item['civetScanId'] + settings['CIVET_SURFACE_GRAY_LEFT_SUFFIX']
   indivLhSurface_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['civetScanId'], 'surfaces', indivLhSurface)
   cmd << "--indivLhSurface #{indivLhSurface_fullPath}  "   
   #
   indivRhSurface = settings['CIVET_PREFIX'] + '_' + scan_item['civetScanId'] + settings['CIVET_SURFACE_GRAY_RIGHT_SUFFIX']
   indivRhSurface_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['civetScanId'], 'surfaces', indivRhSurface)
   cmd << "--indivRhSurface #{indivRhSurface_fullPath}  "
   return cmd
end  


   
#
# FDG
#
def buildCmd_beagle_fdg_initialization(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_fdg_initialization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanId #{scan_item['civetScanId']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  


def buildCmd_beagle_fdg_convert_native2mnc(scan_item, opt, settings, verbose=false, debug=false)

   cmd = "beagle_fdg_convert_native2mnc   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "

   # set the native volume format switch ("--ecat", "--dicom", or more recently, "--minc")
   cmdSwitch = scan_item["dicomOrEcat"]
   cmd << "--#{cmdSwitch} "

   # point to where the native FDG scan can be found:
   # (1) if ecat/minc --> full path to the ecat file
   if ( cmdSwitch == "ecat" or cmdSwitch == "minc" ) then
      native_target_fullPath = File.join(settings['FDG_NATIVE_DIR'], scan_item["scanFileLocation"])
   end
   
   # (2) if dicom --> full path the dicom root subdirectory
   #     Note: the Dicom root must located within a "scanId" subdirectory (eg., ../fdg/aeneus-20091117/Dicom-PET/.. 
   if ( cmdSwitch == "dicom" ) then
      native_fdg_dirname_fullPath = File.join(settings['FDG_NATIVE_DIR'], scan_item['scanId'])
      native_target_fullPath = File.join(native_fdg_dirname_fullPath, scan_item["scanFileLocation"])
   end
   cmd << "--inputTarget=#{native_target_fullPath} "
   return cmd
end  

   
def buildCmd_beagle_fdg_preprocess(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_fdg_preprocess   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--xfmToNativeMRI  --xfmToIcbmMRI  "
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanId #{scan_item['civetScanId']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   
   keyname_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item['keyname'])
   fdg_dir = 'FDG-' + scan_item['scanDate']
   fdg_dir_fullPath = File.join(keyname_dir_fullPath, fdg_dir)
   fdgNative_dir_fullPath = File.join(fdg_dir_fullPath, 'native')
   #
   minc_in = scan_item["keyname"] + '.mnc'
   minc_in_fullPath = File.join(fdgNative_dir_fullPath, minc_in)
   cmd << "#{minc_in_fullPath}  "
   return cmd
end  


def buildCmd_beagle_fdg_preprocess_verification(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_fdg_preprocess_verification   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  


def buildCmd_beagle_fdg_compute_ratios(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_fdg_compute_ratios.Rscript   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  


def buildCmd_beagle_fdg_compute_SUVR(scan_item, opt, settings, verbose=false, debug=false)

   cmd = "beagle_fdg_compute_SUVR.Rscript   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  


def buildCmd_beagle_fdg_volumetric_visualization(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_fdg_volumetric_visualization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   
   # gray matter mask volume
   derived_gm_mask_volume = 'wholeBrain_gray_matter_mask.mnc'
   masks_dir = 'MASKS-' + scan_item['civetScanDate']
   masks_dir_fullPath = File.join(settings['LORIS_ROOT_DIR'], scan_item['keyname'], masks_dir)
   gmMaskVol_fullPath = File.join(masks_dir_fullPath, derived_gm_mask_volume)
   cmd << "--gmMaskVol #{gmMaskVol_fullPath} "                 
   
   # t1 anatomical underlay volume
   t1Volume = settings['CIVET_PREFIX'] + '_' + scan_item['civetScanId'] + settings['CIVET_FINAL_T1_VOLUME_SUFFIX']
   t1Volume_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['civetScanId'], 'final', t1Volume)
   cmd << "--t1UnderlayVol #{t1Volume_fullPath} "
   return cmd
end  


def buildCmd_beagle_fdg_surface_visualization(scan_item, opt, settings, verbose=false, debug=false)
   cmd = "beagle_fdg_surface_visualization   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{scan_item['keyname']} "
   cmd << "--scanDate #{scan_item['scanDate']} "
   cmd << "--civetScanDate #{scan_item['civetScanDate']} "
   cmd << "--settingsFile #{opt.settingsFile} "
   
   # probability map volume(s) used for visualization masking
   elderly_model_dir = settings['ELDERLY_MODEL_DIR']
   elderly_model_pmap_mean_csf_volume  = settings['ELDERLY_MODEL_PMAP_MEAN_CSF_VOLUME']
   elderly_model_pmap_mean_csf_volume_fullpath = File.join(elderly_model_dir, elderly_model_pmap_mean_csf_volume)
   cmd << "--csfPmapVolume #{elderly_model_pmap_mean_csf_volume_fullpath}  "

   # color map to use in rendering
   color_map = 'hot'             
   cmd << "--colorMap #{color_map}  "
   
   # avg surfaces -- LH/RH; averaged surfaces to be used for visualization
   adni_surfaces_dir = settings['ADNI_SURFACES_DIR']
   adni_lh_gm_surface = settings['ADNI_LH_GM_SURFACE']
   adni_lh_gm_surface_fullpath = File.join(adni_surfaces_dir, adni_lh_gm_surface)
   cmd << "--avgLhSurface #{adni_lh_gm_surface_fullpath}  "
   #
   adni_rh_gm_surface = settings['ADNI_RH_GM_SURFACE']
   adni_rh_gm_surface_fullpath = File.join(adni_surfaces_dir, adni_rh_gm_surface)
   cmd << "--avgRhSurface #{adni_rh_gm_surface_fullpath}  "
   
   # individual surfaces -- LH/RH
   indivLhSurface = settings['CIVET_PREFIX'] + '_' + scan_item['civetScanId'] + settings['CIVET_SURFACE_GRAY_LEFT_SUFFIX']
   indivLhSurface_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['civetScanId'], 'surfaces', indivLhSurface)
   cmd << "--indivLhSurface #{indivLhSurface_fullPath}  "   
   #
   indivRhSurface = settings['CIVET_PREFIX'] + '_' + scan_item['civetScanId'] + settings['CIVET_SURFACE_GRAY_RIGHT_SUFFIX']
   indivRhSurface_fullPath = File.join(settings['CIVET_ROOT_DIR'], scan_item['civetScanId'], 'surfaces', indivRhSurface)
   cmd << "--indivRhSurface #{indivRhSurface_fullPath}  "
   return cmd
end  


#
# Generate Summary Report
#
def buildCmd_beagle_make_summary_report(keyname, opt, settings, verbose=false, debug=false)
   cmd = "beagle_make_summary_report   ";cmd << (opt.verbose ? "-v " : "");cmd << (opt.debug ? "-d " : "")
   cmd << "--keyname #{keyname} "
   cmd << "--settingsFile #{opt.settingsFile} "
   return cmd
end  

   







