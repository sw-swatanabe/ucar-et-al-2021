function update(this, varargin)
	nvarargin = length(varargin);

	n = this.currentdata;

	figure(this.figh);
	clf; 

	for i=1:nvarargin

		%if any(strcmp(varargin, 'contrast'))
		if strcmp(varargin, 'contrast')
			this.makergbdata(n);
		%	this.imageshifted_all = 1;
		end

		%if any(strcmp(varargin, 'contrastall'))
		if strcmp(varargin, 'contrastall')
			for imagenum = 1:this.ndata
				this.makergbdata(imagenum);
			end
		%	this.imageshifted_all = 1;
		end


		if any(strcmp(varargin, 'shiftall'))
			this.imageshifted_all = 1;
		end

		if any(strcmp(varargin, 'rotateall'))
			this.imagerotated_all = 1;
		end

% 			disableroiselect = 0;
% 			if any(strcmp(varargin, 'disableroiselect'))
% 				disableroiselect = 1;
% 			end

	end

	if this.imagerotated
		this.rotate_image(n);
	end

	if this.imageshifted || this.imagerotated
		this.shift_image(n);
	end

	if this.imageshifted_all
		for imgnum = 1:this.ndata
			this.shift_image(imgnum);
		end
	end


	this.imagerotated = 0;
	this.imageshifted = 0;
	this.imageshifted_all = 0;

% 	if this.sizey<this.sizex
% 		axh = subplot('Position', [0.1 0.5-0.4*this.sizey/this.sizex 0.8 0.8*this.sizey/this.sizex]);
% 	else
% 		axh = subplot('Position', [0.5-0.4*this.sizey/this.sizex 0.1 0.8*this.sizey/this.sizex 0.8]);
% 	end	

	axh = subplot('Position', [0.0 0.25 1.0 0.7]);
	
	this.imageaxh = axh;

	switch this.dispmode
		case 'overlay'
			tempimage = zeros(this.sizey, this.sizex, 3);
			tempimage(:,:,[1 3]) = this.rgbdatars{n}(:,:, [1 3]);
			tempimage(:,:,2) = this.rgbdatars{1}(:,:, 2);
			image(tempimage);

		case {'normal', 'endcolor'}
			image(this.rgbdatars{n});
	end



	%axis image;
	axis(this.axismode);
	axis([this.axmin this.axmax this.aymin this.aymax]);
	

	axis off;
	
	%backgroundedge - common image area
	rectangle('Position', [max([this.shiftx, 0]), max([this.shifty, 0]), ...
							this.sizex+min([this.shiftx, 0])-max([this.shiftx, 0]), ...
							this.sizey+min([this.shifty, 0])-max([this.shifty, 0]) ], ...
							'Curvature', [0,0],  'EdgeColor', this.backgroundedgecolor, 'linewidth', 1);

	
