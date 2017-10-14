function ConnectomeMatrix2Image(NewParcImage,ConnectomeOut,TargInds,SeedROI,OutPath)

% Read ConnectomeOut
M = dlmread(ConnectomeOut,' ');

%% Crop NewParcImage to FoV defined by SeedROI
[path, name] = fileparts(NewParcImage);
C = strsplit(name,'.');
cropped_NewParcImage = fullfile(path,[C{1} '_cropped.nii.gz']);
mrcrop_commands = ['mrcrop -force -mask ' SeedROI ' ' NewParcImage ' ' cropped_NewParcImage];
[status, cmdout] = unix(mrcrop_commands,'-echo');

%% Load cropped_NewParcImage and start buliding 4D image
NewParcCrop = niftiRead(cropped_NewParcImage);
[X, Y, Z] = size(NewParcCrop.data);

ConnectomeImage = zeros([X, Y, Z, length(TargInds)]);
for i=length(TargInds)+1:size(M,2)
    ind = find(NewParcCrop.data==i);
    [xx,yy,zz] = ind2sub([X, Y, Z],ind);
    ConnectomeImage(xx,yy,zz,:) = squeeze(M(:,i));
end

if(numel(NewParcCrop.pixdim)>3), TR = NewParcCrop.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(int16(ConnectomeImage), NewParcCrop.sto_xyz, OutPath, 1, '', [],[],[],[], TR);


