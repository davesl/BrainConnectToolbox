function [ConnectomePath, ConnectomeImagePath, ConnectomeConfig, TrackPaths] = ...
    RunParcellation(ParcImage,ParcConfigFile,SeedInds,TargInds,FODpath,MaskPath,OutDir,TrackOptions)
% Run tractography based on seed and target indices defined in a
% parcellation image. A new parcellation image will then be generated and
% used to built a connectivity matrix of the tractogram.
%
% INPUT
% ParcImage = full path to parcellated image file
% ParcConfigFile = path for parcellation config file e.g. fs_default.txt
% SeedInds = vector of indices to be used as seed regions as defined by
%       ParcImage
% TargInds = vector of indices to be used as target regions as defined by
%       ParcImage
% FODpath = full path to preprocessed FOD data
% MaskPath = full path to analigned brain mask
% OutDir = full path to directory for tractograpy data to be saved
% TrackOptions = structure containing processing options. Default options can be
%       obtained by calling defaultTractOptions.m
%
% OUTPUT
% ConnectomePath = connectivity matrix of target regions and seed voxels
% ConnectomeImagePath = path to 4D connectome image. This is cropped to the
%       seed ROI with one image for each target connectivity profile along
%       the 4th dimension
% ConnectomeConfig = path to config .mat file which defines the labeling
%       scheme of ConnectomePath, NewParcPath and ConnectomeImagePath
% TrackPaths = structure containing paths

%% Load data and setup dirctories and variable for processing
if isempty(TrackOptions)
    TrackOptions = defaultTractOptions();
end

%% Run seed to target tracking
TrackPaths = TrackFromParc(ParcImage,SeedInds,TargInds,FODpath,MaskPath,OutDir,TrackOptions);


%% Prepare parcellation image for connectome construction
NewParcPath = fullfile(TrackPaths.TractDir,'CustomParcImage.nii.gz');
[NewParcPath, ConnectomeConfig] = PrepareParc(ParcImage,TrackPaths.Seed,TargInds,SeedInds,ParcConfigFile,NewParcPath);

%% Generate cropped connectome matrix
% Define ConnectomeOut path based on seed labels
LookupLabels = ConfigLookup(ParcConfigFile,SeedInds);
SeedNames = LookupLabels{1,2};
if size(LookupLabels,1)>1
    for i=1:size(LookupLabels,1)
        SeedNames = [SeedNames '_' LookupLabels{i+1,2}];
    end
end
ConnectomePath = fullfile(OutDir,[SeedNames '.csv']);

% Build connectome matrix 
tracts2connectome(NewParcPath,TrackPaths.Tracks,ConnectomePath,TargInds,TrackOptions);


%% Create 4D image of connectivity from seed regions to target regions
ConnectomeImagePath = fullfile(OutDir,[SeedNames '_toTargets.nii.gz']);
ConnectomeMatrix2Image(NewParcPath,ConnectomePath,TargInds,TrackPaths.Seed,ConnectomeImagePath)

% %% Tidy up files
% [PathTCK, NameTCK, ExtTCK] = fileparts(TrackPaths.Tracks);
% TrackPaths.TrackEnds = fullfile(PathTCK,[NameTCK '_ends' ExtTCK]);
% tckedit_cmd = ['tckedit ' TrackPaths.Tracks ' ' TrackPaths.TrackEnds ' -out_ends_only -nthreads ' num2str(TrackOptions.nThreads) ' -force;'];
% % Compress to just start and end points
% unix(tckedit_cmd,'-echo');
% % Delete large .tck files
% if TrackOptions.useScratch
%     copyfile(TrackPaths.TrackEnds,TrackPaths.TracksFinal,'f')
%     delete(TrackPaths.TrackEnds)
% end
% delete(TrackPaths.Tracks)


