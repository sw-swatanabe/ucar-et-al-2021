function update(this, varargin)
	nvarargin = length(varargin);

	t = this.t;
	z = this.z;

	figure(this.figh);
	clf; 

	for i=1:nvarargin

	end
	

	axh = subplot('Position', [0.0 0.25 1.0 0.7]);
	
	this.imageaxh = axh;

% 	switch this.dispmode
% 		case 'overlay'
% 			tempimage = zeros(this.sizey, this.sizex, 3);
% 			tempimage(:,:,[1 3]) = this.rgbdatars{n}(:,:, [1 3]);
% 			tempimage(:,:,2) = this.rgbdatars{1}(:,:, 2);
% 			image(tempimage);
% 
% 		case {'normal', 'endcolor'}
			image(this.rgbdatars{z,t});
% 	end


	%axis image;
	axis(this.axismode);
	axis([this.axmin this.axmax this.aymin this.aymax]);

	axis off;
	
	%backgroundedge - common image area
	rectangle('Position', [ max([this.shiftx, 0]), ...
							max([this.shifty, 0]), ...
							this.sizex+min([this.shiftx, 0])-max([this.shiftx, 0]), ...
							this.sizey+min([this.shifty, 0])-max([this.shifty, 0]) ], ...
							'Curvature', [0,0],  'EdgeColor', this.backgroundedgecolor, 'linewidth', 1);

% 	axh = gca;
	
	if this.show_title

		if this.sizet >1 || this.sizez >1
					title([this.titlestr '[ t = ' num2str(t) '/' num2str(this.sizet) ',  z = ' num2str(z) '/' num2str(this.sizez) ' ]'], 'interpreter', 'none');
		else
			title([this.titlestr], 'interpreter', 'none');
		end
		
	end

	hold on;

	if this.enable_keypress
		set(this.figh, 'KeyPressFcn',@keypressf);
	end
	if this.enable_scrollwheel
		set(this.figh, 'WindowScrollWheelFcn', @wscrollwheelf);
	end
	
	set(this.figh, 'WindowButtonUpFcn', @figclickf); %for activating the figure (and inactivating the selected roi)
%  	set(this.figh, 'WindowButtonDownFcn', @figclickf); %for activating the figure (and inactivating the selected roi)
%	set(this.figh, 'ButtonDownFcn', @figclickf); %for activating the figure (and inactivating the selected roi)

% 	axh = get(this.figh, 'CurrentAxes');


	% draw rois
	for r = this.roilist

		if this.roi{r}.selected
			rcolor = this.roicolor_selected;
		else
% 			rcolor = this.roi{r}.color;
			rcolor = this.roicolor_default;
		end

		rlinewidth = this.roi{r}.linewidth;

		switch this.roi{r}.type
			case {'polygon', 'open'}
				if this.roi{r}.npt<=2 || strcmp(this.roi{r}.type, 'open')
% 					this.plh(r) = plot(this.roi{r}.pt(:,1), this.roi{r}.pt(:,2),    'color', rcolor, 'linewidth', rlinewidth);
					this.plh(r) = plot(this.roi{r}.pt(:,1) + this.roi{r}.shiftx(t) + this.shiftx(t), this.roi{r}.pt(:,2) + this.roi{r}.shifty(t) + this.shifty(t),    'color', rcolor, 'linewidth', rlinewidth);
				else
% 					this.plh(r) = plot([this.roi{r}.pt(:,1); this.roi{r}.pt(1,1)], [this.roi{r}.pt(:,2); this.roi{r}.pt(1,2)],  'color', rcolor, 'linewidth', rlinewidth);
					this.plh(r) = plot([this.roi{r}.pt(:,1); this.roi{r}.pt(1,1)] + this.roi{r}.shiftx(t) + this.shiftx(t), ...
									   [this.roi{r}.pt(:,2); this.roi{r}.pt(1,2)] + this.roi{r}.shifty(t) + this.shifty(t),  'color', rcolor, 'linewidth', rlinewidth);
				end

				[xmin, xminix] = min(this.roi{r}.pt(:,1));

				if this.roi{r}.shownum
