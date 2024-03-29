function Project = Workspace_To_Project(Workspace)
	
	Project = struct('Segments',{},'Vertices',{},'Points',{},'Neuron_Axes',{},'Parameters',{},'Info',{});
	for w=1:numel(Workspace) % For each Project.
		
		Project(w).Segments = Workspace(w).Workspace.Segments;
		Project(w).Vertices = Workspace(w).Workspace.Vertices;
		Project(w).Points = Workspace(w).Workspace.All_Points;
		Project(w).Neuron_Axes = Workspace(w).Workspace.Neuron_Axes;
		Project(w).Parameters = Workspace(w).Workspace.Parameters;
		
		Project(w).Info(1).Experiment = struct('Identifier',{},'Username',{},'Neuron_Name',{},'Strain_Name',{},'Scale_Factor',{},'Age',{},'Strain',{},'Sex',{},'Genotype',{},'Phenotype',{},'Anesthetics',{},'Fixation',{},'Camera',{},'Magnification',{},'Date',{},'Temperature',{},'Time',{});
		
        if(isfield(Workspace(w).Workspace.User_Input,'File_Name'))
            Project(w).Info.Experiment(1).Identifier = Workspace(w).Workspace.User_Input.File_Name(1:end-4);
        end
		
        Project(w).Info.Experiment(1).Username = 'AF';
		Project(w).Info.Experiment.Neuron_Name = 'PVD';
		Project(w).Info.Experiment.Age = Workspace(w).Workspace.User_Input.Features.Age;
		Project(w).Info.Experiment.Scale_Factor = Workspace(w).Workspace.User_Input.Scale_Factor;
		Project(w).Info.Experiment.Strain_Name = Workspace(w).Workspace.User_Input.Features.Genotype; % wt = BP709. git-1 = BP1054.
		Project(w).Info.Experiment.Strain = Workspace(w).Workspace.User_Input.Features.Strain; % wt = BP709. git-1 = BP1054.
		Project(w).Info.Experiment.Sex = 'Hermaphrodite';
		Project(w).Info.Experiment.Genotype = ''; % git = git-1 (ok1848).
		Project(w).Info.Experiment.Phenotype = '';
		Project(w).Info.Experiment.Temperature = '20';
		
		Project(w).Info.Experiment.Anesthetics = '0.1% tricaine and 0.01% tetramisole in M9 solution for 20-30 minutes';
		Project(w).Info.Experiment.Fixation = '';
		Project(w).Info.Experiment.Camera = 'iXon EMCCD (Andor)';
		Project(w).Info.Experiment.Magnification = 'x40';
		
		Project(w).Info.Experiment(2).Date = 'YYYYMMDD';
		Project(w).Info.Experiment(2).Temperature = '°C';
		Project(w).Info.Experiment(2).Scale_Factor = 'µm/px';
		Project(w).Info.Experiment(2).Duration = 'seconds';
		Project(w).Info.Experiment(2).Time = 'hh:mm:ss';
		
		Project(w).Info.Analysis = struct('Version',{},'Commit',{},'Date',{},'Username',{});
		Project(w).Info.Analysis(1).Version = 'V2.0.0';
		Project(w).Info.Analysis(1).Commit = 'c6725c3';		
		Project(w).Info.Analysis.Username = 'YI';
		Project(w).Info.Analysis(2).Date = 'YYYYMMDD';
		
		Project(w).Info.Files = struct('Raw_Image',{},'Denoised_Image',{},'Binary_Image',{});
		Project(w).Info.Files(1).Raw_Image = Workspace(w).Workspace.Image0;
		
        if(isfield(Workspace(w).Workspace,'NN_Probabilities'))
            Project(w).Info.Files(1).Denoised_Image = Workspace(w).Workspace.NN_Probabilities;
        end
		
        if(isfield(Workspace(w).Workspace,'Im_BW'))
            Project(w).Info.Files(1).Binary_Image = Workspace(w).Workspace.Im_BW;
        end
	end
end