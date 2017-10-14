function [lh_out, rh_out] = AddNodeInfoToFreeSurferLabel(NodeInfo,NodeList,AnnotID,OutDir,OutName)
% A function to add node values in NodeInfo to AnnotID labels for the
% typical MNI subject cvs_avg35_inMNI152. 
% 
% e.g. Peak age could be estimated for each node. This could then be
% displayed on the cvs_avg35_inMNI152 subject.

if isunix
    % By default use fs subject cvs_avg35_inMNI152
    fs_subject = '/data/lren/program/freesurfer/subjects/fsaverage';
    % Default fs LUT
%     fs_LUT = '/media/dave/Elements/Diffusion/Connectomics/Connectome_code/fs_LUT.mat';
    fs_LUT = '/data/lren/DSLATER/Connectomics/Connectome_code/fs_LUT.mat';
else
    % By default use fs subject cvs_avg35_inMNI152
    fs_subject = 'I:\Diffusion\cvs_avg35_inMNI152';
    % Default fs LUT
    fs_LUT = 'I:\Diffusion\Connectomics\Code\Connectome_code\fs_LUT.mat';
end
if strcmpi(AnnotID,'Gordon')
    fs_LUT = 'I:\Diffusion\Connectomics\Code\Connectome_code\Gordon333_LUT.mat';
end

% % mean of nonzero elements along 2nd dimension
% n = sum(SigNetwork_tScores{i}~=0,2);
% n(n==0) = NaN;
% SigNetwork_Node_tscores{i} = sum(SigNetwork_tScores{i},2) ./ n;

load(fs_LUT)

% Find and load appropriate parc annot files and pial surfaces
Thickmgz = cellstr(pickfiles(fullfile(fs_subject,'surf'),{'thickness'},{'.'},{'rh.'}));
lhAnnot = cellstr(pickfiles(fullfile(fs_subject,'label'),{'lh.',AnnotID},{'.'},{'rh.'}));
rhAnnot = cellstr(pickfiles(fullfile(fs_subject,'label'),{'rh.',AnnotID},{'.'},{'lh.'}));
lhPial = cellstr(pickfiles(fullfile(fs_subject,'surf'),{'lh.pial'},{'.'},{'rh.'}));
rhPial = cellstr(pickfiles(fullfile(fs_subject,'surf'),{'rh.pial'},{'.'},{'lh.'}));

[~, M]=load_mgh(Thickmgz{1});
[lh_vertices, lh_label, lh_colortable] = read_annotation(lhAnnot{1});
[rh_vertices, rh_label, rh_colortable] = read_annotation(rhAnnot{1});
[lh_vertex_coords] = read_surf(lhPial{1});
[rh_vertex_coords] = read_surf(rhPial{1});

% lh_nodes = [1:length(NodeList)/2];
% rh_nodes = [length(NodeList)/2:length(NodeList)];

lh_nodes = [1:length(NodeList)];
rh_nodes = [1:length(NodeList)];


% Loop over all lh nodes and vertices
lh_node_surf = zeros(size(lh_vertex_coords,1),1);
for i=lh_nodes
    NodeName = NodeList{i};
    
    % Find index for node in fs annot 
    for j=1:length(lh_colortable.struct_names)
        Test = strfind(NodeName,lh_colortable.struct_names{j});
        if ~isempty(Test)
            Ind = j;
        end
    end
    
    % Find verties of node i
    NodeID = lh_colortable.table(Ind,5);
    Label_INDS = find(lh_label==NodeID);
    
    % Add NodeInfo into correct vertex locations
    lh_node_surf(Label_INDS) = NodeInfo(i);
    
end

% Loop over all rh nodes and vertices
rh_node_surf = zeros(size(rh_vertex_coords,1),1);
for i=rh_nodes
    NodeName = NodeList{i};
    
    % Find index for node in fs annot 
    for j=1:length(rh_colortable.struct_names)
        Test = strfind(NodeName,rh_colortable.struct_names{j});
        if ~isempty(Test)
            Ind = j;
        end
    end
    
    % Find verties of node i
    NodeID = rh_colortable.table(Ind,5);
    Label_INDS = find(rh_label==NodeID);
    
    % Add NodeInfo into correct vertex locations
    rh_node_surf(Label_INDS) = NodeInfo(i);
    
end

lh_out = ['lh.' OutName '.mgh'];
rh_out = ['rh.' OutName '.mgh'];

% Save NodeInfo into .mgh surface file
save_mgh(lh_node_surf,fullfile(OutDir,lh_out),M);
save_mgh(rh_node_surf,fullfile(OutDir,rh_out),M);

lh_out = fullfile(OutDir,lh_out);
rh_out = fullfile(OutDir,rh_out);

