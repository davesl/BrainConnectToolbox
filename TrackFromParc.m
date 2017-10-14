function [TrackPaths, tckgen_command] = TrackFromParc(ParcImage,SeedInds,TargInds,FODpath,MaskPath,TractDir,TrackOptions)
% Function to track from a Seed to a Target. The tractography is based on a
% predefined parcellated image. This can be any image which assigns a
% unique integer value to each structure of interest. The SeedInds and
% TargInds can be used to set seed and target regions for a particular
% diffusion parcellation experiment.
%
% INPUT
% ParcImage = full path to parcellated image file
% SeedInds = vector of indices to be used as seed regions as defined by
%            ParcImage
% TargInds = vector of indices to be used as target regions as defined by
%            ParcImage
% FODpath = full path to preprocessed FOD data
% MaskPath = full path to analigned brain mask
% TractDir = full path to directory for tractograpy data to be saved
% TrackOptions = structure containing processing options. Default options can be
%       obtained by calling defaultTractOptions.m
%
% OUTPUT
% TrackPaths = structure containing paths to relevent tracking files


%% Load data and setup dirctories and variable for processing
if isempty(TrackOptions)
    TrackOptions = defaultTractOptions();
end

parcnii = niftiRead(ParcImage);
if(numel(parcnii.pixdim)>3), TR = parcnii.pixdim(4);
else                       TR = 1;
end

ROIdir = fullfile(TractDir,'ROIs');
if ~exist(ROIdir,'dir')
    mkdir(ROIdir)
end

mask = MaskPath;

%% Create seed and mask ROIs
% Create Seed ROI
Seeds = zeros(size(parcnii.data));
for i = SeedInds
    Seeds(parcnii.data==i) = 1;
end
Seedpath = fullfile(ROIdir,'Seeds.nii.gz');
dtiWriteNiftiWrapper(int16(Seeds), parcnii.qto_xyz, Seedpath, 1, '', [],[],[],[], TR);
% Create Target ROI
Targets = zeros(size(parcnii.data));
for i = TargInds
    Targets(parcnii.data==i) = 1;
end
Targpath = fullfile(ROIdir,'Targets.nii.gz');
dtiWriteNiftiWrapper(int16(Targets), parcnii.qto_xyz, Targpath, 1, '', [],[],[],[], TR);

%% Create commands for tractography tracking

% Handle whether to use /scratch
TrackPath = fullfile(TractDir,'Fibers.tck');
if TrackOptions.useScratch
    FinalPath = TrackPath;
    TrackPath = fullfile([filesep 'scratch'],FinalPath);
    if ~exist(fileparts(TrackPath),'dir')
        mkdir(fileparts(TrackPath))
    end
else
    FinalPath = TrackPath;
end

% Concat tckgen options
tckgen_options = ['-algorithm ' TrackOptions.TrackChoice ' -minlength ' num2str(TrackOptions.minLength) ...
    ' -maxlength ' num2str(TrackOptions.maxLength) ' -unidirectional -stop -force -downsample ' ...
    num2str(TrackOptions.downsample_factor) ' -cutoff ' num2str(TrackOptions.cutoff) ' -nthreads ' num2str(TrackOptions.nThreads)];

% Full command for track generation
tckgen_command = ['tckgen ' tckgen_options ' -include ' Targpath ' -mask ' mask ...
    ' -seed_grid_per_voxel ' Seedpath ' ' num2str(round(TrackOptions.seedspervox^(1/3))) ' ' ...
    FODpath ' ' TrackPath];

% Run mrtrix tractography commands
if TrackOptions.RunTracts
    [status, cmdout] = unix(tckgen_command,'-echo');
end

% Build structure of useful paths
TrackPaths = struct();
TrackPaths.TractDir = TractDir;
TrackPaths.Seed = Seedpath;
TrackPaths.Target = Targpath;
TrackPaths.Tracks = TrackPath;
TrackPaths.TracksFinal = FinalPath;


end
