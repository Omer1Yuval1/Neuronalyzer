Dir1 = uigetdir; % Let the user choose a directory.
Files_List = dir(Dir1); % List of files names.
Files_List(find([Files_List.isdir])) = [];

i = 4;
for d=1:numel(Files_List)
	F1 = strfind(Files_List(d).name,'Source');
    F2 = strfind(Files_List(d).name,'Annotated');
	
    if(length(F1))
        New_Name = [num2str(i),'_GS_',Files_List(d).name(1:F1(1)-2),Files_List(d).name(end-4:end)];
        movefile([Files_List(d).folder,filesep,Files_List(d).name],[Files_List(d).folder,filesep,New_Name]);
    end
    if(length(F2))
        New_Name = [num2str(i),'_BW_',Files_List(d).name(1:F2(1)-2),Files_List(d).name(end-4:end)];
        movefile([Files_List(d).folder,filesep,Files_List(d).name],[Files_List(d).folder,filesep,New_Name]);
    end
    
    i = i + 1;
end