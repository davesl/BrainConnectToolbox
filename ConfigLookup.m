function LookupLabels = ConfigLookup(ParcConfigFile,LookupInds)


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
for i=1:length(LookupInds)
    ParcInd = find(str2double(ParcConfig(:,1))==LookupInds(i));
    LookupLabels{i,1}= str2double(ParcConfig(ParcInd,1));
    LookupLabels{i,2}=char(ParcConfig(ParcInd,2));
end
