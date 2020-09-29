function Set_Objects(P)
	
	P.GUI_Handles(1).Main_Figure = figure(12);
	clf(P.GUI_Handles.Main_Figure);
	set(P.GUI_Handles.Main_Figure,'WindowState','maximized','Color',[.2,.2,.2]);
	
	dp = 0.005;
	
	P.GUI_Handles.Main_Panel_1 = uipanel(P.GUI_Handles.Main_Figure,'Units','Normalized','Position',[0+dp,.3+dp,1-2*dp,.7-3*dp],'BackgroundColor',P.GUI_Handles.BG_Color_1);
	
	P.GUI_Handles.Buttons_Panel = uipanel(P.GUI_Handles.Main_Figure,'Units','Normalized','Position',[0+dp,.075+dp,0.3-dp,.225-2*dp],'BackgroundColor',P.GUI_Handles.BG_Color_1);
	P.GUI_Handles.Control_Pnael = uipanel(P.GUI_Handles.Main_Figure,'Units','Normalized','Position',[0.3+dp,.075+dp,0.45-dp,.225-2*dp],'BackgroundColor',P.GUI_Handles.BG_Color_1);
	P.GUI_Handles.Info_Panel = uipanel(P.GUI_Handles.Main_Figure,'Units','Normalized','Position',[0.75+dp,.075+dp,0.25-2*dp,.225-2*dp],'BackgroundColor',P.GUI_Handles.BG_Color_1);
	
	P.GUI_Handles.Steps_Panel = uipanel(P.GUI_Handles.Main_Figure,'Units','Normalized','Position',[0+dp,0+dp,1-2*dp,0.075-2*dp],'BackgroundColor',P.GUI_Handles.BG_Color_1);
	
	P.GUI_Handles.Menus = gobjects(1,length(P.GUI_Handles.Menu_Names));
	for m=1:length(P.GUI_Handles.Menu_Names)
		P.GUI_Handles.Menus(m) = uimenu(P.GUI_Handles.Main_Figure,'Text',P.GUI_Handles.Menu_Names{m});
	end
	Set_Reconstructions_Menu(P);
	Set_Plots_Menu(P);
	
	% Control panel:
	N = 3;
	dmx = 0.025;
	dmy = 0.05;
	Lx = 1-2*dmx;
	Ly = 1-2*dmy;
	dx = 0.1 .* Lx; % Sum of spaces between buttons.
	dy = 0.25 .* Ly; % ".
	x = (Lx-dx) ./ N; % Button width.
	y = (Ly-dy) ./ N; % Button height.
	P.GUI_Handles.Buttons = gobjects(N,N);
	for i=1:N
		for j=1:N
			py = dmy + (y+dy/(N-1)).*(i-1);
			px = dmx + (x+dx/(N-1)).*(j-1);
			P.GUI_Handles.Buttons(N-i+1,j) = uicontrol(P.GUI_Handles.Buttons_Panel,'Style','pushbutton','String',P.GUI_Handles.Buttons_Names{N-i+1,j},'Units','Normalized','Position',[px,py,x,y],'FontSize',P.GUI_Handles.Buttons_FontSize);
		end
	end
	set(P.GUI_Handles.Buttons(1,1),'Backgroundcolor',P.GUI_Handles.Step_BG_Before);
	set(P.GUI_Handles.Buttons(1,2),'Backgroundcolor',P.GUI_Handles.Step_BG_Before);
	set(P.GUI_Handles.Buttons(3,1),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'ForegroundColor',[1,1,1]);
	set(P.GUI_Handles.Buttons(3,2),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'ForegroundColor',[1,1,1]);
	set(P.GUI_Handles.Buttons(3,3),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'ForegroundColor',[1,1,1]);
	
	Ny = 4;
	dmy = 0.05;
	Ly = 1-2*dmy;
	dy = 0.2 .* Ly; % Sum of spaces between buttons.
	y = (Ly-dy) ./ Ny; % Button height.
	lx = 0.25;
	px = [0.02,0.29,[0.5,0.65,0.85]-0.05];
	P.GUI_Handles.Control_Panel_Objects = gobjects(4,5);
	P.GUI_Handles.Radio_Group_1 = uibuttongroup(P.GUI_Handles.Control_Pnael,'BackgroundColor',P.GUI_Handles.BG_Color_1,'BorderType','none');
	for i=1:4
		py = dmy + (y+dy/(Ny-1)).*(4-i);
		
		P.GUI_Handles.Control_Panel_Objects(i,1) = uicontrol(P.GUI_Handles.Control_Pnael,'Style','checkbox','Units','Normalized','Position',[px(1),py,lx,y],'ForegroundColor',[1,1,1],'Backgroundcolor',P.GUI_Handles.BG_Color_1,'FontSize',12,'String',['Checkbox Text',num2str(i)],'Enable','off');
		P.GUI_Handles.Control_Panel_Objects(i,2) = uicontrol(P.GUI_Handles.Radio_Group_1,'Style','radio','UserData',i,'Units','Normalized','Position',[px(2),py,0.15,y],'ForegroundColor',[1,1,1],'Backgroundcolor',P.GUI_Handles.BG_Color_1,'FontSize',12,'String',['Radio ',num2str(i)],'Enable','off');
		
		P.GUI_Handles.Control_Panel_Objects(i,3) = uicontrol(P.GUI_Handles.Control_Pnael,'Style','text','Units','Normalized','Position',[px(3),py*0.96,0.15,y],'ForegroundColor',[1,1,1],'Backgroundcolor',P.GUI_Handles.BG_Color_1,'FontSize',12,'HorizontalAlignment','left','String','Placeholder:');
		
		if(i == 1)
			P.GUI_Handles.Control_Panel_Objects(i,4) = uicontrol(P.GUI_Handles.Control_Pnael,'Style','slider','Units','Normalized','Position',[px(4),py,0.18,y],'Enable','off');
			P.GUI_Handles.Control_Panel_Objects(i,5) = uicontrol(P.GUI_Handles.Control_Pnael,'Style','edit','String','1','Units','Normalized','Position',[px(5),py,0.18,y],'FontSize',12,'Enable','off','HorizontalAlignment','center');
		else
			P.GUI_Handles.Control_Panel_Objects(i,4) = uicontrol(P.GUI_Handles.Control_Pnael,'Style','popupmenu','String',{'Option 1'},'Units','Normalized','Position',[px(4),py,0.18,y],'Enable','off','FontSize',12);
			P.GUI_Handles.Control_Panel_Objects(i,5) = uicontrol(P.GUI_Handles.Control_Pnael,'Style','popupmenu','String',{'Option 1'},'Units','Normalized','Position',[px(5),py,0.18,y],'Enable','off','FontSize',12);
		end
	end
	set(P.GUI_Handles.Control_Panel_Objects(1,3),'String','Bin size:');
	set(P.GUI_Handles.Control_Panel_Objects(2,3),'String','Statistics:');
	set(P.GUI_Handles.Control_Panel_Objects(3,3),'String','Normalization:');
	set(P.GUI_Handles.Control_Panel_Objects(4,3),'String','Plot type:');
	
	set(P.GUI_Handles.Control_Panel_Objects(1,1),'String','Selected project only');
	set(P.GUI_Handles.Control_Panel_Objects(2,1),'String','Projection correction');
	
	% Step Buttons:
	N = length(P.GUI_Handles.Step_Buttons_Names);
	dmx = 0.01;
	dmy = 0.15;
	Lx = 1-2*dmx; % Total x-length to use.
	dW = 0.1 .* Lx; % Sum of spaces between buttons.
	W = (Lx-dW) ./ N; % Button width.
	P.GUI_Handles.Step_Buttons = gobjects(1,length(P.GUI_Handles.Step_Buttons_Names));
	for i=1:length(P.GUI_Handles.Step_Buttons_Names)
		px = dmx + (W + dW/(N-1)).*(i-1);
		P.GUI_Handles.Step_Buttons(i) = uicontrol(P.GUI_Handles.Steps_Panel,'Style','pushbutton','Units','Normalized','Position',[px,dmy,W,1-2*dmy],'UserData',i-1,'FontSize',P.GUI_Handles.Buttons_FontSize,'String',P.GUI_Handles.Step_Buttons_Names{i},'Backgroundcolor',P.GUI_Handles.Step_BG_Before,'Enable','on');
	end
	set(P.GUI_Handles.Step_Buttons(1),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'ForegroundColor',[1,1,1]);
	set(P.GUI_Handles.Step_Buttons(end),'Backgroundcolor',P.GUI_Handles.Button_BG_Neurtral,'ForegroundColor',[1,1,1],'Enable','on');
	
	% Info panel
	Info_Tab_Group = uitabgroup(P.GUI_Handles.Info_Panel);
    drawnow;
	Info_Tab_Group.Units = 'Pixels';
    Info_Tabs = gobjects(1,length(P.GUI_Handles.Info_Fields_List));
	Info_Panels = gobjects(1,length(P.GUI_Handles.Info_Fields_List));
	P.GUI_Handles.Info_Tables = gobjects(1,length(P.GUI_Handles.Info_Fields_List));
	
	for t=1:length(Info_Tabs)
		Info_Tabs(t) = uitab(Info_Tab_Group,'Title',P.GUI_Handles.Info_Fields_List{t});
		Info_Panels(t) = uipanel(Info_Tabs(t),'BackgroundColor',P.GUI_Handles.BG_Color_1);
        drawnow;
        Info_Panels(t).Units = 'Pixels';
        W = Info_Panels(t).Position(3);
		P.GUI_Handles.Info_Tables(t) = uitable(Info_Panels(t),'Data',cell(10,3),'UserData',t,'Position',Info_Panels(t).InnerPosition,'ColumnWidth',{W.*0.35,W.*0.35,W.*0.24},'ColumnEditable',[false,true,true],'RowName',[],'ColumnName',[],'ForegroundColor','w','BackgroundColor',P.GUI_Handles.BG_Color_1,'FontSize',P.GUI_Handles.Buttons_FontSize);
	end
end