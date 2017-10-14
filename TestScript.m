
SubDir = '/data/lren/Diff_Tractography/PR00505_RB170548';
ParcConfigFile = '/data/lren/DSLATER/Code_and_Scripts/ParcellationPackage/fs_aparc2009config.txt';
SeedInds = [79];
TargInds = [1:75];
ParcDir = '/data/lren/Diff_Tractography/PR00505_RB170548/01/16/Parcellations';
TractDir = fullfile(ParcDir,'Putamen');

ParcImage = cellstr(pickfiles(SubDir,{'qMRI','destrieux_Parc_image_fixSGM.nii.gz'}));
FODpath = cellstr(pickfiles(SubDir,{'HARDI','_fod.nii.gz'}));
MaskPath = cellstr(pickfiles(SubDir,{'HARDI','_mask.nii'}));

TrackOptions = defaultTractOptions();
TrackOptions.seedspervox = 100;

[Mcropped, TrackPaths, ConnectomeConfig] = RunParcellation(ParcImage{1},ParcConfigFile,SeedInds,TargInds,FODpath{1},MaskPath{1},TractDir,TrackOptions);