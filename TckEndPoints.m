function TckEndPoints(tckPath,OutPath)
% Function to read in an mrtrix .tck streamline file and output the end
% points of all streamlines.
% 
% tckPath = full path to .tck file
% OutPath = full path to save output .txt file

tracks = read_mrtrix_tracks(tckPath);

Ends = zeros(length(tracks.data),6);

for i=1:length(tracks.data)
    
    X = tracks.data{i};
    
    Ends(i,:) = [X(1,:) X(end,:)];
    
end

fileID = fopen(OutPath,'w');
fprintf(fileID,'%4.2f %4.2f %4.2f %4.2f %4.2f %4.2f\n',Ends);
fclose(fileID);


