function [jObj,hjObj,hContainer] = Display_Wait_Animation(OnOff,jObj,hjObj,hContainer)

	if(OnOff == 1)
		try
			iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
			iconsSizeEnums = javaMethod('values',iconsClassName);
			SIZE_32x32 = iconsSizeEnums(2);  % (1) = 16x16,  (2) = 32x32
			jObj = com.mathworks.widgets.BusyAffordance(SIZE_32x32, 'Loading...');  % icon, label
		end
		jObj.setPaintsWhenStopped(true);  % default = false
		jObj.useWhiteDots(false);         % default = false (true is good for dark backgrounds)
		[hjObj,hContainer] = javacomponent(jObj.getComponent,[1000,500,150,150],gcf);
		set(hContainer,'Units','norm');
		jObj.start;
	else	
		% jObj.stop;
		% jObj.setBusyText('Done!');
		delete(hContainer);
		% delete(hjObj);
		% jObj.getComponent.setVisible(false);		
	end
	
end