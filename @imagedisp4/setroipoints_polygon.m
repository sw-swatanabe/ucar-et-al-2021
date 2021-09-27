%setroipoints.m by S. Watanabe

%updated 091228


function setroipoints_polygon(imgdisp, roinum, maxpt, linemode) %imgdisp - imagedisp object

	if nargin <3 || isempty(maxpt)
		maxpt = 0;
	end
	if nargin <4
		linemode = 1;
	end
	
	if strcmp(linemode, 'normal')
		linemode = 1;
	end
	if strcmp(linemode, 'live')
		linemode = 2;
	end

	
	
	figh = imgdisp.figh;
	
	axh = get(figh, 'CurrentAxes');
	xlim = get(axh, 'XLim');
	ylim = get(axh, 'YLim');


	set(figh, 'WindowButtonUpFcn', @buttonupf);
	set(figh, 'KeyPressFcn', @setroikeypressf);

	
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

	function setroikeypressf(src, evnt) %this should be moved to setroipoints functions
		switch evnt.Key
			case 'escape'
				set(src,'WindowButtonMotionFcn', '')
				set(src,'WindowButtonUpFcn', '')
				set(figh, 'KeyPressFcn', '');
				
				set(src,'Pointer', 'arrow')
				
			%	imgdisp.continueroisetting = 0;
				imgdisp.roistatus.continue = 0;
				uiresume(figh);
		
			case 'delete'
			%	imgdisp.deleteselectedroi = 1;
				imgdisp.roistatus.delete = 1;
				
				uiresume(figh);
		end
	end


	function buttonupf(src, evnt)
		axh = get(figh, 'CurrentAxes');
		cp = get(axh, 'CurrentPoint');

		n = n +1;
		
		if n > 1
			xdat = [xinit, cp(1,1)];
			ydat = [yinit, cp(1,2)];
			
			if linemode >=1
				hl = line('XData', xdat, 'YData', ydat, 'Marker', '.', 'MarkerSize', 5, 'color', 'm');
				%set(hl, 'XData', xdat, 'YData', ydat); 
				drawnow
			end
		end
		
		xinit = cp(1,1);
		yinit = cp(1,2);

% 		imgdisp.roipt(n, 1, roinum) = xinit;
% 		imgdisp.roipt(n, 2, roinum) = yinit;
		
		roipt(n, 1) = xinit;
		roipt(n, 2) = yinit;
		
	
		xdat = xinit;
		ydat = yinit;
		hl = line('XData', xdat, 'YData', ydat, 'Marker', '.', 'MarkerSize', 5, 'color', 'm');
		%set(hl, 'XData', xdat, 'YData', ydat); 
		drawnow

	%	if ~noline
			if strcmp(get(src,'SelectionType'), 'normal') && (n ~= maxpt) %left button
				set(src,'WindowButtonMotionFcn',@wbuttonmotionf)
			end
	%	end
		
		if strcmp(get(src,'SelectionType'), 'alt') || (strcmp(get(src,'SelectionType'), 'normal') && n ==maxpt ) %right button
			
			if n > 2
				hl = line('XData', xinit, 'YData', yinit, 'Marker', '.', 'MarkerSize', 5, 'color', 'm');
				xdat = [xinit, roipt(1,1)];
				ydat = [yinit, roipt(1,2)];
				set(hl, 'XData', xdat, 'YData', ydat); drawnow
			end
			
			set(src,'WindowButtonMotionFcn', '')
			set(src,'WindowButtonUpFcn', '')
			set(figh, 'KeyPressFcn', '');
			
			set(src,'Pointer', 'arrow')

			imgdisp.roi{roinum}.pt = roipt;

			imgdisp.roistatus.completed = 1;

			uiresume(figh);
				

			axh = get(figh, 'CurrentAxes');
		end		
		
		
		function wbuttonmotionf(src, evnt)
			axh = get(figh, 'CurrentAxes');

			if linemode==2 %live mode
				cp = get(axh, 'CurrentPoint');
				xdat = [xinit, cp(1,1)];
				ydat = [yinit, cp(1,2)];
			
				set(hl, 'XData', xdat, 'YData', ydat); drawnow
			end
		
		end

	end

	
end



