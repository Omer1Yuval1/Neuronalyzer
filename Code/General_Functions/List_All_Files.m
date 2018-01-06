function Files_List = List_All_Files(Dir1,Ext)
	Files_List = dir([Dir1,filesep,'**',filesep,'*.',Ext]);
end