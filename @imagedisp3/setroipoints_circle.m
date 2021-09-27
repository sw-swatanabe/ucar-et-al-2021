%setroipoints_circle.m by S. Watanabe

%updated 091228


function setroipoints_circle(imgdisp, roinum, varargin) %imgdisp - imagedisp object

	linemode = 2;
	
	if length(varargin) ==1
		switch varargin{1}
			case 'normal'
				linemode = 1;
			case 'live'
				linemode = 2;
		end
    end
    
    figh = imgdisp.figh;
	
% 	axh = get(figh, 'CurrentAxes');
	axh = imgdisp.imageaxh;
	
% 	xlim = get(axh, 'XLim');
% 	ylim = get(axh, 'YLim');

%	axes(axh, 'DrawMode', 'fast');
	
	radius = imgdisp.roiradiusinit;
	diameter = radius *2;

	cp = get(imgdisp.imageaxh, 'CurrentPoint');


    % 	ch = rectangle('Position', [-diameter, -diameter, diameter, diameter], 'Curvature', [1,1], 'EdgeColor', 'm');
% 	ch = rectangle('Position', [0, 0, diameter, diameter], 'Curvature', [1,1], 'EdgeColor', 'm');
	ch = rectangle('Position',  [cp(1,1)-radius, cp(1,2)-radius, diameter, diameter], 'Curvature', [1,1], 'EdgeColor', 'm');
    
	set(figh, 'pointer', 'crosshair')
	set(figh, 'WindowButtonUpFcn', @buttonupf)
	set(figh,'WindowButtonMotionFcn',@wbuttonmotionf)

	set(figh, 'WindowScrollWheelFcn', '')
	set(figh, 'WindowScrollWheelFcn', @wscrollwheelf)

% 	set(figh, 'KeyPressFcn', @setroikeypressf);


	%the following lines are necessary for these variables to be accessible by the subfunctions
%	imgdisp.nroipt(roinum) = 0;
% 	imgdisp.show_roinum(roinum) = 1;
% 	imgdisp.selectedroi(roinum) = 0;

%	imgdisp.roipt(:, :, roinum) = 0;
	
	xinit = 0;
	yinit = 0;
	
	
% 	function setroikeypressf(src, evnt) %this should be moved to setroipoints functions
% 		switch evnt.Key
% 			case 'escape'
% 				set(src,'WindowButtonUpFcn', '')
% 				set(figh,'WindowButtonMotionFcn','')
% 				set(figh, 'WindowScrollWheelFcn', '')
% 				
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

% 		cp = get(axh, 'CurrentPoint');
 		cp = get(imgdisp.imageaxh, 'CurrentPoint');

		imgdisp.roi{roinum}.pt = [cp(1,1), cp(1,2)];
		
		imgdisp.roi{roinum}.radius = radius;
		imgdisp.roiradiusinit = radius;
		
		
		set(src,'WindowButtonMotionFcn', '')
		set(src,'WindowButtonUpFcn', '')
% 		set(figh, 'KeyPressFcn', '');
		set(figh, 'WindowScrollWheelFcn', '')

		set(src,'Pointer', 'arrow')

		
		
		%imgdisp.roisettingcompleted = 1;
		imgdisp.roistatus.completed = 1;
		
		uiresume(figh);

	%	imgdisp.updateimage;

		axh = get(figh, 'CurrentAxes');
	end


	function wbuttonmotionf(src, evnt)
% 		axh = get(figh, 'CurrentAxes');
		axes(imgdisp.imageaxh);

        if linemode==2 %live mode
			
% 			axh = get(figh, 'CurrentAxes');
% 			cp = get(axh, 'CurrentPoint');
			cp = get(imgdisp.imageaxh, 'CurrentPoint');

			set(ch, 'Position', [cp(1,1)-radius, cp(1,2)-radius, diameter, diameter]);
%   		ch = rectangle('Position',  [cp(1,1)-radius, cp(1,2)-radius, diameter, diameter], 'Curvature', [1,1], 'EdgeColor', 'm');

            drawnow;
 		end

	end


	function wscrollwheelf(src, evnt)
		if evnt.VerticalScrollCount <0
			radius = radius +1;
		end
		if evnt.VerticalScrollCount >0
			if radius >1
				radius = radius -1;
			end
		end
		diameter = radius *2; 

% 		cp = get(axh, 'CurrentPoint');
		cp = get(imgdisp.imageaxh, 'CurrentPoint');
		set(ch, 'Position', [cp(1,1)-radius, cp(1,2)-radius, diameter, diameter]);

	%	axh = get(this.figh, 'CurrentAxes');
	end


	
end



