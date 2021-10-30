function Tags_Struct = TIF_Init(Image_Size)
	
	Tile_Size = 64;
	
	Tags_Struct.ImageWidth = Image_Size(1);
	Tags_Struct.ImageLength = Image_Size(2);
	Tags_Struct.Photometric = Tiff.Photometric.MinIsBlack;
	Tags_Struct.BitsPerSample = 8;
	Tags_Struct.SamplesPerPixel = 1;
	Tags_Struct.TileLength = Tile_Size;
	Tags_Struct.TileWidth = Tile_Size;
	Tags_Struct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

end