function [Genotype,Strain,Crowding] = Define_Groups_Categories()
	
	% Genotype:
	Genotype = struct('Index',{},'Name',{});
	Genotype(1).Index = 1;
	Genotype(1).Name = 'WT';
	Genotype(2).Index = 2;
	Genotype(2).Name = 'asic-1';
	Genotype(3).Index = 3;
	Genotype(3).Name = 'mec-10';
	Genotype(4).Index = 4;
	Genotype(4).Name = 'degt-1';
	Genotype(5).Index = 5;
	Genotype(5).Name = 'asic-1;mec-10';
	Genotype(6).Index = 6;
	Genotype(6).Name = 'asic-1;degt-1';
	Genotype(7).Index = 7;
	Genotype(7).Name = 'mec-10;degt-1';
	Genotype(8).Index = 8;
	Genotype(8).Name = 'asic-1;mec-10;degt-1';


	% Strain:
	Strain = struct('Index',{},'Name',{});
	Strain(1).Index = 1;
	Strain(1).Name = '';
	Strain(2).Index = 2;
	Strain(2).Name = 'BP1023';
	Strain(3).Index = 3;
	Strain(3).Name = 'BP1022';
	Strain(4).Index = 4;
	Strain(4).Name = 'BP1027';
	Strain(5).Index = 5;
	Strain(5).Name = 'BP1024';
	Strain(6).Index = 6;
	Strain(6).Name = 'BP1028';
	Strain(7).Index = 7;
	Strain(7).Name = 'BP1029';
	Strain(8).Index = 8;
	Strain(8).Name = 'BP1030';
	
	% Crowding:
	Crowding = struct('Index',{},'Name',{});
	Crowding(1).Index = 1;
	Crowding(1).Name = 'Crowded';
	Crowding(2).Index = 2;
	Crowding(2).Name = 'Isolated';
end