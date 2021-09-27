classdef imagedisp4 < handle
    
    properties
% 		use_iptoolbox = 1;
		
		% data properties
		filepath, filename;
		
		noimage = 0;				%no image window is created, but roi analysis etc are enabled
		
		img;						%image object (1 channel, 2D or 3D only), use of image object as input is not recommended
        data;						%data
		stackdata;
		maskdata;					%raw data for masking
		subdata;
		substackdata;
		
		imageopacity = 1;
		subopacity = 1;
		enable_opacityedit = 1;
		imageopacityedith, subopacityedith;
		
		maskthr = [];				%avoid using maskthr/maskgain, use maskmin/maskmax instead
		maskgain = [];
		maskmin = 0;
		maskmax = 0;
		enable_maskedit = 1;
		
% 		datatype;					%obj or data
% 		ndata = 0;					%number of data 
		
		sizex, sizey;
		sizez = 1;
		sizet = 1;
		

		rgbdata, rgbdata_top, rgbdata_bottom;
		maskimage;
% 		maskcolor;
		maskparam = 'gray';
		
		rgbmin = 0; rgbmax = 4095;	%will be changed to apply to all images
		
		rgbparam = 'gray';			%parameters used in converting the data using image2rgb
		endrgbmin, endrgbmax;		%parameters for the top and bottom frames used with the colorstack mode
		contrastref = 'first';		%reference of automatic contrast adjustment, 'first' to adjust all the images to the first one, 
									% 'current' to adjust contrast individually
		endrgbrate = 0.1;			%endrgbmax = rgbmax * endrgbrate, endrgbmin = rgbmin * endrgbrate
		
		enable_individualcontrast = 0;
		contrastroi = [];
		
		subimage;
		submin = 0; submax = 4095;
		subparam = 'gray';			%parameters used in converting the data using image2rgb
		masksubimage = 0;			%apply the same mask to the sub image as the main image
		
		dispmode = 'normal';		%stack for normal display, colorstack for gray stack with blue top and red bottom frames
									%overlay to overlay 1st and other image
		
		backgroundcolor = [0 0 0.5];
		backgroundedgecolor = 'b';
		
		
		t=0; 
		z;
		ztarget=1;
		
		% display manipulation
		zoomstep = 0;				%increments by zooming in and decrements by zooming out; 0 for the original size
		zoomratio = 3/2;			%rate of zooming per hitting the key
		contrastratio = 5/4;
		
		axrange;					%use this in place of axmin etc
		axmin, axmax, aymin, aymax;	%max and min of the axes
		axismode = 'image';

		% image shift and rotation
		enable_imageshift = 1;
		enable_imagerotate = 0;
		enable_imagedrag = 0;
		enable_keypress = 1;
		enable_scrollwheel = 1;
		
		
		roishiftx, roishifty;		%shift
		roirot;						%rotation
		rgbdatar, rgbdatar_top, rgbdatar_bottom;
		rgbdatars, rgbdatars_top, rgbdatars_bottom;
		
		shiftx, shifty, angle;
		shift;						%[shiftx, shifty] - not available yet
		shiftz;

		imageshifted = 0;			
		imagerotated = 0;
		imageshifted_all = 0;
		imagerotated_all = 0;
		
		
		% roi related properties
		roicolor_default = 'm';
		roicolor_selected = 'y';
		roilinewidth_default = 2;

		enable_roiselect = 1;
		enable_roishift = 1;		
		roishift_allimages = 0;		%shift roi in all images by the same amount

		roiradiusinit = 6;
		
		
		roilist;					%list of active roi - not available yet
		
		roi;						%cell array containing all roi params - not available yet
		%roi struct members
		%pt, npt, type, color, color_selected, linewidth, marker, selected, radius, shownum
		
		% scale bar
		show_scalebar = 1;
		scalebarpos = [5 5];		
		scalebarlength = 1;			%um
		scalebarcolor = 'w';
		
		show_colorbar = 1;
		colorbartick = [];
		enable_colorbaredit = 1;
		rgbmaxedith, rgbminedith;
		
		subcolorbartick = [];
		submaxedith, subminedith;

		maskcolorbartick = [];
		maskmaxedith, maskminedith;

		
		show_fbutton = 1;
		fbuttonf;
		fbuttonh;
		fbuttonstr;
		
		show_fparamedit = 1;
		fparamval;
		fparamedith;
		fparamstr;
		fparamf;  %callback function, not implemented yet
		
		pixelsize;					%can be incorporated from the object
		
		frametime;
		zstackstep;
		
		%use the followings instead
		tstep;
		zstep;
		
		%bleach points
		bleachpt, nbleachpt;		%can be incorporated from the object
		bleachcolor_default = 'c';
		bleachcolor;				%bleach point color for each bleach set
		bleachimage;				%lock bleachpt to the nth data
		bleachdispimage;
		
		comb;
		compmode;
		compint;
		
		show_title = 1;
		titlestr = '';				%title
		timestamp;					%any string containing information about each data
		time;
		
		% figure handle
		figh;
		
		% main image axes
		imageaxh;
		
		% plot handle
		plh;
		% plot text handle
		pltxh;
		
 		roistatus;					%struct
		
		roiclickcallbackf;
		
	end
	
	
	methods
		
		function this = imagedisp4(varargin)
			nvarargin = size(varargin, 2);
			
			fignum = [];
			data = [];
			subdata = [];
			maskdata = [];
			
			for i=1:nvarargin
				
				if isnumeric(varargin{i}) && i==1
						data = varargin{i};
