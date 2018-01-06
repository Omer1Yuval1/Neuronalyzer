function [Clusters_Indices,Clusters_Centroids] = Cluster_Data(Data_Mat,Algorithm_Name,Clusters_Vector)
	
	switch Algorithm_Name
		case 'k-means'
			eva = evalclusters(Data_Mat,'kmeans','silhouette','KList',Clusters_Vector);
			[Clusters_Indices,Clusters_Centroids] = kmeans(Data_Mat,eva.OptimalK);
		case 'Gaussian Mixture'
			eva = evalclusters(Data_Mat,'gmdistribution','silhouette','KList',Clusters_Vector);
			Clusters_Object = fitgmdist(Data_Mat,eva.OptimalK);
			Clusters_Indices = cluster(Clusters_Object,Data_Mat);
			Clusters_Centroids = 0;
		case 'Linkage'
			eva = evalclusters(Data_Mat,'linkage','silhouette','KList',Clusters_Vector);
			d = pdist(Data_Mat);
			Clusters_Object = linkage(d);
			Clusters_Indices = cluster(Clusters_Object,'maxclust',eva.OptimalK);
			Clusters_Centroids = 0;
		end
end