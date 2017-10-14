function Mcropped = tracts2connectome(NewParcImage,TrackPath,ConnectomeOut,TargInds,TrackOptions)
% This function will take a pregenerated tractogram and extract the
% connectome matrix based on the definition of ParcImage. The matrix will
% be trimmed to have Ntarg rows and Nseedvox columns.
% 
% NewParcImage = parcellated image with values assigned to unique integer
%       values for all target regions and unique integers for each seed ROI
%       voxel. Expects numbering 1:Ntargets then
%       Ntargets+1:Ntargets+Nseedvox
% TrackPath = full path to .tck track file
% ConnectomeOut = Outpath for connectome .csv file
% StartROIind = The integer index for which the seed ROI voxels start. e.g.
%       for the default parc setup StartROIind=35
% TrackOptions = options structure


%% Load data and setup dirctories and variable for processing
if isempty(TrackOptions)
    TrackOptions = defaultTractOptions();
end

if ~TrackOptions.saveAssignments
    Assignments_command = '';
else
    Assignment_path = fullfile(fileparts(ConnectomeOut),'TckAssignments.txt');
    Assignments_command=['-assignments ' Assignment_path ' '];
end


Tck2ConnectomeCommand = ['tck2connectome -force -assignment_radial_search ' num2str(TrackOptions.radialassigndist) ' ' Assignments_command TrackPath ' ' NewParcImage ' ' ConnectomeOut];

[status, cmdout] = unix(Tck2ConnectomeCommand,'-echo');

numTargs = length(TargInds);
M = dlmread(ConnectomeOut,' ');
Mcropped = M(1:numTargs,numTargs+1:end);

dlmwrite(ConnectomeOut,Mcropped,' ')

end