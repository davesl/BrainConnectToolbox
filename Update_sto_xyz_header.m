function Update_sto_xyz_header(Nii_to_change,Nii_template)

Nii1 = niftiRead(Nii_to_change);
Nii2 = niftiRead(Nii_template);

if(numel(Nii1.pixdim)>3), TR = Nii1.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(Nii1.data, Nii2.sto_xyz, Nii_to_change, 1, '', [],[],[],[], TR);