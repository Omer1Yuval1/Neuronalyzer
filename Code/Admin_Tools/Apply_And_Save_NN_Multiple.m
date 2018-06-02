Dir1 = uigetdir; % Let the user choose a source directory.
Dir2 = uigetdir; % Let the user choose a target directory.
Files_List = dir(Dir1); % List of files names.
Files_List(find([Files_List.isdir])) = [];

for f=1:numel(Files_List)
    [deepnet,y,Test_Frames,Test_Classes]= NN_Index('HiddenX3_CNN');
    Im0 = imread([Files_List(d).folder,filesep,Files_List(d).name]);
    NN_Probabilities = Apply_Trained_Network(deepnet,Im0);
    imwrite(Im0,[Dir2,filesep,Files_List(d).name]);
end