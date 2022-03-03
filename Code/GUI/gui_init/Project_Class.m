classdef Project_Class < handle
    
	properties
		Data
		GUI_Handles
	end
    
    methods
        function obj = Project_Class() % Constructor.
			obj.Data = struct('Segments',{},'Vertices',{},'Points',{},'Axes',{},'Parameters',{},'Info',{});
			obj.GUI_Handles = struct();
        end
		
		function S = project_init(obj)
			ff = fieldnames(obj.Data)';
			ff{2,1} = {};
			S = struct(ff{:}); % Create an empty struct with the same fields as in obj.Data.
			
			S(1).Parameters = Parameters_Func(1);
			S(1).Info = struct('Experiment',{},'Analysis',{},'Files',{});
			
			S(1).Info(1).Experiment = struct('Identifier',{},'Username',{},'Neuron_Name',{},'Strain_Name',{},'Scale_Factor',{},'Age',{},'Strain',{},'Sex',{},'Genotype',{},'Phenotype',{},'Anesthetics',{},'Fixation',{},'Camera',{},'Magnification',{},'Date',{},'Temperature',{},'Time',{});
			S.Info.Analysis = struct('Commit',{},'Date',{},'Username',{});
			S.Info.Files = struct('Raw_Image',{},'Denoised_Image',{},'Binary_Image',{});
			
			S.Info.Experiment(1).Scale_Factor = 1;
			
			% The second row is used for units:
			S.Info.Experiment(2).Date = 'YYYYMMDD';
			S.Info.Experiment(2).Temperature = '°C';
			S.Info.Experiment(2).Scale_Factor = 'µm/px';
			S.Info.Experiment(2).Duration = 'seconds';
			S.Info.Experiment(2).Time = 'hh:mm:ss';
			
			S.Info.Analysis(1).Commit = [];
			S.Info.Analysis(2).Date = 'YYYYMMDD';
			
			S.Parameters.General_Parameters.Pixel_Limits = [0,255];
		end
    end
end