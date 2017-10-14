function [NewParcPath, ConnectomeConfig] = PrepareParc(ParcImage,SeedROI,TargInds,SeedInds,ParcConfigFile,NewParcPath)
% Takes a parcellation image and creates a new parcellation image 
% with values 1:length(TargInds) corresponding to the target regions. Values
% from length(TargInds):(length(TargInds)+N) are then unique values for 
% each voxel in the SeedROI mask where N is the total number of voxels in 
% the seed mask.
% ParcConfigFile is used to save a reference back to the original target
% labels.
%
% Output from this code can be used with tracts2connectome.m to generate
% connectome matrices.
% 
% Note: ParcImage and SeedROI should be in the same matrix dimentions
% and aligned.
%
% INPUT
% ParcImage = full path to the parcellated image
% SeedROI = full path to seed structure ROI of interest
% TargInds = indicies to target regions in ParcImage
% ParcConfigFile = path for parcellation config file e.g. fs_default.txt
% NewParcPath = full path for newly generated parcellation image
% 
% OUTPUT
% NewParcPath = full path for newly generated parcellation image
% NewParcConfig = cell array of NewParcImage indices and brain labels

%% Load data and setup dirctories and variable for processing

if ischar(ParcImage)
    ParcNii = niftiRead(ParcImage);
    Parc = zeros(size(ParcNii.data));
else disp('ParcImage must be a full path to the parcellation nii.')
    return
end
if ischar(SeedROI)
    ROInii = niftiRead(SeedROI);
    ROI = ROInii.data;
end

%% Generate new parc image

% Re-labels all target indices
Count = 1;
for i = TargInds
    Parc(ParcNii.data==i) = Count;
    Count = Count + 1;
end

% Find all voxels in ROI mask and assign each one a unique integer value
ROIinds = find(ROI>0);
newROI = zeros(size(ROI));
for i = 1:nnz(ROI)
    newROI(ROIinds(i)) = length(TargInds) + i;
end

% Create label lookup
fileID = fopen(ParcConfigFile);
ConfigTxt = textscan(fileID, '%s','delimiter', '\t');
count=1;
for i=1:length(ConfigTxt{1,1})
    TextStr = ConfigTxt{1,1}{i};
    TextStr = strtrim(TextStr);
    TextStr = regexprep(TextStr, '\s+', ' ');
    C = strsplit(TextStr,' ');
    if ~isempty(str2num(C{1}))
        ParcConfig{count,1} = C{1};
        ParcConfig{count,2} = C{2};
        count=count+1;
    end
end
for i=1:length(TargInds)
    ParcInd = find(str2double(ParcConfig(:,1))==TargInds(i));
    NewParcConfig{i,1}= i; %str2double(ParcConfig(ParcInd,1));
    NewParcConfig{i,2}=char(ParcConfig(ParcInd,2));
end
NewParcConfig{length(TargInds)+1,1} = ['>' num2str(length(TargInds))];
NewParcConfig{length(TargInds)+1,2} = 'Seed-Voxels';

% Combine the newROI with the updated ParcImage. If overlap between seeds
% and targets exit with error output
Intersect = (Parc>0).*(newROI>0);
Intersect = max(Intersect(:));
if Intersect
    disp('Error: Overlap between seed and target regions')
    return;
end
NewParc_data = double(Parc) + double(newROI);

% Save NewParc image
if(numel(ParcNii.pixdim)>3), TR = ParcNii.pixdim(4);
else                       TR = 1;
end
dtiWriteNiftiWrapper(int16(NewParc_data), ParcNii.qto_xyz, NewParcPath, 1, '', [],[],[],[], TR);
[path, name] = fileparts(NewParcPath);
Parcout = cellstr(pickfiles(path,{name}));
NewParcPath = Parcout{1};

LookupLabels = ConfigLookup(ParcConfigFile,SeedInds);
SeedLabels = LookupLabels{1,2};
if size(LookupLabels,1)>1
    for i=2:size(LookupLabels,1)
        SeedLabels = [SeedLabels '_' LookupLabels{i,2}];
    end
end
ConnectomeConfig = fullfile(path,[SeedLabels '_ConnectomeConfig.mat']);
save(ConnectomeConfig,'NewParcConfig','NewParcPath')


