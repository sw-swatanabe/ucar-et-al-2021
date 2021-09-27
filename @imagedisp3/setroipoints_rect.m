%setroipoints.m by S. Watanabe

%updated 091228


function setroipoints_rect(imgdisp, roinum, linemode) %imgdisp - imagedisp object

	maxpt = 2;
	linemode = 2;

	
	figh = imgdisp.figh;
	
	axh = get(figh, 'CurrentAxes');
	xlim = get(axh, 'XLim');
	ylim = get(axh, 'YLim');


	set(figh, 'WindowButtonUpFcn', @buttonupf)
% 	set(figh, 'KeyPressFcn', @setroikeypressf);

%	axes(axh, 'DrawMode', 'fast');
	
	set(figh, 'pointer', 'crosshair')

	roipt = [];
	n = 0;

	
	%the following lines are necessary for these variables to be accessible by the subfunctions
% 	imgdisp.nroipt(roinum) = 0;
% 	imgdisp.show_roinum(roinum) = 1;
% 	imgdisp.selectedroi(roinum) = 0;

	%imgdisp.roipt(:, :, roinum) = 0;
	
	%the following lines are necessary for these variables to be accessible by the subfunctions
 	xinit = 0;
 	yinit = 0;

	
% 	function setroikeypressf(src, evnt) %this should be moved to setroipoints functions
% 		switch evnt.Key
% 			case 'escape'
% 				set(src,'WindowButtonMotionFcn', '')
% 				set(src,'WindowButtonUpFcn', '')
% 				set(figh, 'KeyPressFcn', '');
% 				
% 				set(src,'Pointer', 'arrow')
% 				
% 				%imgdisp.continueroisetting = 0;
% 				imgdisp.roistatus.continue = 0;
% 				uiresume(figh);
% 		
% 			case 'delete'
% 				%imgdisp.deleteselectedroi = 1;
% 				imgdisp.roistatus.delete = 1;
% 				
% 				uiresume(figh);
% 		end
% 	end

	function buttonupf(src, evnt)
		axh = get(figh, 'CurrentAxes');
		n = n +1;

		cp = get(axh, 'CurrentPoint');
		roipt(n, 1) = cp(1,1);
		roipt(n, 2) = cp(1,2);
		
		xinit = cp(1,1);
		yinit = cp(1,2);

		
		if n > 1
			xdat = [roipt(n-1,1), roipt(n-1,1), cp(1,1), cp(1,1), roipt(n-1,1)];
			ydat = [roipt(n-1,2), cp(1,2), cp(1,2), roipt(n-1,2), roipt(n-1,2)];
		else
			xdat = cp(1,1);
			ydat = cp(1,2);
		end
			
		
		if linemode >=1
			hl = line('XData', xdat, 'YData', ydat, 'Marker', '.', 'MarkerSize', 5, 'color', 'm');
			drawnow
		end
		
		
		if strcmp(get(src,'SelectionType'), 'normal') && (n ~= maxpt) %left button
			set(src,'WindowButtonMotionFcn',@wbuttonmotionf)
		end
		
		if strcmp(get(src,'SelectionType'), 'alt') || (strcmp(get(src,'SelectionType'), 'normal') && n ==maxpt ) %right button
			
			if n > 2 && linemode >=1
			%	hl = line('XData', xinit, 'YData', yinit, 'Marker', '.', 'MarkerSize', 5, 'color', 'm');
%  				xdat = [xinit, imgdisp.roipt(1,1, roinum)];
%  				ydat = [yinit, imgdisp.roipt(1,2, roinum)];
% 				xdat = [xinit, roipt(1,1)];
%  				ydat = [yinit, roipt(1,2)];
				xdat = [xinit, xinit, cp(1,1), cp(1,1), xinit];
				ydat = [yinit, cp(1,2), cp(1,2), yinit, yinit];
			%	set(hl, 'XData', xdat, 'YData', ydat); drawnow
				hl = line('XData', xdat, 'YData', ydat, 'Marker', '.', 'MarkerSize', 5, 'color', 'm');
			end
			
			set(src,'WindowButtonMotionFcn', '')
			set(src,'WindowButtonUpFcn', '')
			set(figh, 'KeyPressFcn', '');

			set(src,'Pointer', 'arrow')


% 			imgdisp.nroipt(roinum) = n;
% 			imgdisp.roitype{roinum} = 'rect';
% 			imgdisp.roipt{roinum} = roipt;
			imgdisp.roi{roinum}.pt = roipt;
% 			imgdisp.show_roinum(roinum) = 1;
% 			imgdisp.selectedroi(roinum) = 1;
			
			%imgdisp.roisettingcompleted = 1;
			imgdisp.roistatus.completed = 1;

			uiresume(figh);
				
			axh = get(figh, 'CurrentAxes');
		end		
		
		
		function wbuttonmotionf(src, evnt)
			axh = get(figh, 'CurrentAxes');

			if linemode==2 %live mode
				cp = get(axh, 'CurrentPoint');
				xdat = [xinit, xinit, cp(1,1), cp(1,1), xinit];
				ydat = [yinit, cp(1,2), cp(1,2), yinit, yinit];
			
				set(hl, 'XData', xdat, 'YData', ydat); drawnow
			end
		
		end

	end

	
end