% 						this.data{1} = varargin{i};
				end
				
				if ischar(varargin{i})
					switch varargin{i}
						case {'data', 'main', 'maindata'}
							data = varargin{i+1};

						case 'stackdata'
							stackdata = varargin{i+1};
							this.keepstackdata = 1;
							
						case 'normal'
							this.dispmode = 'normal';
						case 'overlay'
							this.dispmode = 'overlay';
							
						case {'param', 'mainparam'}
							this.rgbparam = varargin{i+1};
						case 'subparam'
							this.subparam = varargin{i+1};
						case 'maskparam'
							this.maskparam = varargin{i+1};
							
						case {'min', 'mainmin', 'rgbmin'}
							this.rgbmin  = varargin{i+1}; 
						case {'max', 'mainmax', 'rgbmax'}
							this.rgbmax  = varargin{i+1}; 	
						case {'submin'}
							this.submin  = varargin{i+1}; 
						case {'submax'}
							this.submax  = varargin{i+1}; 	
						case {'maskmin'}
							this.maskmin  = varargin{i+1}; 
						case {'maskmax'}
							this.maskmax  = varargin{i+1}; 	
							
						case 'keepstack'
							this.keepstackdata = 1;

						case 'fig'
							fignum = varargin{i+1};
						case 'noimage'
							this.noimage = 1;
							
						case 'zsize'
							this.sizez = varargin{i+1};
							
						case 'tstep'
							this.tstep = varargin{i+1};
						case 'zstep'
							this.zstep = varargin{i+1};
							
					end
				end
				
			end
			
			if ~isempty(fignum)
				this.figh = figure(fignum);
			else
				this.figh = figure;
			end
			
			if ~isempty(data)
				this.append('data', data, varargin{:});
			end		
			
		end %constructor

		
		function append(this, varargin) 
			%data can be an image object or a simple numeric data
			%for a numeric data, image object information can be optionally loaded
			
			nvarargin = size(varargin, 2);
			if this.t == 0
				z = 1;
				t = 1;
			else
				if this.z < this.sizez
					z = this.z +1;
					t = this.t;
				else
					z = 1;
					t = this.t +1;
				end
			end
			this.z = z;
			this.t = t;
			this.ztarget(t) = 1;
			
			data = [];
			subdata = [];
			maskdata = [];
			stackdata = [];
			
			imgobj = [];
			
			update = 1;
			
			for i=1:nvarargin

				if isnumeric(varargin{i}) && i==1
					data = varargin{i};
				end

				if ischar(varargin{i})
					switch varargin{i}
						case {'data', 'main', 'maindata'}
							data = varargin{i+1};
						case {'sub', 'subdata'}
							subdata = varargin{i+1};
						case {'mask', 'maskdata'}
							maskdata = varargin{i+1};
							
						case 'stackdata'
							stackdata = varargin{i+1};
							this.keepstackdata = 1;

						case 'z'
							z = varargin{i+1};
						case 't'
							t = varargin{i+1};

						case 'update'
							update = 1;
						case 'noupdate'
							update = 0;
					end
				end
			end
			
			this.maskdata{z,t} = [];
			this.maskimage{z,t} = [];
			this.subdata{z,t} = [];
			this.subimage{z,t} = [];
			this.stackdata{z,t} = [];

			this.data{z,t} = data;
			this.subdata{z,t} = subdata;
			this.maskdata{z,t} = maskdata;
			this.stackdata{z,t} = stackdata;

			
			if t==1 && z==1
				this.sizex = size(this.data{z,t}, 1);
				this.sizey = size(this.data{z,t}, 2);
			end
			
			this.shiftx(t) = 0;
			this.shifty(t) = 0;

