function Output1 = Order_Index_Conversion(Input1,Direction1)
	
	if(Direction1 == 1) % Convert Order to Index.
		Output1 = 2*Input1 - 1;
	elseif(Direction1 == -1) % Convert Index to Order.
		Output1 = (Input1 + 1) / 2;			
	end
	
end