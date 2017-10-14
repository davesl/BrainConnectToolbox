function TrackOptions = defaultTractOptions()

% D Slater default params
TrackOptions                         = struct;
TrackOptions.bvalue                  = [];

% TrackOptions.mrtrixPATH = '/data/lren/program/mrtrix3'; % Path to mrtrix. By default the HPC1 location.
% TrackOptions.HPCdirPATH = '/data/lren/Diff_Tractography'; % If saving commands only this is assumed to be the basedir for copied /Subject/HARDI folders on HPC system

TrackOptions.TrackChoice = 'iFOD2';     % FACT, iFOD1, iFOD2, Nulldist, SD_Stream, Seedtest, Tensor_Det, Tensor_Prob (default: iFOD2).
TrackOptions.seedspervox = 50000;        % Number of seeds to run for each voxel
TrackOptions.maxLength = 250;           % Maximum allowed length of tracks in output (in mm)
TrackOptions.minLength = 0;            % Minimum allowed length of tracks in output (in mm)
TrackOptions.downsample_factor = 8;     % The factor by which streamlines should be down sampled to reduce tck file size
TrackOptions.radialassigndist = 4;      % Distance for max radial assignment in tck2connectome (in mm)
TrackOptions.cutoff = 0.1;              % The FOD amplitude cutoff for terminating tracks
TrackOptions.nThreads = 4;                % Number of threads to run in parallel
TrackOptions.useScratch = 1;            % if true run tractography on local /scratch then copy back
TrackOptions.saveAssignments=0;           % if true save connectome assignments file.
TrackOptions.RunTracts=1;               % if false just output tckgen command

return