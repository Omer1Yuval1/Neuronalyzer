classdef MyDatastore_Im2Im < matlab.io.Datastore & matlab.io.datastore.Partitionable
	
	methods
		function subds = partition(myds,n,ii)
			subds = copy(myds);
			subds.FileSet = partition(myds.FileSet,n,ii);
			reset(subds);         
		end
	end
	
	methods (Access = protected)
		function n = maxpartitions(myds)
			n = maxpartitions(myds.FileSet);
		end
	end
end