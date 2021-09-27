%setroipoints.m by S. Watanabe

%new method 150623


function setroipoints_circle(imgdisp, roinum, linemode) %imgdisp - imagedisp object

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
 	xinit = 0;
 	yinit = 0;

	function buttonupf(src, evnt)
		axh = get(figh, 'CurrentAxes');
		n = n +1;

		cp = get(axh, 'CurrentPoint');
		roipt(n, 1) = cp(1,1);
		roipt(n, 2) = cp(1,2);
		
		xinit = cp(1,1);
		yinit = cp(1,2);

		
		if n == 2
			radius = sqrt(diff(roipt(:,1))^2 + diff(roipt(:,2))^2);
		else
			radius = 0.001;
		end
			
		if linemode >=1
			hl = rectangle('Position', [roipt(1,1)-radius, roipt(1,2)-radius, 2*radius, 2*radius], 'Curvature', 1, 'EdgeColor', 'm');
			drawnow
		end
		
		
		if strcmp(get(src,'SelectionType'), 'normal') && (n ~= maxpt) %left button
			set(src,'WindowButtonMotionFcn',@wbuttonmotionf)
		end
		
		if strcmp(get(src,'SelectionType'), 'alt') || (strcmp(get(src,'SelectionType'), 'normal') && n ==maxpt ) %right button
			
			if n > 2 && linemode >=1
				hl = rectangle('Position', [roipt(1,1)-radius, roipt(1,2)-radius, 2*radius, 2*radius], 'Curvature', 1, 'EdgeColor', 'm');
			end
			
			set(src,'WindowButtonMotionFcn', '')
			set(src,'WindowButtonUpFcn', '')
			set(figh, 'KeyPressFcn', '');

			set(src,'Pointer', 'arrow')

			imgdisp.roi{roinum}.pt = roipt(1,:);
			imgdisp.roi{roinum}.radius = radius;
			
			imgdisp.roistatus.completed = 1;

			uiresume(figh);
				
			axh = get(figh, 'CurrentAxes');
		end		
		
		
		function wbuttonmotionf(src, evnt)
			axh = get(figh, 'CurrentAxes');

			if linemode==2 %live mode
				cp = get(axh, 'CurrentPoint');
				radius = sqrt((cp(1,1)-roipt(1,1))^2 + (cp(1,2)-roipt(1,2))^2);
				set(hl, 'Position', [roipt(1,1)-radius, roipt(1,2)-radius, 2*radius, 2*radius]); drawnow
			end
		
		end

	end

	
end