% 					text(this.roi{r}.pt(xminix, 1) -3, this.roi{r}.pt(xminix, 2), num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right');
					this.pltxh(r) = text(this.roi{r}.pt(xminix, 1) + this.roi{r}.shiftx(t) + this.shiftx(t) -3, ...
						 this.roi{r}.pt(xminix, 2) + this.roi{r}.shifty(t) + this.shifty(t),		num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right', 'fontsize', 11);
				end

			case 'circle'
				cx = this.roi{r}.pt(1,1);
				cy = this.roi{r}.pt(1,2);
% 				this.plh(r) = rectangle('Position', [cx - this.roi{r}.radius, cy - this.roi{r}.radius, 2*this.roi{r}.radius, 2*this.roi{r}.radius], ...
% 										'Curvature', [1,1],  'EdgeColor', rcolor, 'linewidth', rlinewidth);
				this.plh(r) = rectangle('Position', [(cx - this.roi{r}.radius + this.roi{r}.shiftx(t) + this.shiftx(t)), ...
													 (cy - this.roi{r}.radius + this.roi{r}.shifty(t) + this.shifty(t)), ...
													2*this.roi{r}.radius, 2*this.roi{r}.radius], ...
										'Curvature', [1,1],  'EdgeColor', rcolor, 'linewidth', rlinewidth);


				if this.roi{r}.shownum
% 					text(cx - this.roi{r}.radius -3, cy, num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right');
					this.pltxh(r) = text(cx - this.roi{r}.radius + this.roi{r}.shiftx(t) + this.shiftx(t) -3, ...
						 cy + this.roi{r}.shifty(t) + this.shifty(t),							num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right', 'fontsize', 11);
				end

			case 'rect'
				rx1 = min(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(t) + this.shiftx(t); 
				ry1 = min(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(t) + this.shifty(t);
				rx2 = max(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(t) + this.shiftx(t); 
				ry2 = max(this.roi{r}.pt(: ,2)) + this.roi{r}.shifty(t) + this.shifty(t);
				this.plh(r) = rectangle('Position', [rx1, ry1, rx2-rx1, ry2-ry1], ...
										'Curvature', [0,0],  'EdgeColor', rcolor, 'linewidth', rlinewidth);

				if this.roi{r}.shownum
					this.pltxh(r) = text(min(rx1,rx2) -3, min(ry1,ry2), num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right', 'fontsize', 11);
				end

		end

		set(this.plh(r), 'SelectionHighlight', 'off');

		if this.enable_roiselect
			set(this.plh(r), 'ButtonDownFcn', @roiclickf); %for activating the figure (and inactivating the selected roi)
		end


	end %for r = find(this.nroipt)


	
	% show bleach points
	%comb - nstimpt elements (numeric array)
	%compmode - number of combiner elements (cell)
	%compint - number of combiner elements (cell)
	
% 	axes(axh);
	axes(this.imageaxh);

	for bn = 1:length(this.nbleachpt) %bleach set number

		for b=1:this.nbleachpt(bn) %bleach point in the set

			bleachroipoints = size(this.bleachpt{bn}, 3);
% 			bleachroipoints = size(this.bleachpt, 3);
			if bleachroipoints==1 %point bleach
				
				if this.bleachimage(bn)==0
% 					[bx, by] = this.rgbptrotateshift(this.bleachpt{bn}(b,1), this.bleachpt{bn}(b,2), n);
% 					[bx, by] = this.shift_imagept([this.bleachpt{bn}(b,1), this.bleachpt{bn}(b,2)], this.shiftx(t), this.shifty(t));
					bpt = this.shift_imagept([this.bleachpt{bn}(b,1), this.bleachpt{bn}(b,2)], this.shiftx(t), this.shifty(t));
				else
% 					[bx, by] = this.rgbptrotateshift(this.bleachpt{bn}(b,1), this.bleachpt{bn}(b,2), this.bleachimage(bn));
% 					[bx, by] = this.shift_imagept([this.bleachpt{bn}(b,1), this.bleachpt{bn}(b,2)], this.shiftx(this.bleachimage(bn)), this.shifty(this.bleachimage(bn)));
					bpt = this.shift_imagept([this.bleachpt{bn}(b,1), this.bleachpt{bn}(b,2)], this.shiftx(this.bleachimage(bn)), this.shifty(this.bleachimage(bn)));
				end
				bx = bpt(1);
				by = bpt(2);
				%plot(bx, by, '.', 'color', this.bleachcolor, 'MarkerSize', 5);

% 				if ~any(strcmp(fieldnames(this),'bleachcompmode')) || isempty(this.bleachcompmode) || this.bleachcompmode{bs}(this.bleachcomb{bs}(b))==0
% 				if ~any(strcmp(fieldnames(this),'bleachcompmode')) || isempty(this.bleachcompmode) || this.bleachcompmode{bn}(this.bleachcomb{bn})==0
% 				if isempty(this.compmode) || this.compmode{bn}(this.comb{bn}(b))==0
				if isempty(this.compmode{bn}) || this.compmode{bn}(this.comb{bn}(b))==0
					plot(bx, by, '.', 'color', this.bleachcolor{bn}, 'MarkerSize', 5);

				else
					compsize = round(sqrt(this.compmode{bn}(this.comb{bn}(b))) );
					compint = this.compint{bn}(this.comb{bn}(b));
					for x=1:compsize
						for y=1:compsize
							plot(bx+(x-1)*compint, by+(y-1)*compint, '.', 'color', this.bleachcolor{bn}, 'MarkerSize', 5);	
						end
					end
				end

			else %roi bleach
				for bpr = 1:bleachroipoints
					[bx(bpr), by(bpr)] = this.rgbptrotateshift(this.bleachpt{bn}(b,1, bpr), this.bleachpt{bn}(b,2, bpr), this.bleachimage(bn));
				end
				plot([bx, bx(1)], [by, by(1)], '-', 'color', this.bleachcolor{bn}, 'MarkerSize', 5);
			end
		end

	end

	% show scalebar
	if this.show_scalebar && ~isempty(this.pixelsize)
		%plot([this.scalebarposx, this.scalebarposx + 1 / this.pixelsize], [this.scalebarposy, this.scalebarposy], 'Color', 'c', 'Linewidth', 2);
		%plot([this.scalebarpos(1), this.scalebarpos(1) + this.scalebarlength / this.pixelsize], [this.scalebarpos(2), this.scalebarpos(2)], 'Color', this.scalebarcolor, 'Linewidth', 2);
		if isempty(this.axmin) || isempty(this.aymin)
			plot([this.scalebarpos(1), this.scalebarpos(1) + this.scalebarlength / this.pixelsize], [this.scalebarpos(2), this.scalebarpos(2)], 'Color', this.scalebarcolor, 'Linewidth', 2);
		else
			plot([this.axmin + this.scalebarpos(1), this.axmin + this.scalebarpos(1) + this.scalebarlength / this.pixelsize], ...
				[this.aymin + this.scalebarpos(2), this.aymin + this.scalebarpos(2)], 'Color', this.scalebarcolor, 'Linewidth', 2);
		end
	end


	% show colorbar
	if this.show_colorbar

		%in pixel units
		barpos_y = 101; 
		sph_colorbar = axes;
		set(sph_colorbar, 'Units', 'pixels', 'Position', [65, barpos_y, 170, 15]);

		tickdisp = [];

		if ~isempty(this.colorbartick)
			tickdisp = this.tick( find( (this.colorbartick < this.rgbmax) .* (this.colorbartick > this.rgbmin)  ) );
			tickdisp = tickdisp(:)';
			%tickdisppos = maxresol * (tickdisp - this.rgbmin) / (this.rgbmax - this.rgbmin);
		end

		if this.rgbmin~=this.rgbmax
			image(linspace(this.rgbmin, this.rgbmax, 1000), 1, data2rgb(linspace(this.rgbmin, this.rgbmax, 1000)', this.rgbmin, this.rgbmax, this.rgbparam));
		else
			image(data2rgb([ones(500,1)*this.rgbmin-1; ones(500,1)*this.rgbmin+1], this.rgbmin, this.rgbmax, this.rgbparam));
		end

		set(gca, 'TickDirMode', 'manual');
		set(gca, 'TickLength', [0 0]);
		set(gca, 'XTickMode', 'manual');
		set(gca, 'XTickLabelMode', 'manual');
		set(gca, 'XTick', []);
		set(gca, 'XTickLabel', []);
		if ~this.enable_colorbaredit
			set(gca, 'XTick', [this.rgbmin tickdisp this.rgbmax]);
			set(gca, 'XTickLabel', [this.rgbmin, tickdisp, this.rgbmax]);
		end
		set(gca, 'YTickMode', 'manual');
		set(gca, 'YTickLabelMode', 'manual');
		set(gca, 'YTick', []);
		set(gca, 'YTickLabel', []);
	end

	if this.show_colorbar && this.enable_colorbaredit
		this.rgbminedith = uicontrol('Style', 'edit', 'String', num2str(this.rgbmin), 'Units', 'pixels', 'Position', [5 barpos_y 50 15], ...
							'Callback', @rgbmineditf);
		this.rgbmaxedith = uicontrol('Style', 'edit', 'String', num2str(this.rgbmax), 'Units', 'pixels', 'Position', [245 barpos_y 50 15], ...
							'Callback', @rgbmaxeditf);
	end
		
	function rgbmineditf(hObject, evnt)
		this.rgbmin = str2num(get(hObject, 'String'));
		this.updatec;
	end
	function rgbmaxeditf(hObject, evnt)
		this.rgbmax = str2num(get(hObject, 'String'));
		this.updatec;
	end


	if this.show_colorbar && ~isempty(this.maskdata{z,t})

		barpos_y = 83; 
		sph_maskbar = axes;
		set(sph_maskbar, 'Units', 'pixels', 'Position', [65, barpos_y, 170, 15]);

		tickdisp = [];
		if ~isempty(this.maskcolorbartick)
			masktickdisp = this.subtick( find( (this.maskcolorbartick < this.maskmax) .* (this.maskcolorbartick > this.maskmin)  ) );
			masktickdisp = masktickdisp(:)';
		end

% 		if ~this.binarymask && this.maskmin~=this.maskmax
		if this.maskmin~=this.maskmax
			image(data2rgb(linspace(this.maskmin, this.maskmax, 1000)', this.maskmin, this.maskmax, this.maskparam));
		else
			image(data2rgb([ones(500,1)*this.maskmin-1; ones(500,1)*this.maskmin+1], this.maskmin, this.maskmin, this.maskparam));
		end
		
		set(gca, 'TickDirMode', 'manual');
		set(gca, 'TickLength', [0 0]);
		set(gca, 'XTickMode', 'manual');
		set(gca, 'XTickLabelMode', 'manual');
		set(gca, 'XTick', []);
		set(gca, 'XTickLabel', []);
% 		if ~this.enable_maskcolorbaredit
		if ~this.enable_colorbaredit
			set(gca, 'XTick', [1 masktickdisppos maxresol]);
			set(gca, 'XTickLabel', [this.maskmin, masktickdisp, this.maskmax]);
		end
		set(gca, 'YTickMode', 'manual');
		set(gca, 'YTickLabelMode', 'manual');
		set(gca, 'YTick', []);
		set(gca, 'YTickLabel', []);
	end

	if this.show_colorbar && this.enable_colorbaredit && ~isempty(this.maskdata{z,t})
		this.maskminedith = uicontrol('Style', 'edit', 'String', num2str(this.maskmin), 'Units', 'pixels', 'Position', [5 barpos_y 50 15], ...
							'Callback', @maskmineditf);
			this.maskmaxedith = uicontrol('Style', 'edit', 'String', num2str(this.maskmax), 'Units', 'pixels', 'Position', [245 barpos_y 50 15], ...
								'Callback', @maskmaxeditf);
		
	end
	

	function maskmineditf(hObject, evnt)
		this.maskmin = str2num(get(hObject, 'String'));
		this.updatec;
	end
	function maskmaxeditf(hObject, evnt)
		this.maskmax = str2num(get(hObject, 'String'));
		this.updatec;
	end


	if this.show_colorbar && ~isempty(this.subdata{z,t})

		barpos_y = 65;
		sph_subbar = axes;
		set(sph_subbar, 'Units', 'pixels', 'Position', [65, barpos_y, 170, 15]);

		tickdisp = [];
		if ~isempty(this.subcolorbartick)
			subtickdisp = this.subtick( find( (this.subcolorbartick < this.submax) .* (this.subcolorbartick > this.submin)  ) );
			subtickdisp = subtickdisp(:)';
		end

		if this.submin~=this.submax
			image(data2rgb(linspace(this.submin, this.submax, 1000)', this.submin, this.submax, this.subparam));
		else
			image(data2rgb([ones(500,1)*this.submin-1; ones(500,1)*this.submin+1], this.submin, this.submax, this.subparam));
		end

		set(gca, 'TickDirMode', 'manual');
		set(gca, 'TickLength', [0 0]);
		set(gca, 'XTickMode', 'manual');
		set(gca, 'XTickLabelMode', 'manual');
		set(gca, 'XTick', []);
		set(gca, 'XTickLabel', []);
% 		if ~this.enable_subcolorbaredit
		if ~this.enable_colorbaredit
			set(gca, 'XTick', [1 subtickdisppos maxresol]);
			set(gca, 'XTickLabel', [this.submin, subtickdisp, this.submax]);
		end
		set(gca, 'YTickMode', 'manual');
		set(gca, 'YTickLabelMode', 'manual');
		set(gca, 'YTick', []);
		set(gca, 'YTickLabel', []);
	end

% 	if this.show_subcolorbar && this.enable_subcolorbaredit && ~isempty(this.subdata{n})
% 	if this.show_colorbar && this.enable_colorbaredit && ~isempty(this.subdata{n})
	if this.show_colorbar && this.enable_colorbaredit && ~isempty(this.subdata{z,t})
% 		this.subminedith = uicontrol('Style', 'edit', 'String', num2str(this.submin), 'Units', 'normalized', 'Position', [0.30 barpos_y 0.09 0.025], ...
% 							'Callback', @submineditf);
% 		this.submaxedith = uicontrol('Style', 'edit', 'String', num2str(this.submax), 'Units', 'normalized', 'Position', [0.61 barpos_y 0.09 0.025], ...
% 							'Callback', @submaxeditf);
		this.subminedith = uicontrol('Style', 'edit', 'String', num2str(this.submin), 'Units', 'pixels', 'Position', [5 barpos_y 50 15], ...
							'Callback', @submineditf);
		this.submaxedith = uicontrol('Style', 'edit', 'String', num2str(this.submax), 'Units', 'pixels', 'Position', [245 barpos_y 50 15], ...
							'Callback', @submaxeditf);
	end
	
	function submineditf(hObject, evnt)
		this.submin = str2num(get(hObject, 'String'));
		this.updatec;
	end
	function submaxeditf(hObject, evnt)
		this.submax = str2num(get(hObject, 'String'));
		this.updatec;
	end



	%custom function button
	fbutton_position = 'bottom';
	fparam_position = 'bottom';
	
	
	if this.show_fbutton
		for i=1:length(this.fbuttonf)
			
			
			if ~isempty(this.fbuttonf{i})
				%in pixel units
				switch fbutton_position
					case 'bottom'
						position = [5+60*(i-1), 38, 50, 20];
				end

					this.fbuttonh(i) =  uicontrol('Style', 'PushButton', 'String', this.fbuttonstr{i}, 'Units', 'pixels', ...
								'Position', position, 'Callback', this.fbuttonf{i});

			end
		end
	end

	
	if this.show_fparamedit
		for i=1:length(this.fparamval)

			if ~isempty(this.fparamval{i})
			%in pixel units
				switch fparam_position
					case 'bottom'
						position_s = [5+60*(i-1), 18, 50, 12];
						position_e = [5+60*(i-1), 2, 50, 15];
				end

					uicontrol('Style', 'text', 'String', this.fparamstr{i}, 'Units', 'pixels', 'Position',  position_s);
					this.fparamedith(i) =  uicontrol('Style', 'edit', 'String', num2str(this.fparamval{i}), 'Units', 'pixels', 'Position',  position_e, ...
								'Callback', @fparameditf);
			end
			
		end
	end
	
	function fparameditf(hObject, evnt)
		fparamnum = find(this.fparamedith==hObject);
		this.fparamval{fparamnum} = str2num(get(hObject, 'String'));
		eval(this.fparamf{fparamnum});
	end

%event callback functions

% 	initpt = get(gca, 'CurrentPoint');
	initpt = get(this.imageaxh, 'CurrentPoint');
	selectedroilist = [];
	
	function roiclickf(src, evnt)
% 		set(this.figh, 'WindowButtonUpFcn', ''); %do not invoke fig click callback

		
		rc = find(src == this.plh);
		
		if ~strcmp(get(this.figh, 'SelectionType'), 'extend') %not shift-clicked
			for r=this.roilist
% 				set(this.plh(r), 'Selected', 'off');
				if r~=rc
					this.roi{r}.selected = 0;
				end
			end
		end
		
		if ~this.roi{rc}.selected
			this.roi{rc}.selected = 1;
		else
			this.roi{rc}.selected = 0;
		end


		selectedroilist = [];
		
		for r=this.roilist
			
			if this.roi{r}.selected
				
				switch this.roi{r}.type
					case {'rect', 'circle'}
						set(this.plh(r), 'EdgeColor', this.roicolor_selected); 
					case {'polygon', 'open'}
						set(this.plh(r), 'Color', this.roicolor_selected); 	
				end
				
				if this.roi{r}.shownum
					set(this.pltxh(r), 'Color', this.roicolor_selected); 
				end
				drawnow;
				selectedroilist = [selectedroilist, r];
				
			else
				
				switch this.roi{r}.type
					case {'rect', 'circle'}
						set(this.plh(r), 'EdgeColor', this.roicolor_default); 
					case {'polygon', 'open'}
						set(this.plh(r), 'Color', this.roicolor_default); 
				end
				
				if this.roi{r}.shownum
					set(this.pltxh(r), 'Color', this.roicolor_default);
				end
				drawnow;
			end
		end
		
% 		initpt = get(axh, 'CurrentPoint');
		initpt = get(this.imageaxh, 'CurrentPoint');
		
		
		if ~isempty(this.roiclickcallbackf)
			eval(this.roiclickcallbackf);
		end

		set(this.figh, 'WindowButtonUpFcn', @roibuttonupf);
		set(this.figh, 'WindowButtonMotionFcn',@roibuttonmotionf);
	end

	function roibuttonmotionf(srs, evnt)
% 		'roi-motion'
 
% 		cp = get(axh, 'CurrentPoint');
		cp = get(this.imageaxh, 'CurrentPoint');
		shiftx = cp(1,1) - initpt(1,1);
		shifty = cp(1,2) - initpt(1,2);
		
		for r = selectedroilist
			switch this.roi{r}.type
				case {'polygon', 'open'}
					if this.roi{r}.npt <=2 || strcmp(this.roi{r}.type, 'open')
						set(this.plh(r), 'XData',  this.roi{r}.pt(:,1) + this.roi{r}.shiftx(t) + this.shiftx(t) + shiftx);
						set(this.plh(r), 'YData',  this.roi{r}.pt(:,2) + this.roi{r}.shifty(t) + this.shifty(t) + shifty);
					else
						set(this.plh(r), 'XData',  [this.roi{r}.pt(:,1); this.roi{r}.pt(1,1)] + this.roi{r}.shiftx(t) + this.shiftx(t) + shiftx);
						set(this.plh(r), 'YData',  [this.roi{r}.pt(:,2); this.roi{r}.pt(1,2)] + this.roi{r}.shifty(t) + this.shifty(t) + shifty);
					end
					
					if this.roi{r}.shownum
						[xmin, xminix] = min(this.roi{r}.pt(:,1));
						set(this.pltxh(r), 'Position',	[(this.roi{r}.pt(xminix, 1) + this.roi{r}.shiftx(t) + this.shiftx(t) + shiftx - 3), ...
														 (this.roi{r}.pt(xminix, 2) + this.roi{r}.shifty(t) + this.shifty(t) + shifty) ] );
					end
					
				case 'circle'
					cx = this.roi{r}.pt(1,1) + shiftx;
					cy = this.roi{r}.pt(1,2) + shifty;
					set(this.plh(r), 'Position', [(cx - this.roi{r}.radius + this.roi{r}.shiftx(t) + this.shiftx(t)), ...
														(cy - this.roi{r}.radius + this.roi{r}.shifty(t) + this.shifty(t)), ...
														2*this.roi{r}.radius, 2*this.roi{r}.radius]);
					if this.roi{r}.shownum
						set(this.pltxh(r), 'Position',	[(cx - this.roi{r}.radius + this.roi{r}.shiftx(t) + this.shiftx(t) -3), ...
														(cy + this.roi{r}.shifty(t) + this.shifty(t))]);
				end

					
				case 'rect'
					rx1 = min(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(t) + this.shiftx(t) + shiftx; 
					ry1 = min(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(t) + this.shifty(t) + shifty;
					rx2 = max(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(t) + this.shiftx(t) + shiftx; 
					ry2 = max(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(t) + this.shifty(t) + shifty;

					set(this.plh(r), 'Position', [rx1, ry1, rx2-rx1, ry2-ry1]);
					
					if this.roi{r}.shownum
						set(this.pltxh(r), 'Position',	[min(rx1,rx2)-3, min(ry1,ry2)]);
					end
			end
			
			drawnow;
		end
		
	end


	function roibuttonupf(src, evnt)
% 		'roi-buttonup'

%  		cp = get(axh, 'CurrentPoint');
		cp = get(this.imageaxh, 'CurrentPoint');

		shiftx = round( cp(1,1) - initpt(1,1) );
		shifty = round( cp(1,2) - initpt(1,2) );

		for r = selectedroilist
% 			this.roi{r}.pt = [this.roi{r}.pt(:,1)+shiftx, this.roi{r}.pt(:,2)+shifty];
			if this.roishift_allimages
				for m=1:this.sizet
					this.roi{r}.shiftx(m) = this.roi{r}.shiftx(m) +shiftx;	this.roi{r}.shifty(m) = this.roi{r}.shifty(m) +shifty;
				end
			else
				this.roi{r}.shiftx(t) = this.roi{r}.shiftx(t) +shiftx;	this.roi{r}.shifty(t) = this.roi{r}.shifty(t) +shifty;
			end
			
			switch this.roi{r}.type
				case {'polygon', 'open'}
					if this.roi{r}.npt <=2 || strcmp(this.roi{r}.type, 'open')
						set(this.plh(r), 'XData',  this.roi{r}.pt(:,1) + this.roi{r}.shiftx(t) + this.shiftx(t));
						set(this.plh(r), 'YData',  this.roi{r}.pt(:,2) + this.roi{r}.shifty(t) + this.shifty(t));
					else
						set(this.plh(r), 'XData',  [this.roi{r}.pt(:,1); this.roi{r}.pt(1,1)] + this.roi{r}.shiftx(t) + this.shiftx(t));
						set(this.plh(r), 'YData',  [this.roi{r}.pt(:,2); this.roi{r}.pt(1,2)] + this.roi{r}.shifty(t) + this.shifty(t));
					end
					
					if this.roi{r}.shownum
						[xmin, xminix] = min(this.roi{r}.pt(:,1));
						set(this.pltxh(r), 'Position',	[(this.roi{r}.pt(xminix, 1) + this.roi{r}.shiftx(t) + this.shiftx(t) - 3), ...
														 (this.roi{r}.pt(xminix, 2) + this.roi{r}.shifty(t) + this.shifty(t))]);
					end
					
				case 'circle'
					cx = this.roi{r}.pt(1,1);
					cy = this.roi{r}.pt(1,2);
					set(this.plh(r), 'Position', [(cx - this.roi{r}.radius + this.roi{r}.shiftx(t) + this.shiftx(t)), ...
														(cy - this.roi{r}.radius + this.roi{r}.shifty(t) + this.shifty(t)), ...
														2*this.roi{r}.radius, 2*this.roi{r}.radius]);
					if this.roi{r}.shownum
						set(this.pltxh(r), 'Position',	[(cx - this.roi{r}.radius + this.roi{r}.shiftx(t) + this.shiftx(t) -3), ...
														(cy + this.roi{r}.shifty(t) + this.shifty(t))]);
				end

					
				case 'rect'
					rx1 = min(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(t) + this.shiftx(t); 
					ry1 = min(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(t) + this.shifty(t);
					rx2 = max(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(t) + this.shiftx(t); 
					ry2 = max(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(t) + this.shifty(t);

					set(this.plh(r), 'Position', [rx1, ry1, rx2-rx1, ry2-ry1]);
					
					if this.roi{r}.shownum
						set(this.pltxh(r), 'Position',	[min(rx1,rx2)-3, min(ry1,ry2)]);
					end
					
			end
			
			drawnow;
		end
		
		set(this.figh, 'WindowButtonMotionFcn', '')
		set(this.figh, 'WindowButtonUpFcn', @figclickf)
		set(this.plh(r), 'ButtonDownFcn', @roiclickf); 

	end

	
	function figclickf(src, evnt)
% 		'fig-click'

		%unselect rois
 %		if ~strcmp(get(this.figh, 'SelectionType'), 'extend') && ~this.ignorefigclick %if roi was clicked just before
 		if ~strcmp(get(this.figh, 'SelectionType'), 'extend')

			for r=this.roilist
				this.roi{r}.selected = 0;
			end
% 			this.update;
			selectedroi = [];
		end

		this.update;
% 		this.ignorefigclick = 0;
		
	end


	function keypressf(src, evnt)

		modifier = '';
		if length(evnt.Modifier) == 1 && strcmp(evnt.Modifier{:},'control')
			modifier = 'C';
		end
		if length(evnt.Modifier) == 1 && strcmp(evnt.Modifier{:},'shift')
			modifier = 'S';
		end
		if length(evnt.Modifier) == 1 && strcmp(evnt.Modifier{:},'alt')
			modifier = 'A';
		end
		if length(evnt.Modifier) == 2 && any(ismember(evnt.Modifier, 'control')) && any(ismember(evnt.Modifier, 'shift')) 
			modifier = 'CS';
		end
		if length(evnt.Modifier) == 2 && any(ismember(evnt.Modifier, 'control')) && any(ismember(evnt.Modifier, 'alt')) 
			modifier = 'CA';
		end

		
		selectedroi = [];
		for rnum = this.roilist
			if this.roi{rnum}.selected
				selectedroi = [selectedroi, rnum];
			end
		end

		%with selected rois
% 		if any(this.selectedroi)

		for rnum = selectedroi

			%shift roi
			if this.enable_roishift && (strcmp(modifier, '') || strcmp(modifier, 'C')) 

				if strcmp(modifier, '')
					shiftsize = 1;
				end
				if strcmp(modifier, 'C')
					shiftsize = 5;
				end

				if this.roishift_allimages
					switch evnt.Key
						case 'leftarrow'
							for m=1:this.sizet
									this.roi{rnum}.shiftx(m) = this.roi{rnum}.shiftx(m) - shiftsize;
							end; 
							this.updatec;
						case 'rightarrow'
							for m=1:this.sizet
									this.roi{rnum}.shiftx(m) = this.roi{rnum}.shiftx(m) + shiftsize;	
							end; 
							this.updatec;
						case 'uparrow'
							for m=1:this.sizet
									this.roi{rnum}.shifty(m) = this.roi{rnum}.shifty(m) - shiftsize;	
							end; 
							this.updatec;
						case 'downarrow'
							for m=1:this.sizet
									this.roi{rnum}.shifty(m) = this.roi{rnum}.shifty(m) + shiftsize;	
							end
							this.updatec;
					end
				else
					switch evnt.Key
						case 'leftarrow'
	%								this.roi{rnum}.pt(:,1) = this.roi{rnum}.pt(:,1) - shiftsize;	this.update;
									this.roi{rnum}.shiftx(t) = this.roi{rnum}.shiftx(t) - shiftsize;	this.update;
						case 'rightarrow'
	% 								this.roi{rnum}.pt(:,1) = this.roi{rnum}.pt(:,1) + shiftsize;	this.update;
									this.roi{rnum}.shiftx(t) = this.roi{rnum}.shiftx(t) + shiftsize;	this.update;
						case 'uparrow'
	% 								this.roi{rnum}.pt(:,2) = this.roi{rnum}.pt(:,2) - shiftsize;	this.update;
									this.roi{rnum}.shifty(t) = this.roi{rnum}.shifty(t) - shiftsize;	this.update;
						case 'downarrow'
	% 								this.roi{rnum}.pt(:,2) = this.roi{rnum}.pt(:,2) + shiftsize;	this.update;
									this.roi{rnum}.shifty(t) = this.roi{rnum}.shifty(t) + shiftsize;	this.update;
					end
				end
				
% 				this.update;
			end %if this.enable_roishift

			if strcmp(modifier, '')	%delete roi by delete key
				switch evnt.Key
					case 'delete'
% 						this.deleteroi(find(this.selectedroi));
						this.deleteroi(selectedroi);
						this.update;
				end

			end

		end

% 		if ~any(this.selectedroi) || ~this.enable_roishift %shift or rotate the image
% 		if ~isempty(selectedroi) ||  ~this.enable_roishift %shift or rotate the image
		if isempty(selectedroi) ||  ~this.enable_roishift %shift or rotate the image
% 			if this.enable_imagerotate && ( strcmp(modifier, 'S') || strcmp(modifier, 'CS') ) %rotate
% 
% 				if strcmp(modifier, 'S')
% 					rotsize = 0.01;
% 				end
% 				if strcmp(modifier, 'CS')
% 					rotsize = 0.05;
% 				end
% 
% 				if n > 1
% 					switch evnt.Key
% 						case 'leftarrow'
% 							this.angle(n) = this.angle(n) - rotsize;
% 							this.imagerotated = 1;	this.update;
% 
% 						case 'rightarrow'
% 							this.angle(n) = this.angle(n) + rotsize;
% 							this.imagerotated = 1;	this.update;
% 					end
% 				end
% 			end %if this.enable_imagerotate

			if this.enable_imageshift && ( strcmp(modifier, '') || strcmp(modifier, 'C') ) %shift

				if strcmp(modifier, '')
					shiftsize = 1;
				end
				if strcmp(modifier, 'C')
					shiftsize = 5;
				end

				if t > 1
					switch evnt.Key
						case 'leftarrow'
							this.shiftx(t) = this.shiftx(t) - shiftsize;
% 							this.imageshifted = 1;	this.update;
							this.updatec;

						case 'rightarrow'
							this.shiftx(t) = this.shiftx(t) + shiftsize;
% 							this.imageshifted = 1;	this.update;
							this.updatec;


						case 'uparrow'
							this.shifty(t) = this.shifty(t) - shiftsize;
% 							this.imageshifted = 1;	this.update;
							this.updatec;


						case 'downarrow'
							this.shifty(t) = this.shifty(t) + shiftsize;
% 							this.imageshifted = 1;	this.update;
							this.updatec;

					end
				end
				
% 				if n > 1
% 					switch evnt.Key
% 						case 'leftarrow'
% 							this.shiftx(n) = this.shiftx(n) - shiftsize;
% 							this.imageshifted = 1;	this.update;
% 
% 						case 'rightarrow'
% 							this.shiftx(n) = this.shiftx(n) + shiftsize;
% 							this.imageshifted = 1;	this.update;
% 
% 						case 'uparrow'
% 							this.shifty(n) = this.shifty(n) - shiftsize;
% 							this.imageshifted = 1;	this.update;
% 
% 						case 'downarrow'
% 							this.shifty(n) = this.shifty(n) + shiftsize;
% 							this.imageshifted = 1;	this.update;
% 					end
% 				end
			end %if enable_imageshift

			if this.enable_imageshift && ( strcmp(modifier, 'A') || strcmp(modifier, 'CA') ) %shift all following images
				if strcmp(modifier, 'A')
					shiftsize = 1;
				end
				if strcmp(modifier, 'CA')
					shiftsize = 5;
				end

				if n > 1
					switch evnt.Key
						case 'leftarrow'
							for t=this.t:this.sizet
								this.shiftx(t) = this.shiftx(t) - shiftsize;
% 								this.imageshifted_all = 1;	this.update;
							end

						case 'rightarrow'
							for t=this.t:this.sizet
								this.shiftx(t) = this.shiftx(t) + shiftsize;
% 								this.imageshifted_all = 1;	this.update;
							end
						case 'uparrow'
							for t=this.t:this.sizet
								this.shifty(t) = this.shifty(t) - shiftsize;
% 								this.imageshifted_all = 1;	this.update;
							end

						case 'downarrow'
							for t=this.t:this.sizet
								this.shifty(t) = this.shifty(t) + shiftsize;
% 								this.imageshifted_all = 1;	this.update;
							end
					end
					this.updatec;
				end
			end %if enable_imageshift
		end %if ~any(this.selectedroi) || ~this.enable_roishift




		%change image
		if strcmp(modifier, '')
			switch evnt.Key
				case 'pageup'
					if t > 1
						this.t = t-1;	this.z = this.ztarget(this.t);
						this.update;
					end
				case 'pagedown'
					if t < this.sizet
						this.t = t+1;	this.z = this.ztarget(this.t);
						this.update;
					end
				case 'home'
					this.t = 1; 	this.z = this.ztarget(this.t);
					this.update;
				case 'end'
					this.t = this.sizet; 	this.z = this.ztarget(this.t);
					this.update;
						
				case 'a'
					this.z = 1;		this.ztarget(t) = this.z;
					this.update;
				case 's'
					if z >1
						this.z = z-1;	this.ztarget(t) = this.z;
						this.update;
					end
				case 'd'
					if z < this.sizez
						this.z = z+1;	this.ztarget(t) = this.z;
						this.update;
					end
				case 'f'
					this.z = this.sizez;	this.ztarget(t) = this.z;
					this.update;
			end
			
		end

		axh = get(this.figh, 'CurrentAxes');

	end %function keypressf


	function wscrollwheelf(src, evnt)
		if evnt.VerticalScrollCount <0
			this.zoomstep = this.zoomstep +1;
		end
		if evnt.VerticalScrollCount >0
			this.zoomstep = this.zoomstep -1;
			if this.zoomstep<0; this.zoomstep = 0; end;
		end

% 		cp = get(axh, 'CurrentPoint');
		cp = get(this.imageaxh, 'CurrentPoint');

		xi = cp(1,1);
		yi = cp(1,2);

		axsizemax = this.sizex;
		aysizemax = this.sizey;

		axsize = axsizemax / this.zoomratio^this.zoomstep;
		aysize = aysizemax / this.zoomratio^this.zoomstep;

		zoomcenterxmin = axsize /2;
		zoomcenterxmax = axsizemax - axsize /2;
		zoomcenterymin = aysize /2;
		zoomcenterymax = aysizemax - aysize /2;

		xc = min( max(xi, zoomcenterxmin), zoomcenterxmax);
		yc = min( max(yi, zoomcenterymin), zoomcenterymax);

		this.axmin = xc - axsize /2;
		this.aymin = yc - aysize /2;
		this.axmax = xc + axsize /2;
		this.aymax = yc + aysize /2;

		axis([this.axmin this.axmax this.aymin this.aymax]);

		axh = get(this.figh, 'CurrentAxes');

		this.update;
	end


end %update
