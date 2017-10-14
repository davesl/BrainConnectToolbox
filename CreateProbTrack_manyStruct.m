function CreateProbTrack_manyStruct(SubjParDir, TrackOptions)

%% Setup paths and variables

ParcImage = cellstr(pickfiles(SubjParDir,{'destrieux_Parc_image_fixSGM.nii.gz'}));
ParcConfigFile = cellstr(pickfiles('/data/lren/DSLATER/Code_and_Scripts/ParcellationPackage',{'fs_Destrieux.txt'}));
FODpath = cellstr(pickfiles(SubjParDir,{'data_aligned_unwarped_HARDI_WMfod.nii.gz'}));
%     MaskPath = cellstr(pickfiles(SubjParDir,{'data_aligned_unwarped_mask.nii'}));
MaskPath = cellstr(pickfiles(SubjParDir,{'Sliced5TT_mask.nii.gz'}));

SeedInds =[78 79 80 85 86 87];

dirName ={'Caudate_lh'; 'Putamen_lh'; 'GP_lh';'Caudate_rh';'Putamen_rh'; 'GP_rh'};

if isempty(TrackOptions)
    TrackOptions = defaultTractOptions();
end
% Number of fibers per voxels
TrackOptions.seedspervox = 10000;
TrackOptions.cutoff = 0.01;

%% Check all neccessary files present
SkipSubject = 0;
if isempty(ParcImage{1}) || isempty(ParcConfigFile{1}) || isempty(FODpath{1}) || isempty(MaskPath{1})
    SkipSubject = 1;
end

%% Loop over and track for each structure
if ~SkipSubject
    for i=1:length(SeedInds)
        mkdir([SubjParDir,filesep,dirName{i}] )
        OutDir = [SubjParDir,filesep,dirName{i}] ;
        if SeedInds(i)<81
            % left seed to left cortex
            TargIndsLeft = 1:75;
            [ConnectomePath, ConnectomeImagePath, ConnectomeConfig, TrackPaths]=RunParcellation(ParcImage{1},ParcConfigFile{1},SeedInds(i),TargIndsLeft,FODpath{1},MaskPath{1},OutDir,TrackOptions); %#ok<ASGLU>
            save([OutDir filesep 'RunParcellation_variables.mat'],'ConnectomePath', 'ConnectomeImagePath', 'ConnectomeConfig', 'TrackPaths')
        else
            % right seed to right cortex
            TargIndsRight = 91:165;
            [ConnectomePath, ConnectomeImagePath, ConnectomeConfig, TrackPaths]=RunParcellation(ParcImage{1},ParcConfigFile{1},SeedInds(i),TargIndsRight,FODpath{1},MaskPath{1},OutDir,TrackOptions); %#ok<ASGLU>
            save([OutDir filesep 'RunParcellation_variables.mat'],'ConnectomePath', 'ConnectomeImagePath', 'ConnectomeConfig', 'TrackPaths')
        end
    end
else
    disp('------------------------')
    disp('Missing neccessary files')
    disp('------------------------')
    ParcImage=ParcImage{1}
    ParcConfigFile=ParcConfigFile{1}
    FODpath=FODpath{1}
    MaskPath=MaskPath{1}
    disp('------------------------')
end

end
