classdef imageRegressionDatastore < matlab.io.Datastore & matlab.io.datastore.Shuffleable & matlab.io.datastore.Partitionable
    
    properties
        Datastore
        Labels
        ReadSize
        InputSize
        Type
    end
    
    properties(SetAccess = protected)
        NumObservations
    end
    
    properties(Access = private)
        CurrentFileIndex
    end
    
    methods
        function ds = imageRegressionDatastore(folder,inputSize,ext,InOut)
			% function ds = imageRegressionDatastore(folder,labels,inputSize)
            % creates a datastore from the data in folder and labels
            
            % Create file datastore
            fds = imageDatastore(folder,'IncludeSubfolders',true,'FileExtensions',ext);
            ds.Datastore = fds;
            
            numObservations = numel(fds.Files);
            
            % Labels:
			% ds.Labels = labels;
            
            % Initialize datastore properties.
            ds.ReadSize = 1;
            ds.NumObservations = numObservations;
            ds.CurrentFileIndex = 1;
            ds.InputSize = inputSize;
			ds.Type = InOut;
        end
        
        function tf = hasdata(ds)
            % tf = hasdata(ds) returns true if more data is available.
            
            tf = ds.CurrentFileIndex + ds.ReadSize - 1 <= ds.NumObservations;
        end
        
        function [data,info] = read(ds)
			% [data,info] = read(ds) read one mini-batch of data.
			
            miniBatchSize = ds.ReadSize;
            info = struct;
			
			for i=1:miniBatchSize
				predictors{i,1} = imresize(read(ds.Datastore), ds.InputSize);
				% responses{i,1} = ds.Labels(ds.CurrentFileIndex,:);
				ds.CurrentFileIndex = ds.CurrentFileIndex + 1;
			end
			
			data = table(predictors);
			data.Properties.VariableNames = ds.Type;
		end
		
		function reset(ds)
			% reset(ds) resets the datastore to the start of the data.          
			reset(ds.Datastore);
			ds.CurrentFileIndex = 1;
        end
        
        function dsNew = shuffle(ds)
            % dsNew = shuffle(ds) shuffles the files and the corresponding
            % labels in the datastore.
            
            % Create copy of datastore.
            dsNew = copy(ds);
            dsNew.Datastore = copy(ds.Datastore);
            fds = dsNew.Datastore;
            
            % Shuffle files and corresponding labels.
            numObservations = dsNew.NumObservations;
            idx = randperm(numObservations);
            fds.Files = fds.Files(idx);
            % dsNew.Labels = dsNew.Labels(idx,:);
        end
        
        function subds = partition(ds, numPartitions, idx)
            subds = copy(ds);            
            subds.Datastore = partition(ds.Datastore, numPartitions, idx);
            subds.NumObservations = numel(subds.Datastore.Files);
            indices = pigeonHole(idx, numPartitions, ds.NumObservations);
            % subds.Labels = ds.Labels(indices,:); 
            reset(subds);
        end
    end
    
    methods(Access = protected)
        function n = maxpartitions(ds)
            n = ds.NumObservations;
        end
    end
    
    methods (Hidden = true)
        function frac = progress(ds)
            % frac = progress(ds) returns the percentage of observations
            % read in the datastore.
            
            frac = (ds.CurrentFileIndex - 1) / ds.NumObservations;
        end
    end
end

function observationIndices = pigeonHole(partitionIndex, numPartitions, numObservations)
	% pigeonHole Helper function that maps partition index and numpartitions
	% to the corresponding observation indices.
    observationIndices = floor((0:numObservations - 1) * numPartitions / numObservations) + 1;    
    observationIndices = find(observationIndices == partitionIndex);
    % Convert to a vector if observationIndices is empty.
    if isempty(observationIndices)
        observationIndices = double.empty(0,1);
    end
end