% 	axh = gca;

	if this.show_title

		%title([num2str(this.currentdata) ' / ' num2str(this.ndata)]);
		if any(this.filepath=='\')
			filepathstr = this.filepath(find(this.filepath=='\', 1, 'last') +1 : end);
		else
			filepathstr = this.filepath;
		end

		filename = '';
		if length(this.filename) >= n
			filename = this.filename{n};
		end

		%title([filepathstr ' - ' num2str(this.currentdata) ' / ' num2str(this.ndata)]);
		%title([filepathstr ' - ' filename ' - ' num2str(this.currentdata) ' / ' num2str(this.ndata)]);
		%{
		if this.ndata >1
			if ~strcmp(filename, '')
				if ~strcmp(this.titlestr, '')
					title([filepathstr ' - ' filename ' - ' this.titlestr ' - ' num2str(this.currentdata) ' / ' num2str(this.ndata)], 'interpreter', 'none');
				else
					title([filepathstr ' - ' filename ' - ' num2str(this.currentdata) ' / ' num2str(this.ndata)], 'interpreter', 'none');
				end
			else
				if ~strcmp(this.titlestr, '')
					title([this.titlestr ' - ' num2str(this.currentdata) ' / ' num2str(this.ndata)], 'interpreter', 'none');
				else
					title([num2str(this.currentdata) ' / ' num2str(this.ndata)], 'interpreter', 'none');
				end
			end
		else
			if ~strcmp(filename, '')
				if ~strcmp(this.titlestr, '')
					title([filepathstr ' - ' filename ' - ' this.titlestr], 'interpreter', 'none');
				else
					title([filepathstr ' - ' filename], 'interpreter', 'none');
				end
			else
				if ~strcmp(this.titlestr, '')
					title([this.titlestr], 'interpreter', 'none');
				else
					%no title
				end
			end
		end
		%}
		
		if this.ndata >1
% 			if ~strcmp(this.titlestr, '')
% 				title([this.titlestr ' - ' num2str(this.currentdata) ' / ' num2str(this.ndata)], 'interpreter', 'none');
				if ~isempty(this.current_z) && ~isempty(this.current_t)
					title([this.titlestr '[ t = ' num2str(this.current_t) '/' num2str(this.sizet) ',  z = ' num2str(this.current_z(this.current_t)) '/' num2str(this.sizez) ' ]'], 'interpreter', 'none');
				else
					title([this.titlestr '[ ' num2str(this.currentdata) '/' num2str(this.ndata) ' ]'], 'interpreter', 'none');
				end
		else
% 			if ~strcmp(this.titlestr, '')
				title([this.titlestr], 'interpreter', 'none');
% 			end
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
					this.plh(r) = plot(this.roi{r}.pt(:,1) + this.roi{r}.shiftx(n) + this.shiftx(n), this.roi{r}.pt(:,2) + this.roi{r}.shifty(n) + this.shifty(n),    'color', rcolor, 'linewidth', rlinewidth);
				else
% 					this.plh(r) = plot([this.roi{r}.pt(:,1); this.roi{r}.pt(1,1)], [this.roi{r}.pt(:,2); this.roi{r}.pt(1,2)],  'color', rcolor, 'linewidth', rlinewidth);
					this.plh(r) = plot([this.roi{r}.pt(:,1); this.roi{r}.pt(1,1)] + this.roi{r}.shiftx(n) + this.shiftx(n), ...
									   [this.roi{r}.pt(:,2); this.roi{r}.pt(1,2)] + this.roi{r}.shifty(n) + this.shifty(n),  'color', rcolor, 'linewidth', rlinewidth);
				end

				[xmin, xminix] = min(this.roi{r}.pt(:,1));

				if this.roi{r}.shownum
% 					text(this.roi{r}.pt(xminix, 1) -3, this.roi{r}.pt(xminix, 2), num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right');
					this.pltxh(r) = text(this.roi{r}.pt(xminix, 1) + this.roi{r}.shiftx(n) + this.shiftx(n) -3, ...
						 this.roi{r}.pt(xminix, 2) + this.roi{r}.shifty(n) + this.shifty(n),		num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right', 'fontsize', 11);
				end

			case 'circle'
				cx = this.roi{r}.pt(1,1);
				cy = this.roi{r}.pt(1,2);
% 				this.plh(r) = rectangle('Position', [cx - this.roi{r}.radius, cy - this.roi{r}.radius, 2*this.roi{r}.radius, 2*this.roi{r}.radius], ...
% 										'Curvature', [1,1],  'EdgeColor', rcolor, 'linewidth', rlinewidth);
				this.plh(r) = rectangle('Position', [(cx - this.roi{r}.radius + this.roi{r}.shiftx(n) + this.shiftx(n)), ...
													 (cy - this.roi{r}.radius + this.roi{r}.shifty(n) + this.shifty(n)), ...
													2*this.roi{r}.radius, 2*this.roi{r}.radius], ...
										'Curvature', [1,1],  'EdgeColor', rcolor, 'linewidth', rlinewidth);


				if this.roi{r}.shownum
% 					text(cx - this.roi{r}.radius -3, cy, num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right');
					this.pltxh(r) = text(cx - this.roi{r}.radius + this.roi{r}.shiftx(n) + this.shiftx(n) -3, ...
						 cy + this.roi{r}.shifty(n) + this.shifty(n),							num2str(r),  'color', rcolor, 'HorizontalAlignment', 'right', 'fontsize', 11);
				end

			case 'rect'
				rx1 = min(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(n) + this.shiftx(n); 
				ry1 = min(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(n) + this.shifty(n);
				rx2 = max(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(n) + this.shiftx(n); 
				ry2 = max(this.roi{r}.pt(: ,2)) + this.roi{r}.shifty(n) + this.shifty(n);
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
					[bx, by] = this.rgbptrotateshift(this.bleachpt{bn}(b,1), this.bleachpt{bn}(b,2), n);
				else
					[bx, by] = this.rgbptrotateshift(this.bleachpt{bn}(b,1), this.bleachpt{bn}(b,2), this.bleachimage(bn));
				end
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
% 		if this.sizey<this.sizex; 
% 			barpos_y = 0.065 + 0.4*(1-this.sizey/this.sizex); 
% 		else
% 			barpos_y = 0.065 ;
% 		end
% 		barpos_y = 0.21; 
		
% 		subplot('Position', [0.4 barpos_y 0.2 0.025]);
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
% 		this.rgbminedith = uicontrol('Style', 'edit', 'String', num2str(this.rgbmin), 'Units', 'normalized', 'Position', [0.30 barpos_y 0.09 0.025], ...
% 							'Callback', @rgbmineditf);
% 		this.rgbmaxedith = uicontrol('Style', 'edit', 'String', num2str(this.rgbmax), 'Units', 'normalized', 'Position', [0.61 barpos_y 0.09 0.025], ...
% 							'Callback', @rgbmaxeditf);
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


% 	if this.show_maskcolorbar && ~isempty(this.maskdata{n})
	if this.show_colorbar && ~isempty(this.maskdata{n})
% 		if this.sizey<this.sizex; 
% 			barpos_y = 0.005 + 0.4*(1-this.sizey/this.sizex); 
% 		else
% 			barpos_y = 0.005 ;
% 		end
% 		barpos_y = 0.18; 
% 		subplot('Position', [0.4 0.005 0.2 0.025]);
% 		subplot('Position', [0.4 barpos_y 0.2 0.025]);

		barpos_y = 83; 
		sph_maskbar = axes;
		set(sph_maskbar, 'Units', 'pixels', 'Position', [65, barpos_y, 170, 15]);

		tickdisp = [];
		if ~isempty(this.maskcolorbartick)
			masktickdisp = this.subtick( find( (this.maskcolorbartick < this.maskmax) .* (this.maskcolorbartick > this.maskmin)  ) );
			masktickdisp = masktickdisp(:)';
		end

		if ~this.binarymask && this.maskmin~=this.maskmax
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

% 	if this.enable_maskedit && ~isempty(this.maskdata{n})
	if this.show_colorbar && this.enable_colorbaredit && ~isempty(this.maskdata{n})
% 		this.maskminedith = uicontrol('Style', 'edit', 'String', num2str(this.maskmin), 'Units', 'normalized', 'Position', [0.30 barpos_y 0.09 0.025], ...
% 							'Callback', @maskmineditf);
% 		if ~this.binarymask
% 			this.maskmaxedith = uicontrol('Style', 'edit', 'String', num2str(this.maskmax), 'Units', 'normalized', 'Position', [0.61 barpos_y 0.09 0.025], ...
% 								'Callback', @maskmaxeditf);
		this.maskminedith = uicontrol('Style', 'edit', 'String', num2str(this.maskmin), 'Units', 'pixels', 'Position', [5 barpos_y 50 15], ...
							'Callback', @maskmineditf);
		if ~this.binarymask
			this.maskmaxedith = uicontrol('Style', 'edit', 'String', num2str(this.maskmax), 'Units', 'pixels', 'Position', [245 barpos_y 50 15], ...
								'Callback', @maskmaxeditf);
		end
		
	%to display binary checkbutton, uncomment
% 		this.binarymaskcheckboxh = uicontrol('Style', 'checkbox', 'String', 'Binary', 'Units', 'normalized', 'Position', [0.75 barpos_y 0.11 0.025], 'Callback', @binarymaskcheckboxf);
% 		set(this.binarymaskcheckboxh, 'Value', this.binarymask);
	end
	
% 	function binarymaskcheckboxf(hObject, eventdata, handles)
% 		if (get(hObject,'Value') == get(hObject,'Max'))
% 			this.binarymask = 1;
% 		else
% 			this.binarymask = 0;
% 		end
% 		
% 		this.maskmax = this.maskmin;
% 		this.updatec;
% 	end

	function maskmineditf(hObject, evnt)
		this.maskmin = str2num(get(hObject, 'String'));
		this.updatec;
	end
	function maskmaxeditf(hObject, evnt)
		this.maskmax = str2num(get(hObject, 'String'));
		this.updatec;
	end


	if this.show_colorbar && ~isempty(this.subdata{n})
% 		if this.sizey<this.sizex; 
% 			barpos_y = 0.035 + 0.4*(1-this.sizey/this.sizex); 
% 		else
% 			barpos_y = 0.035 ;
% 		end
% 		barpos_y = 0.15;
		
% 		subplot('Position', [0.4 barpos_y 0.2 0.025]);
		%in pixel units
% 		subplot('Position', [65 75 200 22], 'Units', 'pixels');

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
	if this.show_colorbar && this.enable_colorbaredit && ~isempty(this.subdata{n})
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


% 	if this.enable_opacityedit && ~isempty(this.subdata{n})
% 	if this.show_colorbar && this.enable_colorbaredit && ~isempty(this.subdata{n})
% 		this.imageopacityedith = uicontrol('Style', 'edit', 'String', num2str(this.imageopacity), 'Units', 'normalized', 'Position', [0.75 barpos_y+0.03 0.09 0.025], ...
% 							'Callback', @imageopacityeditf);
% 		this.subopacityedith = uicontrol('Style', 'edit', 'String', num2str(this.subopacity), 'Units', 'normalized', 'Position', [0.75 barpos_y 0.09 0.025], ...
% 							'Callback', @subopacityeditf);
% 	end

% 	function imageopacityeditf(hObject, evnt)
% 		this.imageopacity = str2num(get(hObject, 'String'));
% 		this.updatec;
% 	end
% 	function subopacityeditf(hObject, evnt)
% 		this.subopacity = str2num(get(hObject, 'String'));
% 		this.updatec;
% 	end


	%custom function button
	fbutton_position = 'bottom';
	fparam_position = 'bottom';
	
	
	if this.show_fbutton
		for i=1:length(this.fbuttonf)
			
% 			switch fbutton_position
% 				case 'right'
% 					position =  [0.90, 0.90-0.1*(i-1), 0.09, 0.03];
% 				case 'bottom'
% 					position = [0.0+0.1*(i-1), 0.06, 0.09, 0.03];
% 			end
% 		
% 			if length(this.fbuttonstr) >=i &&  ~isempty(this.fbuttonstr{i})
% % 				this.fbuttonh(i) =  uicontrol('Style', 'PushButton', 'String', this.fbuttonstr{i}, 'Units', 'normalized', ...
% % 							'Position', [0.90, 0.90-0.1*(i-1), 0.09, 0.06], 'Callback', this.fbuttonf{i});
% 				this.fbuttonh(i) =  uicontrol('Style', 'PushButton', 'String', this.fbuttonstr{i}, 'Units', 'normalized', ...
% 							'Position', position, 'Callback', this.fbuttonf{i});
% 			else
% % 				this.fbuttonh(i) =  uicontrol('Style', 'PushButton', 'String', this.fbuttonf{i}, 'Units', 'normalized', ...
% % 							'Position', [0.90, 0.90-0.1*(i-1), 0.09, 0.06], 'Callback', this.fbuttonf{i});
% 				this.fbuttonh(i) =  uicontrol('Style', 'PushButton', 'String', this.fbuttonf{i}, 'Units', 'normalized', ...
% 							'Position', position, 'Callback', this.fbuttonf{i});
% 			end
			
			if ~isempty(this.fbuttonf{i})
				%in pixel units
				switch fbutton_position
					case 'bottom'
						position = [5+60*(i-1), 38, 50, 20];
				end

% 				if length(this.fbuttonstr) >=i &&  ~isempty(this.fbuttonstr{i})
					this.fbuttonh(i) =  uicontrol('Style', 'PushButton', 'String', this.fbuttonstr{i}, 'Units', 'pixels', ...
								'Position', position, 'Callback', this.fbuttonf{i});
% 				else
% 					this.fbuttonh(i) =  uicontrol('Style', 'PushButton', 'String', this.fbuttonf{i}, 'Units', 'pixels', ...
% 								'Position', position, 'Callback', this.fbuttonf{i});
% 				end

			end
		end
	end

	
	if this.show_fparamedit
		for i=1:length(this.fparamval)

% 			switch fparam_position
% 				case 'left'
% 					position_s =  [0.01, 0.90-0.05*(2*i-1)-0.01, 0.09, 0.025];
% 					position_e =  [0.01, 0.90-0.05*(2*i-2)-0.01, 0.09, 0.025];
% 				case 'top'
% 					position_s = [0.1+0.1*i, 0.9, 0.09, 0.025];
% 					position_e = [0.1+0.1*i, 0.85, 0.09, 0.025];
% 				case 'bottom'
% 					position_s = [0.1+0.1*i, 0.03, 0.09, 0.025];
% 					position_e = [0.1+0.1*i, 0.00, 0.09, 0.025];
% 			end
% 			
% 			if length(this.fparamstr) >=i
% % 				uicontrol('Style', 'text', 'String', this.fparamstr{i}, 'Units', 'normalized', 'Position',  [0.01, 0.90-0.05*(2*i-2)-0.01, 0.09, 0.025]);
% % 				this.fparamedith(i) =  uicontrol('Style', 'edit', 'String', num2str(this.fparamval{i}), 'Units', 'normalized', 'Position',  [0.01, 0.90-0.05*(2*i-1), 0.09, 0.025], ...
% % 							'Callback', @fparameditf);
% 				uicontrol('Style', 'text', 'String', this.fparamstr{i}, 'Units', 'normalized', 'Position',  position_s);
% 				this.fparamedith(i) =  uicontrol('Style', 'edit', 'String', num2str(this.fparamval{i}), 'Units', 'normalized', 'Position',  position_e, ...
% 							'Callback', @fparameditf);
% 			else
% % 				this.fparamedith(i) =  uicontrol('Style', 'edit', 'String', num2str(this.fparamval{i}), 'Units', 'normalized', 'Position',  [0.01, 0.90-0.05*(2*i-2), 0.09, 0.025], ...
% % 							'Callback', @fparameditf);
% 				this.fparamedith(i) =  uicontrol('Style', 'edit', 'String', num2str(this.fparamval{i}), 'Units', 'normalized', 'Position',  position_e, ...
% 							'Callback', @fparameditf);
% 			end
			
			if ~isempty(this.fparamval{i})
			%in pixel units
				switch fparam_position
					case 'bottom'
						position_s = [5+60*(i-1), 18, 50, 12];
						position_e = [5+60*(i-1), 2, 50, 15];
				end

	% 			if length(this.fparamstr) >=i
					uicontrol('Style', 'text', 'String', this.fparamstr{i}, 'Units', 'pixels', 'Position',  position_s);
					this.fparamedith(i) =  uicontrol('Style', 'edit', 'String', num2str(this.fparamval{i}), 'Units', 'pixels', 'Position',  position_e, ...
								'Callback', @fparameditf);
	% 			else
	% 				this.fparamedith(i) =  uicontrol('Style', 'edit', 'String', num2str(this.fparamval{i}), 'Units', 'pixels', 'Position',  position_e, ...
	% 							'Callback', @fparameditf);
	% 			end
			end
			
		end
	end
	
	function fparameditf(hObject, evnt)
		fparamnum = find(this.fparamedith==hObject);
		this.fparamval{fparamnum} = str2num(get(hObject, 'String'));
	end

%event callback functions

% 	initpt = get(gca, 'CurrentPoint');
	initpt = get(this.imageaxh, 'CurrentPoint');
	selectedroilist = [];
	
	function roiclickf(src, evnt)
% 		set(this.figh, 'WindowButtonUpFcn', ''); %do not invoke fig click callback

		
% 		this.ignorefigclick = 1;
		
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

% 		set(srs, 'Selected', 'on');

% 		for r=this.roilist
% 			if this.roi{r}.selected
% 
% 				if strcmp(get(this.figh, 'SelectionType'), 'extend') %if shift-clicked, revert selection
% 					this.roi{r}.selected = ~this.roi{r}.selected;
% 				else
% 					this.roi{r}.selected = 1;
% 				end
% 
% 			end
% 		end

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
						set(this.plh(r), 'XData',  this.roi{r}.pt(:,1) + this.roi{r}.shiftx(n) + this.shiftx(n) + shiftx);
						set(this.plh(r), 'YData',  this.roi{r}.pt(:,2) + this.roi{r}.shifty(n) + this.shifty(n) + shifty);
					else
						set(this.plh(r), 'XData',  [this.roi{r}.pt(:,1); this.roi{r}.pt(1,1)] + this.roi{r}.shiftx(n) + this.shiftx(n) + shiftx);
						set(this.plh(r), 'YData',  [this.roi{r}.pt(:,2); this.roi{r}.pt(1,2)] + this.roi{r}.shifty(n) + this.shifty(n) + shifty);
					end
					
					if this.roi{r}.shownum
						[xmin, xminix] = min(this.roi{r}.pt(:,1));
						set(this.pltxh(r), 'Position',	[(this.roi{r}.pt(xminix, 1) + this.roi{r}.shiftx(n) + this.shiftx(n) + shiftx - 3), ...
														 (this.roi{r}.pt(xminix, 2) + this.roi{r}.shifty(n) + this.shifty(n) + shifty) ] );
					end
					
				case 'circle'
					cx = this.roi{r}.pt(1,1) + shiftx;
					cy = this.roi{r}.pt(1,2) + shifty;
					set(this.plh(r), 'Position', [(cx - this.roi{r}.radius + this.roi{r}.shiftx(n) + this.shiftx(n)), ...
														(cy - this.roi{r}.radius + this.roi{r}.shifty(n) + this.shifty(n)), ...
														2*this.roi{r}.radius, 2*this.roi{r}.radius]);
					if this.roi{r}.shownum
						set(this.pltxh(r), 'Position',	[(cx - this.roi{r}.radius + this.roi{r}.shiftx(n) + this.shiftx(n) -3), ...
														(cy + this.roi{r}.shifty(n) + this.shifty(n))]);
				end

					
				case 'rect'
					rx1 = min(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(n) + this.shiftx(n) + shiftx; 
					ry1 = min(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(n) + this.shifty(n) + shifty;
					rx2 = max(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(n) + this.shiftx(n) + shiftx; 
					ry2 = max(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(n) + this.shifty(n) + shifty;

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
				for m=1:this.ndata
					this.roi{r}.shiftx(m) = this.roi{r}.shiftx(m) +shiftx;	this.roi{r}.shifty(m) = this.roi{r}.shifty(m) +shifty;
				end
			else
				this.roi{r}.shiftx(n) = this.roi{r}.shiftx(n) +shiftx;	this.roi{r}.shifty(n) = this.roi{r}.shifty(n) +shifty;
			end
			
			switch this.roi{r}.type
				case {'polygon', 'open'}
					if this.roi{r}.npt <=2 || strcmp(this.roi{r}.type, 'open')
						set(this.plh(r), 'XData',  this.roi{r}.pt(:,1) + this.roi{r}.shiftx(n) + this.shiftx(n));
						set(this.plh(r), 'YData',  this.roi{r}.pt(:,2) + this.roi{r}.shifty(n) + this.shifty(n));
					else
						set(this.plh(r), 'XData',  [this.roi{r}.pt(:,1); this.roi{r}.pt(1,1)] + this.roi{r}.shiftx(n) + this.shiftx(n));
						set(this.plh(r), 'YData',  [this.roi{r}.pt(:,2); this.roi{r}.pt(1,2)] + this.roi{r}.shifty(n) + this.shifty(n));
					end
					
					if this.roi{r}.shownum
						[xmin, xminix] = min(this.roi{r}.pt(:,1));
						set(this.pltxh(r), 'Position',	[(this.roi{r}.pt(xminix, 1) + this.roi{r}.shiftx(n) + this.shiftx(n) - 3), ...
														 (this.roi{r}.pt(xminix, 2) + this.roi{r}.shifty(n) + this.shifty(n))]);
					end
					
				case 'circle'
					cx = this.roi{r}.pt(1,1);
					cy = this.roi{r}.pt(1,2);
					set(this.plh(r), 'Position', [(cx - this.roi{r}.radius + this.roi{r}.shiftx(n) + this.shiftx(n)), ...
														(cy - this.roi{r}.radius + this.roi{r}.shifty(n) + this.shifty(n)), ...
														2*this.roi{r}.radius, 2*this.roi{r}.radius]);
					if this.roi{r}.shownum
						set(this.pltxh(r), 'Position',	[(cx - this.roi{r}.radius + this.roi{r}.shiftx(n) + this.shiftx(n) -3), ...
														(cy + this.roi{r}.shifty(n) + this.shifty(n))]);
				end

					
				case 'rect'
					rx1 = min(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(n) + this.shiftx(n); 
					ry1 = min(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(n) + this.shifty(n);
					rx2 = max(this.roi{r}.pt(:, 1)) + this.roi{r}.shiftx(n) + this.shiftx(n); 
					ry2 = max(this.roi{r}.pt(:, 2)) + this.roi{r}.shifty(n) + this.shifty(n);

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
							for m=1:this.ndata
									this.roi{rnum}.shiftx(m) = this.roi{rnum}.shiftx(m) - shiftsize;
							end; 
							this.update;
						case 'rightarrow'
							for m=1:this.ndata
									this.roi{rnum}.shiftx(m) = this.roi{rnum}.shiftx(m) + shiftsize;	
							end; 
							this.update;
						case 'uparrow'
							for m=1:this.ndata
									this.roi{rnum}.shifty(m) = this.roi{rnum}.shifty(m) - shiftsize;	
							end; 
							this.update;
						case 'downarrow'
							for m=1:this.ndata
									this.roi{rnum}.shifty(m) = this.roi{rnum}.shifty(m) + shiftsize;	
							end
							this.update;
					end
				else
					switch evnt.Key
						case 'leftarrow'
	%								this.roi{rnum}.pt(:,1) = this.roi{rnum}.pt(:,1) - shiftsize;	this.update;
									this.roi{rnum}.shiftx(n) = this.roi{rnum}.shiftx(n) - shiftsize;	this.update;
						case 'rightarrow'
	% 								this.roi{rnum}.pt(:,1) = this.roi{rnum}.pt(:,1) + shiftsize;	this.update;
									this.roi{rnum}.shiftx(n) = this.roi{rnum}.shiftx(n) + shiftsize;	this.update;
						case 'uparrow'
	% 								this.roi{rnum}.pt(:,2) = this.roi{rnum}.pt(:,2) - shiftsize;	this.update;
									this.roi{rnum}.shifty(n) = this.roi{rnum}.shifty(n) - shiftsize;	this.update;
						case 'downarrow'
	% 								this.roi{rnum}.pt(:,2) = this.roi{rnum}.pt(:,2) + shiftsize;	this.update;
									this.roi{rnum}.shifty(n) = this.roi{rnum}.shifty(n) + shiftsize;	this.update;
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
			if this.enable_imagerotate && ( strcmp(modifier, 'S') || strcmp(modifier, 'CS') ) %rotate

				if strcmp(modifier, 'S')
					rotsize = 0.01;
				end
				if strcmp(modifier, 'CS')
					rotsize = 0.05;
				end

				if n > 1
					switch evnt.Key
						case 'leftarrow'
							this.angle(n) = this.angle(n) - rotsize;
							this.imagerotated = 1;	this.update;

						case 'rightarrow'
							this.angle(n) = this.angle(n) + rotsize;
							this.imagerotated = 1;	this.update;
					end
				end
			end %if this.enable_imagerotate

			if this.enable_imageshift && ( strcmp(modifier, '') || strcmp(modifier, 'C') ) %shift

				if strcmp(modifier, '')
					shiftsize = 1;
				end
				if strcmp(modifier, 'C')
					shiftsize = 5;
				end

				if n > 1
					switch evnt.Key
						case 'leftarrow'
							this.shiftx(n) = this.shiftx(n) - shiftsize;
							this.imageshifted = 1;	this.update;

						case 'rightarrow'
							this.shiftx(n) = this.shiftx(n) + shiftsize;
							this.imageshifted = 1;	this.update;

						case 'uparrow'
							this.shifty(n) = this.shifty(n) - shiftsize;
							this.imageshifted = 1;	this.update;

						case 'downarrow'
							this.shifty(n) = this.shifty(n) + shiftsize;
							this.imageshifted = 1;	this.update;
					end
				end
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
							for t=n:this.ndata
								this.shiftx(t) = this.shiftx(t) - shiftsize;
								this.imageshifted_all = 1;	this.update;
							end

						case 'rightarrow'
							for t=n:this.ndata
								this.shiftx(t) = this.shiftx(t) + shiftsize;
								this.imageshifted_all = 1;	this.update;
							end
						case 'uparrow'
							for t=n:this.ndata
								this.shifty(t) = this.shifty(t) - shiftsize;
								this.imageshifted_all = 1;	this.update;
							end

						case 'downarrow'
							for t=n:this.ndata
								this.shifty(t) = this.shifty(t) + shiftsize;
								this.imageshifted_all = 1;	this.update;
							end
					end
				end
			end %if enable_imageshift
		end %if ~any(this.selectedroi) || ~this.enable_roishift

		%change contrast of all images
		%if strcmp(modifier, 'S') %change rgbmaxi of all images
		if strcmp(modifier, '') %change rgbmaxi of all images
			switch evnt.Key
				case 'comma' 
					this.rgbmax = this.rgbmin + (this.rgbmax - this.rgbmin) / this.contrastratio;
					this.update('contrastall');
				case 'period'
					this.rgbmax = this.rgbmin + (this.rgbmax - this.rgbmin) * this.contrastratio;
					this.update('contrastall');
			end

		end

		%if strcmp(modifier, 'CS') %change rgbmini of all image
		if strcmp(modifier, 'C') %change rgbmini of all image
			switch evnt.Key
				case 'comma' 
					this.rgbmin = this.rgbmin / this.contrastratio;
					this.update('contrastall');
				case 'period'
					this.rgbmin = this.rgbmin * this.contrastratio;
					this.update('contrastall');
			end

		end

		%change contrast in the current image
		%if strcmp(modifier, '') %change rgbmaxi of the current image
		if strcmp(modifier, 'S') %change rgbmaxi of the current image
			switch evnt.Key
				case 'comma' 
					this.rgbmaxi(n) = this.rgbmini(n) + (this.rgbmaxi(n) - this.rgbmini(n)) / this.contrastratio;
					this.update('contrast');					
				case 'period'
					this.rgbmaxi(n) = this.rgbmini(n) + (this.rgbmaxi(n) - this.rgbmini(n)) * this.contrastratio;
					this.update('contrast');					
			end

		end

		%if strcmp(modifier, 'C') %change rgbmini of the current image
		if strcmp(modifier, 'CS') %change rgbmini of the current image
			switch evnt.Key
				case 'comma' 
					this.rgbmini(n) = this.rgbmini(n) -50;
					this.update('contrast');					
				case 'period'
					this.rgbmini(n) = this.rgbmini(n) +50;
					this.update('contrast');					
			end
		end


		%change image
		if strcmp(modifier, '')
			switch evnt.Key
				case 'pageup'
					if this.currentdata >1
						this.showimage(this.currentdata -1);
					end
				case 'pagedown'
					if this.currentdata < this.ndata
						this.showimage(this.currentdata +1);
					end
				case 'home'
						this.showimage(1);
				case 'end'
						this.showimage(this.ndata);
						
				case 'j'
					this.current_t = 1;
					this.currentdata = (this.current_t -1) * this.sizez + this.current_z(this.current_t);
					this.update;
				case 'k'
					if this.current_t >1
						this.current_t = this.current_t -1;
					end
					this.currentdata = (this.current_t -1) * this.sizez + this.current_z(this.current_t);
					this.update;
				case 'l'
					if this.current_t < this.sizet
						this.current_t = this.current_t +1;
					end
					this.currentdata = (this.current_t -1) * this.sizez + this.current_z(this.current_t);
					this.update;
				case 'semicolon'
					this.current_t = this.sizet;
					this.currentdata = (this.current_t -1) * this.sizez + this.current_z(this.current_t);
					this.update;
				case 'd'
					if this.current_z(this.current_t) < this.sizez
						this.current_z(this.current_t) = this.current_z(this.current_t) +1;
					end
					this.currentdata = (this.current_t -1) * this.sizez + this.current_z(this.current_t);
					this.update;
				case 's'
					if this.current_z(this.current_t) > 1
						this.current_z(this.current_t) = this.current_z(this.current_t) -1;
					end
					this.currentdata = (this.current_t -1) * this.sizez + this.current_z(this.current_t);
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