% 			this.sizez = max(z, this.z);
			this.sizet = max(t, this.t);
			this.t = t;
			this.z = z;
			this.ztarget(t) = 1;

			if ~this.noimage
				this.makergbdata(z,t);
			end
			
			if ~this.noimage && update
				this.update;
			end
			
		end %function append
		
		
		function setparam(this, imgobj)
			this.pixelsize = imgobj.pixelsize;
			this.zstackstep = imgobj.stepz;
			this.frametime = imgobj.frametime;

			this.filepath = imgobj.filepath;
			%this.filename = imgobj.filename;
% 			this.time = imgobj.time;
		end
		
		function settime(this)
			this.time = (0:this.sizet-1) * this.tstep;
		end
		
		function delete(this)
		end
		

		
		function makergbdata(this, z,t)
            this.rgbdata{z,t} = data2rgb(this.data{z,t}, this.rgbmin, this.rgbmax, this.rgbparam);

			for i=1:3
				if ~isempty(this.maskdata{z,t})

					if this.maskmin >= this.maskmax
						this.maskimage{z,t}(:,:,i) = (this.maskdata{z,t}' - this.maskmin) > 0;
					else
						this.maskimage{z,t}(:,:,i) = (this.maskdata{z,t}' - this.maskmin) / (this.maskmax - this.maskmin);
					end
					
					this.rgbdata{z,t}(:,:,i) = this.rgbdata{z,t}(:,:,i) .* min(max(this.maskimage{z,t}(:,:,i), 0), 1);
				end
			end
			
			if ~isempty(this.subdata{z,t})
				this.subimage{z,t} = data2rgb(this.subdata{z,t}, this.submin, this.submax, this.subparam);
				if this.masksubimage
					for i=1:3
						this.subimage{z,t}(:,:,i) = this.subimage{z,t}(:,:,i) .* min(max(this.maskimage{z,t}(:,:,i), 0), 1);
					end
				end
				
				this.rgbdata{z,t} = this.rgbdata{z,t} * this.imageopacity + this.subimage{z,t} * this.subopacity;
			end
			
			this.rgbdata{z,t} = min(max(this.rgbdata{z,t}, 0), 1);
		
			this.rgbdatars{z,t} = this.shift_image(this.rgbdata{z,t}, this.shiftx(t), this.shifty(t));
			
		end
			

		
		function setbleachpt(this, varargin)

%add fvdata as argument

			nvarargin = length(varargin);
			%usage example
			%d1.setbleachpt(img1.bleachpt, 'noupdate', 'comb', img1.comb, 'compmode', img1.compmode,  'compint', img1.compint );

			%comb - nstimpt elements (numeric array)
			%compmode - number of combiner elements (cell)
			%compint - number of combiner elements (cell)

			bn = 1; %bleach point set
            bleachpt = [];
			bleachimage = 0;
			bleachdispimage = [];
			bleachcolor = this.bleachcolor_default;
% 			compmode = 0;
			compmode = [];
			compint = 0;
			comb = 1;
			
			update = 1;
			
			for i=1:nvarargin

				if i==1 && isnumeric(varargin{i})
					if size(varargin{i},2)==1
						bn = varargin{i};
						
						if nvarargin>=i+1 && isnumeric(varargin{i+1}) && size(varargin{i+1},2)>=2
							bleachpt = varargin{i+1};
						end
					end
					
					if size(varargin{i},2)>=2
						bleachpt = varargin{i};
					end
					
				end
				
				if ischar(varargin{i})

					switch varargin{i}
						case 'bleachnum' %bleach set number
							bn = varargin{i+1};
							
						case 'pt'
							bleachpt = varargin{i+1};
							
						case 'comb'
							comb = varargin{i+1};
						case 'compmode'
							compmode = varargin{i+1};
						case 'compint'
							compint = varargin{i+1};
						
						case 'image'
							bleachimage = varargin{i+1};
							
						case 'disp'
							bleachdispimage = varargin{i+1};
							
						case 'color'
							if isnumeric(varargin{i+1}) && length(varargin{i+1})==3
								bleachcolor = varargin{i+1};
							else %single character {'y', 'm', 'c', 'r', 'g', 'b', 'w', 'k' }
								bleachcolor = varargin{i+1};
							end
							
						case 'update'
							update = 1;
						case 'noupdate'
							update = 0;
					end
				end
            end
			
            if ~isempty(bleachpt)
                this.bleachpt{bn} = bleachpt;
                this.nbleachpt(bn) = size(bleachpt, 1);

                this.comb{bn} = comb;		%nbleachpt elements
                this.compmode{bn} = compmode;	%nbleachpt elements
                this.compint{bn} = compint;		%nbleachpt elements

                this.bleachimage(bn) = bleachimage;

                if ~isempty(bleachdispimage)
                    this.bleachdispimage(bn) = bleachdispimage;	
                else
                    this.bleachdispimage(bn) = bleachimage;	
                end

                this.bleachcolor{bn} = bleachcolor;
            end
			
			if update
				this.update;
			end
			
		end
		
		function setscalebar(this, varargin)
			nvarargin = size(varargin, 2);

			for i=1:nvarargin
				if ischar(varargin{i})
					switch varargin{i}
						case 'pos'
							this.scalebarpos = varargin{i+1}; %vector [x,y]
						case 'length'
							this.scalebarlength = varargin{i+1}; 
						case 'color'
							if isnumeric(varargin{i+1}) && length(varargin{i+1})==3
								this.scalebarcolor = varargin{i+1};
							else %single character {'y', 'm', 'c', 'r', 'g', 'b', 'w', 'k' }
								this.scalebarcolor = varargin{i+1};
							end
					end
				end

			end
			
			this.show_scalebar = 1;
			this.update;
		end

		
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%roi setting functions
	
		function setroi(this, varargin) %direct setting of roipoints or copy rois from another imagedisp object
				
			nvarargin = length(varargin);
		
			%usage
			% setroi(options) - set a roi on the image
			% setroi(roinum, options) - set a roi on the image as roinum
			% setroi(roipt, options) - set a roi to roipt
			% setroi(roinum, roipt, options) - set a roi to roipt as roinum
			% setroi(imageobj, options) - set rois to the same rois (and properties) in imageobj
			% setroi(imageobj, orgroinum, options) - set rois as those with orgroinum in imageobj, orgroinum can be a scalar or an array
			% setroi(roinum, imageobj, orgroinum, options) - set a roi with orgroinum in imageobj as roinum
			
%there is bug with  setroi(roinum, imageobj, orgroinum, options)

			roitype = 'polygon';
			hideroinum = 0;
			printroival = 0;
			roicolor = this.roicolor_default;
			roilinewidth = this.roilinewidth_default;

			update = 1;
			hideroinum = 0;
			
			roinum = [];
			orgroinum = [];
			roipt = [];
			imgobj = [];
			
			for i=1:nvarargin

				if isnumeric(varargin{i}) && numel(varargin{i})==1 && i==1
					roinum = varargin{i};
				end
				
				if isnumeric(varargin{i}) && numel(varargin{i})>1 && (i==1 || (i==2 && ~isempty(roinum)) )
					roipt = varargin{i};
				end
				
				if isobject(varargin{i})
					imgobj = varargin{i};
					
					if i<nvarargin && isnumeric(varargin{i+1})
						orgroinum = varargin{i+1};
					end
				end
				
				if ischar(varargin{i})
					switch varargin{i}
						case 'circle'
							roitype = 'circle';
						case 'rect'
							roitype = 'rect';
						case 'update'
							update = 1;
						case 'noupdate'
							update = 0;

						case 'hideroinum'
							hideroinum = 1;

						case 'color'
							if isnumeric(varargin{i+1}) && length(varargin{i+1})==3
								roicolor = varargin{i+1};
							else %single character {'y', 'm', 'c', 'r', 'g', 'b', 'w', 'k' }
								roicolor = varargin{i+1};
							end
							
						case 'linewidth'
							roilinewidth = varargin{i+1};
							
						case 'print'
							printroival = 1;
					end
				end				
				
			end %for i=1:nvarargin

			if ~isempty(imgobj)

				if isempty(roinum) && isempty(orgroinum) && ~this.noimage
					this.deleteroi('all');
				end
				
				if isempty(orgroinum)
					orgroinum = imgobj.roilist;
				end
				
				if isempty(roinum)
					roinum = orgroinum;
				end
					
				for r = orgroinum
					this.roi{r} = imgobj.roi{r}; 
					
					if this.sizet > imgobj.sizet
						this.roi{r}.shiftx(imgobj.sizet+1:this.sizet) = this.shiftx(imgobj.sizet+1:this.sizet);
						this.roi{r}.shifty(imgobj.sizet+1:this.sizet) = this.shifty(imgobj.sizet+1:this.sizet);
						this.roi{r}.angle(imgobj.sizet+1:this.sizet) = this.angle(imgobj.sizet+1:this.sizet);
					end
				end
				
			else
				
				if isempty(roinum)
					if ~isempty(this.roilist)
						roinum = max(this.roilist) +1;
					else
						roinum = 1;
					end

				else
					if length(varargin)>1
						varargin_t = varargin{2:end};
					else
						varargin_t = {};
					end
				end

				if ~isempty(roipt)
					this.roi{roinum}.pt = roipt;
					this.roi{roinum}.npt = size(roipt, 1);
					this.roi{roinum}.type = roitype;
					this.roi{roinum}.color = roicolor;
					this.roi{roinum}.linewidth = roilinewidth;
					this.roi{roinum}.shiftx = this.shiftx;
					this.roi{roinum}.shifty = this.shifty;
					this.roi{roinum}.angle = this.angle;
					this.roi{roinum}.selected = 1;
					
					if ~hideroinum
						this.roi{roinum}.shownum = 1;
					else
						this.roi{roinum}.shownum = 0;
					end

				else
					this.setroif(roinum, varargin{:});
				end

			end
			
			for r = this.roilist
				this.roi{r}.selected = 0;
			end
			
			
			for r = 1:length(roinum)
				if ~any(this.roilist==roinum(r))
					this.roilist = [this.roilist, roinum(r)];
				end
			end
			
			if update && ~this.noimage
				this.update;
			end
			
			
		end

	
		function setroif(this, roinum, varargin) %do not use this function directly
			nvarargin = size(varargin, 2);

			roitype = 'polygon';

			linemode = 'normal';	%normal or live
			maxpt = 0;				%0 to set points until the right button is clicked
			update = 1;
			hideroinum = 0;
% 			printroival = 0;
			roicolor = this.roicolor_default;
			roilinewidth = this.roilinewidth_default;

			for i=1:nvarargin
				if ischar(varargin{i})
					switch varargin{i}
						case 'circle'
							roitype = 'circle';
						case 'rect'
							roitype = 'rect';
						case 'open'
							roitype = 'open';
						case 'live'
							linemode = 'live';
						case 'update'
							update = 1;
						
						case 'hideroinum'
							hideroinum = 1;
							
						case 'max'
							maxpt = varargin{i+1};
							
						case 'color'
							if isnumeric(varargin{i+1}) && length(varargin{i+1})==3
								roicolor = varargin{i+1};
							else %single character {'y', 'm', 'c', 'r', 'g', 'b', 'w', 'k' }
								roicolor = varargin{i+1};
							end
							
						case 'linewidth'
							roilinewidth = varargin{i+1};
							
						case 'print'
							printroival = 1;
					end
				end
				
			end
			
			for r = this.roilist
				this.roi{r}.selected = 0;
			end
			
			figure(this.figh);
			
			if this.enable_roiselect && ~this.noimage
				this.enable_roiselect = 0;
				this.update;
			end

			this.roistatus.completed = 0;
			set(this.figh, 'WindowButtonDownFcn', '');	
		
			switch roitype
				case {'polygon', 'open'}
					setroipoints_polygon(this, roinum, maxpt, linemode);
				case 'circle'
					setroipoints_circle(this, roinum, 'live');
				case 'rect'
					setroipoints_rect(this, roinum, 'live');  %this function is under construction
			end
			
			uiwait(this.figh) %wait until resumed by a setroipoints function
			
			if this.roistatus.completed
				
				this.roi{roinum}.npt = size(this.roi{roinum}.pt, 1);
				this.roi{roinum}.type = roitype;
				
				if hideroinum
					this.roi{roinum}.shownum = 0;
				else
					this.roi{roinum}.shownum = 1;
				end
			
				this.roi{roinum}.color = roicolor;
				this.roi{roinum}.linewidth = roilinewidth;

				this.roi{roinum}.selected = 1;
				
				this.roi{roinum}.shiftx = -this.shiftx;
				this.roi{roinum}.shifty = -this.shifty;
				this.roi{roinum}.angle = -this.angle;
				
			end
			
			
			if update && ~this.noimage
				this.enable_roiselect = 1;
				this.update;
			end
			
		end
		
		function setroir(this, varargin)
			nvarargin = length(varargin);
			
			varargin_t = varargin;
			varargin_t{nvarargin+1} = 'rect';
			this.setroi(varargin_t{:});
		end
		

		function deleteroi(this, varargin)
		
			nvarargin = length(varargin);

			update = 1;
			
			if nvarargin==0
				this.roilist = [];
			end
			
			for i=1:nvarargin

				if isnumeric(varargin{i})
					listselected =[];
					for rnum = 1:length(varargin{i})
						listselected = [listselected, find(this.roilist == varargin{i}(rnum))];
					end
					this.roilist(listselected) = [];
				end

				if strcmp(varargin{i}, 'all')
					this.roilist = [];
				end

				if strcmp(varargin{i}, 'update')
					update = 1;
				end
				if strcmp(varargin{i}, 'noupdate')
					update = 0;
				end
			
			end
			
			if update
				this.update;
			end
		end
		
		
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% roi analysis functions
	
    %common

	%new functions compatible with roi shifting
		function roipattern = roip(this, roinum)
			roipattern = zeros(this.sizex, this.sizey, this.sizet);

			switch this.roi{roinum}.type
				case 'polygon'
					roipattern_raw = roipat_polygon(this.roi{roinum}.pt, this.sizex, this.sizey);
				case 'circle'
					roipattern_raw = roipat_circle(this.roi{roinum}.pt, this.roi{roinum}.radius, this.sizex, this.sizey);
				case 'rect'
					roipattern_raw = roipat_rect(this.roi{roinum}.pt, this.sizex, this.sizey);
			end
			
			if any( [this.roi{roinum}.shiftx,  this.roi{roinum}.shifty, this.roi{roinum}.angle] )
				for t=1:this.sizet
					roipattern(:,:,t) = this.shift_data( roipattern_raw, this.roi{roinum}.shiftx(t), this.roi{roinum}.shifty(t)  );
				end
			else
				for t=1:this.sizet
					roipattern(:,:,t) = roipattern_raw;
				end
			end
			
		end
		
		
		function roipattern = roipm(this, roinum)	%pixels in the roi without masking
													%matrix of size (sizex,sizey, sizez,sizet)
			roipattern = zeros(this.sizex, this.sizey, this.sizez, this.sizet);
			roipattern_raw = this.roip(roinum);
			for t=1:this.sizet
				for z=1:this.sizez
					maskrs =  this.shift_data(this.maskdata{z,t}, this.shiftx(t), this.shifty(t));
					roipattern(:,:,z,t) = roipattern_raw(:,:,t) .* ( (maskrs - this.maskmin) >0 );
				end
			end
		end
		
		
		function r = roiarea(this, roinum) %for nroipt >=3
			roipattern = this.roip(roinum);
 			r = msum(roipattern(:,:,1));
		end
		
		function r = roiaream(this, roinum) %ndata points
			roipattern = this.roipm(roinum);
			for t=1:this.sizet
				for z=1:this.sizez
					r(z,t) = msum(roipattern(:,:,z,t));
				end
			end
		end

		function r = roiimage(this, roinum) %roi data, only for rect roi
			for t=1:this.sizet
				for z=1:this.sizez
					for i=1:3
						r{z,t}(:,:,i) = this.rgbdatars{z,t}(round(min(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shifty(t) + this.shifty(t)) : ...
															round(max(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shifty(t) + this.shifty(t)),  ...
															round(min(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shiftx(t) + this.shiftx(t)) : ...
															round(max(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shiftx(t) + this.shiftx(t)) , i);
					end
				end
			end
		end
		
		
		function r = roidata(this, roinum) %roi data, only for rect roi
		%check if this is correct before use
		
			for t=1:this.sizet
				for z=1:this.sizez
					datashift = this.shift_data(this.data{z,t}, this.shiftx(t), this.shifty(t));
					r{z,t} = datashift( round(min(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shiftx(t)) : round(max(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shiftx(t)), ...
									    round(min(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shifty(t)) : round(max(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shifty(t)) );
				end
			end
		end
		
		function r = roival(this, roinum, varargin)
			r = this.roisum(roinum, varargin{:});
		end
		
		function r = roisum(this, roinum, varargin)
			nvarargin = length(varargin);
			
			target = 'main';
			mask = 0;
			
			for i=1:nvarargin
				if ischar(varargin{i})
					switch varargin{i}
						case 'main'
							target = 'main';
						case 'sub'
							target = 'sub';
						case 'mask'
							mask = 1;
					end
				end
			end
			
			r = zeros(this.sizez, this.sizet);
			
			if ~mask
				roipattern = this.roip(roinum);
				switch target
					case 'main'
						for t=1:this.sizet
							for z=1:this.sizez
								r(z,t) = msum(roipattern(:,:,t) .* this.data{z,t});
							end
						end
					case 'sub'
						for t=1:this.sizet
							for z=1:this.sizez
								r(z,t) = msum(roipattern(:,:,t) .* this.subdata{z,t});
							end
						end
				end
			else
				roipattern = this.roipm(roinum);
				switch target
					case 'main'
						for t=1:this.sizet
							for z=1:this.sizez
								r(z,t) = msum(roipattern(:,:,z,t) .* this.data{z,t});
							end
						end
					case 'sub'
						for t=1:this.sizet
							for z=1:this.sizez
								r(z,t) = msum(roipattern(:,:,z,t) .* this.subdata{z,t});
							end
						end
				end
			end
		end
		
				
		function r = roimean(this, roinum, varargin)
			nvarargin = length(varargin);
			
			mask = 0;
			for i=1:nvarargin
				if strcmp(varargin{i}, 'mask')
					mask = 1;
				end
			end
			
			roisum = this.roisum(roinum, varargin{:});
			if ~mask
				r = roisum / this.roiarea(roinum);
			else
				r = roisum ./ this.roiaream(roinum);
			end
		end

		
		function r = roipixels(this, roinum, varargin) %all pexels in the roi aligned in one dim
			nvarargin = length(varargin);

			target = 'main';
			mask = 0;
			z = this.z;
			t = this.t;
			
			for i=1:nvarargin
				if ischar(varargin{i})
					switch varargin{i}
						case 'main'
							target = 'main';
						case 'sub'
							target = 'sub';
						case 'mask'
							mask = 1;
					end
				end
			end
			
			if ~mask
				roipattern = this.roip(roinum);
				switch target
					case 'main'
						for t=1:this.sizet
							r{z,t} = this.data{z,t}(find(roipattern(:,:,t)));
						end
					case 'sub'
						for t=1:this.sizet
							r{z,t} = this.subdata{z,t}(find(roipattern(:,:,t)));
						end
				end
			else
				roipattern = this.roipm(roinum);
				switch target
					case 'main'
						for t=1:this.sizet
							r{z,t} = this.data{z,t}(find(roipattern(:,:,z,t)));
						end
					case 'sub'
						for t=1:this.sizet
							r{z,t} = this.subdata{z,t}(find(roipattern(:,:,z,t)));
						end
				end
			end
		end

		
		function r = lineprof(this, roinum, varargin)
			nvarargin = length(varargin);

			target = 'main';
			
			for i=1:nvarargin
				if ischar(varargin{i})
					switch varargin{i}
						case 'main'
							target = 'main';
						case 'sub'
							target = 'sub';
					end
				end
			end
			
			[linept, lineptwt] = linepoints(this.roi{roinum}.pt);
			nlinept = size(linept, 1);
			
			r = zeros(nlinept, this.sizez, this.sizet);
			
			switch target
				case 'main'
					for t=1:this.sizet
						lineptshift = [linept(:,1)+this.roi{roinum}.shiftx(t), linept(:,2)+this.roi{roinum}.shifty(t)];
						for z=1:this.sizez
							for i=1:nlinept
								r(i, z,t) = msum(this.data{z,t}(lineptshift(i,1):lineptshift(i,1)+1, lineptshift(i,2):lineptshift(i,2)+1) .* lineptwt(:,:,i) );
							end
						end
					end
				case 'sub'
					for t=1:this.sizet
						lineptshift = [linept(:,1)+this.roi{roinum}.shiftx(t), linept(:,2)+this.roi{roinum}.shifty(t)];
						for z=1:this.sizez
							for i=1:nlinept
								r(i, z,t) = msum(this.subdata{z,t}(lineptshift(i,1):lineptshift(i,1)+1, lineptshift(i,2):lineptshift(i,2)+1) .* lineptwt(:,:,i) );
							end
						end
					end
			end
		end
		

	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%image manipulation functions
	%note - the direction of rotation for the image is opposite to that for the data

	%image

		function image_shifted = shift_image(this, image_original, shiftx, shifty, bgcolor)
			if shiftx || shifty
				if nargin<4
					bgcolor = [0,0,0];
				else
					bgcolor = rgbcode(this.backgroundcolor);
				end
				
				for col=1:3
					image_shifted(:,:,col) = ones(size(image_original(:,:,col))) * bgcolor(col);
				end
				
				image_shifted( max(1, 1+shifty) : min(this.sizey, this.sizey+shifty), max(1, 1+shiftx) : min(this.sizex, this.sizex+shiftx), :) ...
					= image_original( max(1, 1-shifty) : min(this.sizey, this.sizey-shifty), max(1, 1-shiftx) : min(this.sizex, this.sizex-shiftx), :);
            else
				image_shifted = image_original;
			end
		end
		
		function data_shifted = shift_data(this, data_original, shiftx, shifty)
			if shiftx || shifty
				data_shifted = zeros(size(data_original));

				data_shifted( max(1, 1+shiftx) : min(this.sizex, this.sizex+shiftx), max(1, 1+shifty) : min(this.sizey, this.sizey+shifty) ) ...
					= data_original( max(1, 1-shiftx) : min(this.sizex, this.sizex-shiftx), max(1, 1-shifty) : min(this.sizey, this.sizey-shifty) );
			else
				data_shifted = data_original;
			end
		end
		
		function imgpt_shifted = shift_imagept(this, imagept_original, shiftx, shifty)
			imgpt_shifted_x = imagept_original(1) + shiftx;
			imgpt_shifted_y = imagept_original(2) + shifty;
			imgpt_shifted = [imgpt_shifted_x, imgpt_shifted_y];
		end


		function reset_shift(this)
			
			for t=1:this.sizet
				this.shiftx(t) = 0;
				this.shifty(t) = 0;
			end
			
% 			this.imagerotated = 1;
% 			this.imageshifted = 1;
			this.updatec;
		end

		
		%sum image over series
		
		function sumdata = sumdata_z(this, sumrange)
			if nargin<2
				sumrange = 1:this.sizez;
			end
			
			sumdata = zeros(this.sizex, this.sizey, this.sizet);
			for t=1:this.sizet
				for z=sumrange
					data_shifted = this.shfitdata(this.data{z,t}, this.shiftx, this.shifty);
					sumdata(:,:,t) = sumdata(:,:,t) + data_shifted;
				end
			end
				
		end

		function sumdata = sumdata_t(this, sumrange)
			if nargin<2
				sumrange = 1:this.sizet;
			end
			
			sumdata = zeros(this.sizex, this.sizey, this.sizez);
			for z=1:this.sizez
				for t=sumrange
					data_shifted = this.shfitdata(this.data{z,t}, this.shiftx, this.shifty);
					sumdata(:,:,z) = sumdata(:,:,z) + data_shifted;
				end
			end
				
		end
		
	
		function meandata = meandata_z(this, sumrange)
			if nargin<2
				sumrange = 1:this.sizez;
			end
			meandata = this.sumdata(sumrange) / length(sumrange);
		end
		
		function meandata = meandata_t(this, sumrange)
			if nargin<2
				sumrange = 1:this.sizet;
			end
			meandata = this.sumdata(sumrange) / length(sumrange);
		end
		


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%update function
	
		function updatec(this)
			for t=1:this.sizet
				for z=1:this.sizez
					this.makergbdata(z,t);
				end
			end
			this.update;
		end
	
	end %methods
    
end
