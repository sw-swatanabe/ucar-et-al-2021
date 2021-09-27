%under construction

%121025 roi as cell array
%130915 background color and image area
%131013 current_t and current_z added

%to do list

%elliptic roi
%make compatible with image processing toolbox
%axrange as vector
%shiftx, shifty, rotation as vector
%average over t range (after shifting)
%rename some variables (main/mask/sub, data/image, xsize/ysize/zsize/tsize/chsize, etc)

%modify shift property
%shift = [shiftx, shifty];
%axrange = [axmin, axmax, aymin, aymax];

%to be modified
%append (main, mask, sub)
%axrange as vector
%shiftx, shifty, rotation as vector
%average over t range (after shifting)
%roi as cell array
%rename some variables (main/mask/sub, data/image, xsize/ysize/zsize/tsize/chsize, etc)

classdef imagedisp3 < handle
    
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
		
		datatype;					%obj or data
% 		datadim;					%number of dimensions in the data
		ndata = 0;					%number of data 
		
% 		datatop;
% 		databottom;
		
		keepstackdata = 0;			%set this to 1 to keep 3d stack data - necessary for using roistackval or linestackprof 
		keependdata = 0;			%set this to 1 to highlight end stacks
		
		sizex, sizey;
		sizez = 1;
		sizet;
		
		rgbdata, rgbdata_top, rgbdata_bottom;
		maskimage;
		maskcolor;
		maskparam = 'gray';
		binarymask = 0;
		binarymaskcheckboxh;
		
		rgbmin = 0; rgbmax = 4095;	%will be changed to apply to all images
		rgbminc, rgbmaxc;			%min and max common to all images (do not use this later)
		rgbmini, rgbmaxi;			%for individual image
		
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
		
		currentdata;
		
		current_z;
		current_t;
		
		
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
		%roicenterx, roicentery;		%center of rotation
		rgbdatar, rgbdatar_top, rgbdatar_bottom;
		rgbdatars, rgbdatars_top, rgbdatars_bottom;
		shiftx, shifty, angle;
		shift;						%[shiftx, shifty] - not available yet

		imageshifted = 0;			
		imagerotated = 0;
		imageshifted_all = 0;
		imagerotated_all = 0;
		
% 		alignrange = 80;			%search range for alignment
% 		aligncoarsestep = 4;
		

		% roi related properties
		%nrois;						%actual number of rois set in the image
% 		nroipt;						%actual points in the roi
		roicolor_default = 'm';
		roicolor_selected = 'y';
		roilinewidth_default = 2;
% 		
% 		roicolor;					%custom roi color for each roi
% 		roilinewidth;
% 		
% 		roimarker;
% 		selectedroi;
% 		
		enable_roiselect = 1;
		enable_roishift = 1;		
		roishift_allimages = 0;		%shift roi in all images by the same amount
% 		
% 		roitype;					%polygon or circle or rect
		
% 		roipt;						%cell array 
		
% 		roiradius;					%radius of circle roi
		roiradiusinit = 6;
		
		
		roi;						%cell array containing all roi params - not available yet

		
		roilist;					%list of active roi - not available yet
		
		%roi members
		%pt, npt, type, color, color_selected, linewidth, marker, selected, radius, shownum
			
% 		show_roinum;				%use this instead of hideroinum; set by showroinum / hideroinum
		
		
		% scale bar
		show_scalebar = 1;
		scalebarpos = [5 5];		
		scalebarlength = 1;			%um
		scalebarcolor = 'w';
		
		show_colorbar = 1;
		colorbartick = [];
		enable_colorbaredit = 1;
		rgbmaxedith, rgbminedith;
		
% 		show_subcolorbar = 1;
		subcolorbartick = [];
% 		enable_subcolorbaredit = 1;
		submaxedith, subminedith;

% 		show_maskcolorbar = 1;
		maskcolorbartick = [];
% 		enable_maskcolorbaredit = 1;
		maskmaxedith, maskminedith;

		
		
		show_fbutton = 1;
		%nfbuttons = 0;
		fbuttonf;
		fbuttonh;
		fbuttonstr;
		
		show_fparamedit = 1;
		fparamval;
		fparamedith;
		fparamstr;
		
		pixelsize;					%can be incorporated from the object
		
		frametime;
		zstackstep;
		
		%bleach points
		bleachpt, nbleachpt;		%can be incorporated from the object
		bleachcolor_default = 'c';
		bleachcolor;				%bleach point color for each bleach set
		bleachimage;				%lock bleachpt to the nth data
		bleachdispimage;
		
		comb;
		compmode;
		compint;
		
	%	sttext;						%static text
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
		
		% miscellaneous
% 		ignorefigclick = 0;
 		roistatus;					%struct
		
		roiclickcallbackf;
		
		
% 		target = 'fig';				%target of mouse events
    end
    
    methods
		
		
		%function this = imagedisp(data, varargin)
		function this = imagedisp3(varargin)
			nvarargin = size(varargin, 2);
			
			fignum = [];
			data = [];
			subdata = [];
			maskdata = [];
			
			for i=1:nvarargin
				
				if isnumeric(varargin{i}) && i==1
						%fignum = varargin{i};
						data = varargin{i};

% 						this.data{1} = varargin{i};
				end
				
				if ischar(varargin{i})
					switch varargin{i}
						case {'data', 'main', 'maindata'}
							data = varargin{i+1};
% 							this.data{1} = varargin{i+1};
% 						case {'sub', 'subdata'}
% 							this.subdata{1} = varargin{i+1};
% 						case {'mask', 'maskdata'}
% 							this.maskdata{1} = varargin{i+1};

						case 'stackdata'
							stackdata = varargin{i+1};
							this.keepstackdata = 1;
							
						case 'normal'
							this.dispmode = 'normal';
% 						case 'endcolor'
% 							this.dispmode = 'endcolor';
%                             this.keependdata = 1;
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
% 						case 'keepend'
% 							this.keependdata = 1;

						case 'fig'
							fignum = varargin{i+1};
						case 'noimage'
							this.noimage = 1;
							
					end
				end
				
			end
			
			%if exist('fignum', 'var')
			if ~isempty(fignum)
				this.figh = figure(fignum);
			else
				this.figh = figure;
			end
			
			if ~isempty(data)
				this.append('data', data, varargin{:});
			end		
			
		end %constructor

		
% 		function append(this, data, varargin) 
		function append(this, varargin) 
			%data can be an image object or a simple numeric data
			%for a numeric data, image object information can be optionally loaded
			
			nvarargin = size(varargin, 2);
			
			this.ndata = this.ndata +1;
			
			n = this.ndata;
			
			data = [];
			subdata = [];
			maskdata = [];
			stackdata = [];
			
			imgobj = [];
			%rmin = []; rmax = [];
			rmin = this.rgbmin; rmax = this.rgbmax;
			
			update = 1;
			
			for i=1:nvarargin

				if isnumeric(varargin{i}) && i==1
					%fignum = varargin{i};
					%data = varargin{i};
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

						case 'stamp'
							this.timestamp{n} = varargin{i+1};
						case 'time'
							this.time(n) = varargin{i+1};
						case 'fname'
							this.filename{n} = varargin{i+1};
% 							case 'obj'
% 								imgobj = varargin{i+1}; 
						case 'min'
							rmin  = varargin{i+1}; 
						case 'max'
							rmax  = varargin{i+1}; 	
						case 'n'
							n = varargin{i+1}; 	

						case 'update'
							update = 1;
						case 'noupdate'
							update = 0;
					end
				end
			end
			
		
% 			this.datadim = ndims(data);
% 			this.sizez = size(data, 3);
			this.sizez = 1;
% 3D data is no longer supported
% 			if this.datadim==3 
% 				this.data{n} = sum(data, 3);
% 				this.subdata{n} = sum(subdata, 3);
% 				this.maskdata{n} = sum(maskdata, 3);
% 
% 				if this.keepstackdata
% 					this.stackdata{n} = data;
% 				end
% 			else

				this.maskdata{n} = [];
				this.maskimage{n} = [];
				this.subdata{n} = [];
				this.subimage{n} = [];
				
				this.stackdata{n} = [];
			
				this.data{n} = data;
				this.subdata{n} = subdata;
				this.maskdata{n} = maskdata;
				this.stackdata{n} = stackdata;
% 			end

			if this.keepstackdata
				this.sizez = size(this.stackdata{n}, 3);
			end
			
			if ~isempty(imgobj)
				this.filename{n} = imgobj.filename;
				if n==1
					this.setparam(imgobj);
				end
			end
			
			if n==1
				this.sizex = size(this.data{n}, 1);
				this.sizey = size(this.data{n}, 2);
			end
			
% 			if isempty(this.rgbmini) || isempty(this.rgbmaxi)
% 					this.rgbmini = mmin(this.data{1});
% 					this.rgbmaxi = mmax(this.data{1}) * 0.5;
% 				
% 					this.endrgbmin = this.rgbmini * 0.1;
% 					this.endrgbmax = this.rgbmaxi * 0.1;
% 			end

		%new - set rgb min and max for each image
		
		%this part under construction
			if this.enable_individualcontrast
				
				if isempty(rmin) || isempty(rmax)
					data_sorted = sort(this.data{n}(:), 'descend');
				end
				
				if isempty(rmin)
					this.rgbmini(n) = data_sorted(round(length(data_sorted)*0.8));
				else
					this.rgbmini(n) = rmin;
				end
				if isempty(rmax)
					this.rgbmaxi(n) = mean(data_sorted(1:ceil(length(data_sorted)*0.05)));
				else
					this.rgbmaxi(n) = rmax;
				end

			
			else
				if n==1 && (isempty(this.rgbmin) || isempty(this.rgbmax))
					if (isempty(rmin) || isempty(rmax))
						data_sorted = sort(this.data{n}(:), 'descend');
					end

					if isempty(rmin)
						this.rgbmin = data_sorted(round(length(data_sorted)*0.8));
					else
						this.rgbmin = rmin;
					end
					if isempty(rmax)
						this.rgbmax = mean(data_sorted(1:ceil(length(data_sorted)*0.05)));
					else
						this.rgbmax = rmax;
					end
				end
				
				this.rgbmini(n) = this.rgbmin;
				this.rgbmaxi(n) = this.rgbmax;
			end
		
			
% 			%this.endrgbmin(n) = this.rgbmini(n) * 0.1;
% 			%this.endrgbmax(n) = this.rgbmaxi(n) * 0.1;
% 			this.endrgbmin(n) = this.rgbmini(n) * this.endrgbrate;
% 			this.endrgbmax(n) = this.rgbmaxi(n) * this.endrgbrate;

			this.shiftx(n) = 0;
			this.shifty(n) = 0;
			this.angle(n) = 0;
			
			if ~this.noimage
				this.makergbdata(n);
			end
			
% 			this.rgbdatar{n} = this.rgbdata{n};
% 			this.rgbdatars{n} = this.rgbdata{n};
				
			if n==1
				this.currentdata = 1;
			end

			if ~this.noimage && update
				this.currentdata = n;
				this.showimage(n);
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
			this.time = (0:this.ndata-1) * this.frametime / 1000;
		end
		
		
		function delete(this)

		end
		
		
		function retrieve(this, fignum)
			if nargin<2
				this.figh = figure;
			else
				this.figh = figure(fignum);
			end
			
			this.update;
		end
		
		function makergbdata(this, n)
			if this.enable_individualcontrast && ~isempty(this.contrastroi)
				contrastval = this.roisum(this.contrastroi);
				this.rgbmaxi(n) = this.rgbmax * (contrastval(n) / contrastval(1));
				this.rgbmini(n) = this.rgbmin;
			else
				this.rgbmaxi(n) = this.rgbmax;
				this.rgbmini(n) = this.rgbmin;
			end
				
			switch this.dispmode
% 				case 'endcolor' %simple z sum image
% 				%	if this.keependdata
% 						rgbcenter = data2rgb(this.data{n}, this.rgbmini(n), this.rgbmaxi(n), 'gray');
% 						rgbtop = data2rgb(this.datatop{n}, this.endrgbmin(n), this.endrgbmax(n), 'gray'); rgbtop(:,:, 1:2) = 0;
% 						rgbbottom = data2rgb(this.databottom{n}, this.endrgbmin(n), this.endrgbmax(n), 'gray'); rgbbottom(:,:, 2:3) = 0;
% 						this.rgbdata{n} = rgbcenter + rgbtop + rgbbottom;
%                         this.rgbdata{n} = min(max(this.rgbdata{n}, 0), 1);
% % 						this.rgbdata{n} = rgbcenter;
% % 						this.rgbdata_top{n} = rgbtop;
% % 						this.rgbdata_bottom{n} = rgbbottom;
% 				%	else
% 				%		this.rgbdata{n} = data2rgb(this.data{n}, this.rgbmini(n), this.rgbmaxi(n), this.rgbparam);
% 				%	end
					
				case 'overlay'
					this.rgbdata{n} = data2rgb(this.data{n}, this.rgbmini(n), this.rgbmaxi(n), 'gray'); 
                case 'normal'
                    this.rgbdata{n} = data2rgb(this.data{n}, this.rgbmini(n), this.rgbmaxi(n), this.rgbparam);

            end
				
			
			for i=1:3
				if ~isempty(this.maskdata{n})
% 					if ~isempty(this.maskthr) %avoid using this setting
% 						%if this.maskgain==0
% 						%	this.maskimage{n}(:,:,i) = max(this.maskdata{n}' - this.maskthr, 0);
% 						%else
% 						%	this.maskimage{n}(:,:,i) = (this.maskdata{n}' - this.maskthr) / this.maskgain;
% 						%end
% 						
% 						this.maskmin = this.maskthr;
% 						this.maskmax = this.maskthr + this.maskgain;
% 					end
% 					
						
					if this.maskmin >= this.maskmax
						%this.maskimage{n}(:,:,i) = max(this.maskdata{n}' - this.maskmin, 0);
						this.maskimage{n}(:,:,i) = (this.maskdata{n}' - this.maskmin) > 0;
					else
						this.maskimage{n}(:,:,i) = (this.maskdata{n}' - this.maskmin) / (this.maskmax - this.maskmin);
					end
					
					if ~isempty(this.maskcolor)
						this.rgbdata{n}(:,:,i) = this.rgbdata{n}(:,:,i) .* min(max(this.maskimage{n}(:,:,i), 0), 1) + (1 - min(max(this.maskimage{n}(:,:,i), 0), 1)) .* this.maskcolor(i);
					else
						this.rgbdata{n}(:,:,i) = this.rgbdata{n}(:,:,i) .* min(max(this.maskimage{n}(:,:,i), 0), 1);
					end

				end
			end
			

			if ~isempty(this.subdata{n})
				%this.subimage{n} = data2rgb(this.subdata{n}, this.submin(n), this.submax(n), this.subparam);
				this.subimage{n} = data2rgb(this.subdata{n}, this.submin, this.submax, this.subparam);
				if this.masksubimage
					for i=1:3
						this.subimage{n}(:,:,i) = this.subimage{n}(:,:,i) .* min(max(this.maskimage{n}(:,:,i), 0), 1);
					end
				end
				
				this.rgbdata{n} = this.rgbdata{n} * this.imageopacity + this.subimage{n} * this.subopacity;
			end
			
			this.rgbdata{n} = min(max(this.rgbdata{n}, 0), 1);
			


			%shift and rotate image - subimage moves with the main image, whereas mask does not
			this.rotate_image(n);
			this.shift_image(n);
			
		end
			
%{		
		function setbleachpt(this, bleachdata, varargin)
			nvarargin = length(varargin);
			
			bleachnum = 1;
			bleachimage = 0;
			bleachdispimage = [];
			bleachcolor = this.bleachcolor_default;
			bleachcompmode = 0;
			bleachcompint = 0;
			bleachcomb = 1;
			update = 1;
			
			for i=1:nvarargin
				
				if isnumeric(varargin{i})
					if i==1
						bleachnum = varargin{i};
					end
					
				else
					switch varargin{i}
						case 'bleachnum'
							bleachnum = varargin{i+1};
							
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
						case 'comb'
							bleachcomb = varargin{i+1};
						case 'compmode'
							bleachcompmode = varargin{i+1};
						case 'compint'
							bleachcompint = varargin{i+1};
						
						case 'update'
							update = 1;
						case 'noupdate'
							update = 0;
					end
				end
			end
			
			this.bleachimage(bleachnum) = bleachimage;
			
			if ~isempty(bleachdispimage)
				this.bleachdispimage(bleachnum) = bleachdispimage;	
			else
				this.bleachdispimage(bleachnum) = bleachimage;	
			end
			
			
			this.bleachcolor{bleachnum} = bleachcolor;
			this.bleachcomb{bleachnum} = bleachcomb;
			this.bleachcompmode{bleachnum} = bleachcompmode;
			this.bleachcompint{bleachnum} = bleachcompint;
			
			if isobject(bleachdata)
				this.bleachpt{bleachnum} = bleachdata.bleachpt;
				this.nbleachpt(bleachnum) = bleachdata.nbleachpt;
			else
				this.bleachpt{bleachnum} = bleachdata;
				this.nbleachpt(bleachnum) = size(bleachdata, 1);
			end
			
			if update
				this.update;
			end
			
		end
%}		
		function setbleachpt(this, varargin)
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
					
% 					this.roi{r}.pt = imgobj.roi{r}.pt;
% 					this.roi{r}.npt = imgobj.roi{r}.npt;
% 					this.roi{r}.type = imgobj.roi{r}.type;
% 					this.roi{r}.color = imgobj.roi{r}.color;
% 					this.roi{r}.linewidth =imgobj.roi{r}.linewidth;
% 					this.roi{r}.shiftx = imgobj.roi{r}.shiftx;
% 					this.roi{r}.shifty = imgobj.roi{r}.shifty;
% 					this.roi{r}.angle = imgobj.roi{r}.angle;
% 					this.roi{r}.shownum = imgobj.roi{r}.shownum;
% 					this.roi{r}.selected = imgobj.roi{r}.selected;

					if this.ndata > imgobj.ndata
						this.roi{r}.shiftx(imgobj.ndata+1:this.ndata) = this.shiftx(imgobj.ndata+1:this.ndata);
						this.roi{r}.shifty(imgobj.ndata+1:this.ndata) = this.shifty(imgobj.ndata+1:this.ndata);
						this.roi{r}.angle(imgobj.ndata+1:this.ndata) = this.angle(imgobj.ndata+1:this.ndata);
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
			
% 			if ~hideroinum
% 				this.roi{roinum}.shownum = 1;
% 			else
% 				this.roi{roinum}.shownum = 0;
% 			end
			for r = 1:length(roinum)
				if ~any(this.roilist==roinum(r))
					this.roilist = [this.roilist, roinum(r)];
				end
			end
			
			if update && ~this.noimage
				this.update;
			end
			
			
		end

		function setrois(this, varargin) %set multiple rois on the image
			nvarargin = length(varargin);
			
			firstroinum = [];
			varargin_t{:} = [];
			
			if nvarargin && isnumeric(varargin{1})
				firstroinum = varargin{1};
				for i=1:nvarargin-1
					varargin_t{i} = varargin{i+1};
				end
			else
				varargin_t = varargin;
			end
			
			
			if isempty(firstroinum)
% 				if any(this.nroipt)
% 					firstroinum = find(this.nroipt, 1, 'last') +1;
				if ~isempty(this.roilist)
					firstroinum = max(this.roilist) +1;
				else
					firstroinum = 1;
				end
			end
			
			
			this.enable_roiselect = 0;
			this.update;
			
			roinum = firstroinum;
			
			this.roistatus.continue = 1;
			this.roistatus.delete = 0;
			
			while this.roistatus.continue
				this.setroif(roinum, varargin_t{:})

				if this.roistatus.delete
					if roinum>2
% 						this.selectedroi(roinum-2) = 1;
						this.roi{roinum-2}.selected = 1;
					end
					if roinum>1
						this.deleteroi(roinum-1);
						roinum = roinum -2;
					end
					
					this.roistatus.delete = 0;
				end
				
				this.update;
				
				roinum = roinum +1;
			end
			
			if roinum > firstroinum +1
% 				this.selectedroi(roinum-2) = 1;
				this.roi{roinum-2}.selected = 1;
			end
			
			this.enable_roiselect = 1;
			this.update
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
				
% 				if printroival && this.roistatus.completed
% 					this.printval(roinum);
% 				end
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
% 					for roinum = varargin{i}
					listselected =[];
					for rnum = 1:length(varargin{i})
						listselected = [listselected, find(this.roilist == varargin{i}(rnum))];
					end
					this.roilist(listselected) = [];
% 						this.roilist(varargin{i}) = [];
% 					end
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
		
		
		function printstamp(this)
			%fprintf('\t\t\t\t');
			fprintf('%d\t', cell2mat(this.timestamp));
			fprintf('\n');
		end


		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% roi analysis functions
	
    %common
		function roipattern = roipat(this, roinum)

			switch this.roi{roinum}.type
				case 'polygon'
					roipattern = roipat_polygon(this.roi{roinum}.pt, this.sizex, this.sizey);
				case 'circle'
					roipattern = roipat_circle(this.roi{roinum}.pt, this.roi{roinum}.radius, this.sizex, this.sizey);
				case 'rect'
					roipattern = roipat_rect(this.roi{roinum}.pt, this.sizex, this.sizey);
			end
		end
		
		function roipattern = roipatm(this, roinum) %pixels in the roi without masking
			for n=1:this.ndata
				maskrs =  this.datarotateshift(this.maskdata{n}, n);
				roipattern{n} = this.roipat(roinum) .* ( (maskrs - this.maskmin) >0 ); %bug fixed 110329
			end
		end
		
	%new functions compatible with roi shifting
		function roipattern = roip(this, roinum)
			roipattern = zeros(this.sizex, this.sizey, this.ndata);

% 			switch this.roi{roinum}.type
% 				case 'polygon'
% 					for n=1:this.ndata
% 						roipattern(:,:,n) = this.rotateshiftdata( roipat_polygon(this.roi{roinum}.pt, this.sizex, this.sizey), ...
% 															this.roi{roinum}.shiftx(n), this.roi{roinum}.shifty(n), this.roi{roinum}.angle(n) );
% 					end
% 				case 'circle'
% 					for n=1:this.ndata
% 						roipattern(:,:,n) = this.rotateshiftdata( roipat_circle(this.roi{roinum}.pt, this.roi{roinum}.radius, this.sizex, this.sizey), ...
% 															this.roi{roinum}.shiftx(n), this.roi{roinum}.shifty(n), this.roi{roinum}.angle(n) );
% 					end
% 				case 'rect'
% 					for n=1:this.ndata
% 						roipattern(:,:,n) = this.rotateshiftdata( roipat_rect(this.roi{roinum}.pt, this.sizex, this.sizey), ...
% 							this.roi{roinum}.shiftx(n), this.roi{roinum}.shifty(n), this.roi{roinum}.angle(n) );
% 					end
% 			end
% 			
			
			switch this.roi{roinum}.type
				case 'polygon'
					roipattern_raw = roipat_polygon(this.roi{roinum}.pt, this.sizex, this.sizey);
				case 'circle'
					roipattern_raw = roipat_circle(this.roi{roinum}.pt, this.sizex, this.sizey);
				case 'rect'
					roipattern_raw = roipat_rect(this.roi{roinum}.pt, this.sizex, this.sizey);
			end
			
			if any( [this.roi{roinum}.shiftx,  this.roi{roinum}.shifty, this.roi{roinum}.angle] )
				for n=1:this.ndata
					roipattern(:,:,n) = this.rotateshiftdata( roipattern_raw, this.roi{roinum}.shiftx(n), this.roi{roinum}.shifty(n), this.roi{roinum}.angle(n) );
				end
			else
				for n=1:this.ndata
					roipattern(:,:,n) = roipattern_raw;
				end
			end
			
			
		end
		
		%not updated as roip
		function roipattern = roipm(this, roinum) %pixels in the roi without masking
			roipattern = zeros(this.sizex, this.sizey, this.ndata);
			roipattern_raw = this.roip(roinum);
			for n=1:this.ndata
				maskrs =  this.rotateshiftdata(this.maskdata{n}, this.sizex, this.sizey, 0);
				roipattern(:,:,n) = roipattern_raw(:,:,n) .* ( (maskrs - this.maskmin) >0 );
			end
		end
		
		
		function r = roiarea(this, roinum) %for nroipt >=3
			roipattern = this.roip(roinum);
 			r = msum(roipattern(:,:,1));
		end
		
		function r = roiaream(this, roinum) %ndata points
			roipattern = this.roipm(roinum);
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n));
			end
		end
	
		function r = roiimage(this, roinum) %roi data, only for rect roi
			for n=1:this.ndata
				for i=1:3
					r{n}(:,:,i) = this.rgbdatars{n}( round(min(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shiftx) : round(max(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shiftx), ...
								  round(min(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shifty) : round(max(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shifty) , i);
				end
			end
		end
		
	%main data
		function r = roidata(this, roinum) %roi data, only for rect roi
			for n=1:this.ndata
				datashift = this.datarotateshift(this.data{n}, n);
				r{n} = datashift( round(min(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shiftx) : round(max(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shiftx), ...
								  round(min(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shifty) : round(max(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shifty) );
			end
		end
		
		function r = roival(this, roinum)
			r = this.roisum(roinum);
		end
		
		function r = roisum(this, roinum)
			roipattern = this.roip(roinum);
			
			r = zeros(1, this.ndata);
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n) .* this.data{n});
			end
		end
		
		function r = roisumm(this, roinum) %pixels without masking
% 			roipattern = this.roipatm(roinum);
			roipattern = this.roipm(roinum);
			
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n) .* this.data{n});
			end
		end
				
		function r = roistackval(this, roinum)
			r = this.roistacksum(roinum);
		end

		function r = roistacksum(this, roinum) %for z stack
			roipattern = this.roip(roinum);
			
			r = zeros(this.sizez, this.ndata);
			for n=1:this.ndata
				for z=1:this.sizez
% 					datashift = this.datarotateshift(this.stackdata{n}(:,:,z), n);
% 					r(z, n) = msum(roipattern .* datashift);
					r(z, n) = msum(roipattern(:,:,n) .* this.stackdata{n}(:,:,z));
				end
			end
		end
		
		function r = roistacksumm(this, roinum) %pixels without masking
			roipattern = this.roipm(roinum);
			
			r = zeros(this.sizez, this.ndata);
			for n=1:this.ndata
				for z=1:this.sizez
					r(z, n) = msum(roipattern(:,:,n) .* this.stackdata{n}(:,:,z));
				end
			end
		end
				
		function r = roimean(this, roinum)
			roipattern = this.roip(roinum);
			roiarea = this.roiarea(roinum);
			
			r = zeros(1, this.ndata);
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n) .* this.data{n}) / roiarea;
			end
		end

		function r = roimeanm(this, roinum) %pixels without masking
			roipattern = this.roipm(roinum);
			roiarea = this.roiaream(roinum);
			
			r = zeros(1, this.ndata);
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n) .* this.data{n}) / roiarea(n);
			end
		end
				
		function r = roistackmean(this, roinum) %for z stack
			roipattern = this.roip(roinum);
			roiarea = this.roiarea(roinum);
			
			r = zeros(this.sizez, this.ndata);
			for n=1:this.ndata
				for z=1:this.sizez
					r(z, n) = msum(roipattern .* this.stackdata{n}(:,:,z)) / roiarea;
				end
			end
		end
		
		function r = roistackmeanm(this, roinum) %pixels without masking
			roipattern = this.roipm(roinum);
			roiarea = this.roiaream(roinum);
			
			r = zeros(this.sizez, this.ndata);
			for n=1:this.ndata
				for z=1:this.sizez
					r(z, n) = msum(roipattern(:,:,n) .* this.stackdata{n}(:,:,z)) / roiarea;
				end
			end
		end
				
		function r = roipixels(this, roinum) %all pexels in the roi aligned in one dim
			roipattern = this.roip(roinum);
			
			for n=1:this.ndata
				r(:, n) = this.data{n}(find(roipattern(:,:,n)));
			end
		end

		function r = roipixelsm(this, roinum) %all pexels in the roi aligned in one dim
			roipattern = this.roipm(roinum);
			
			for n=1:this.ndata
				r{n} = this.data{n}(find(roipattern(:,:,n)));
			end
		end

		
		function r = lineprof(this, roinum)
			[linept, lineptwt] = linepoints(this.roi{roinum}.pt);
			nlinept = size(linept, 1);
			
			r = zeros(nlinept, this.ndata);
			
			for n=1:this.ndata
				lineptshift = [linept(:,1)+this.roi{roinum}.shiftx(n), linept(:,2)+this.roi{roinum}.shifty(n)];
				
				for i=1:nlinept
					r(i, n) = msum(this.data{n}(lineptshift(i,1):lineptshift(i,1)+1, lineptshift(i,2):lineptshift(i,2)+1) .* lineptwt(:,:,i) );
				end
			end
		end
		
		function r = linestackprof(this, roinum) %for zstack
			[linept, lineptwt] = linepoints(this.roi{roinum}.pt);
			nlinept = size(linept, 1);
			
			r = zeros(nlinept, this.sizez, this.ndata);
			
			for n=1:this.ndata
				lineptshift = [linept(:,1)+this.roi{roinum}.shiftx(n), linept(:,2)+this.roi{roinum}.shifty(n)];
				
				for z=1:this.sizez
					
					for i=1:nlinept
						r(i, z, n) = msum(this.data{n}(lineptshift(i,1):lineptshift(i,1)+1, lineptshift(i,2):lineptshift(i,2)+1) .* lineptwt(:,:,i), z);
					end
				end
			end
		end
		
	%sub data
		
		function r = subroidata(this, roinum) %roi data, only for rect roi
			for n=1:this.ndata
				datashift = this.datarotateshift(this.subdata{n}, n);
				r{n} = datashift( round(min(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shiftx) : round(max(this.roi{roinum}.pt(:,1)) +this.roi{roinum}.shiftx), ...
								  round(min(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shifty) : round(max(this.roi{roinum}.pt(:,2)) +this.roi{roinum}.shifty) );
			end
		end
		
	
		function r = subroival(this, roinum)
			r = this.subroisum(roinum);
		end
		
		function r = subroisum(this, roinum)
			roipattern = this.roip(roinum);
			
			r = zeros(1, this.ndata);
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n) .* this.subdata{n});
			end
		end

		
		
		function r = subroisumm(this, roinum) %pixels without masking
			roipattern = this.roipm(roinum);
			
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n) .* this.subdata{n});
			end
		end
		
		


		function r = subroistackval(this, roinum)
			r = this.subroistacksum(roinum);
		end

		function r = subroistacksum(this, roinum) %for z stack
			roipattern = this.roip(roinum);
			
			r = zeros(this.sizez, this.ndata);
			for n=1:this.ndata
				for z=1:this.sizez
					r(z, n) = msum(roipattern(:,:,n) .* this.substackdata{n}(:,:,z));
				end
			end
		end
		
		function r = subroistacksumm(this, roinum) %pixels without masking
			roipattern = this.roipm(roinum);
			
			r = zeros(this.sizez, this.ndata);
			for n=1:this.ndata
				for z=1:this.sizez
					r(z, n) = msum(roipattern(:,:,n) .* this.substackdata{n}(:,:,z));
				end
			end
		end
		
		

				
		function r = subroimean(this, roinum)
			roipattern = this.roip(roinum);
			
			r = zeros(1, this.ndata);
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n) .* this.subdata{n}) / this.roiarea(roinum);
			end
		end

		function r = subroimeanm(this, roinum) %pixels without masking
			roipattern = this.roipm(roinum);
			roiarea = this.roiaream(roinum);
			
			r = zeros(1, this.ndata);
			for n=1:this.ndata
				r(n) = msum(roipattern(:,:,n) .* this.subdata{n}) / roiarea(n);
			end
		end
		

				
		function r = subroistackmean(this, roinum) %for z stack
			roipattern = this.roip(roinum);
			
			r = zeros(this.sizez, this.ndata);
			for n=1:this.ndata
				for z=1:this.sizez
					r(z, n) = msum(roipattern .* this.substackdata{n}(:,:,z)) / this.roiarea(roinum);
				end
			end
		end
		
		function r = subroistackmeanm(this, roinum) %pixels without masking
			roipattern = this.roipm(roinum);
			roiarea = this.roiaream(roinum);
			
			r = zeros(this.sizez, this.ndata);
			for n=1:this.ndata
				for z=1:this.sizez
					r(z, n) = msum(roipattern(:,:,n) .* this.substackdata{n}(:,:,z)) /roiarea(n);
				end
			end
		end
		
%
		
		function r = subroipixels(this, roinum) %all pexels in the roi aligned in one dim
			roipattern = this.roip(roinum);
			
			for n=1:this.ndata
				r(:, n) = this.subdata{n}(find(roipattern(:,:,n)));
			end
		end

		function r = subroipixelsm(this, roinum) %all pexels in the roi aligned in one dim
			roipattern = this.roipm(roinum);
			
			for n=1:this.ndata
				r{n} = this.subdata{n}(find(roipattern(:,:,n)));
			end
		end


		
		function r = sublineprof(this, roinum)
			[linept, lineptwt] = linepoints(this.roi{roinum}.pt);
			nlinept = size(linept, 1);
			
			r = zeros(nlinept, this.ndata);
			
			for n=1:this.ndata
				lineptshift = [linept(:,1)+this.roi{roinum}.shiftx(n), linept(:,2)+this.roi{roinum}.shifty(n)];
				
				for i=1:nlinept
					r(i, n) = msum(this.subdata{n}(lineptshift(i,1):lineptshift(i,1)+1, lineptshift(i,2):lineptshift(i,2)+1) .* lineptwt(:,:,i) );
				end
			end
		end
		
		function r = sublinestackprof(this, roinum) %for zstack
			[linept, lineptwt] = linepoints(this.roi{roinum}.pt);
			nlinept = size(linept, 1);
			
			r = zeros(nlinept, this.sizez, this.ndata);
			
			for n=1:this.ndata
				lineptshift = [linept(:,1)+this.roi{roinum}.shiftx(n), linept(:,2)+this.roi{roinum}.shifty(n)];
				
				for z=1:this.sizez
					
					for i=1:nlinept
						r(i, z, n) = msum(this.subdata{n}(lineptshift(i,1):lineptshift(i,1)+1, lineptshift(i,2):lineptshift(i,2)+1) .* lineptwt(:,:,i), z);
					end
				end
			end
		end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%image manipulation functions
	%note - the direction of rotation for the image is opposite to that for the data

	%image
		function rotate_image(this, n)
			if this.angle(n)
				for col=1:3
					this.rgbdatar{n}(:,:,col) = imagerotate(this.rgbdata{n}(:,:,col), this.angle(n) * 180 /pi);
                end
            else
                this.rgbdatar{n} = this.rgbdata{n};
            end
		end
		
		function shift_image(this, n)
			if any([this.shiftx(n), this.shifty(n)])
% 				this.rgbdatars{n} = zeros(this.sizey, this.sizex, 3);
				if ischar(this.backgroundcolor)
					bgcolor = rem(floor((strfind('kbgcrmyw', this.backgroundcolor) - 1) * [0.25 0.5 1]), 2);
				else
					bgcolor = this.backgroundcolor;
				end
				
				for col=1:3
					this.rgbdatars{n}(:,:,col) = ones(this.sizey, this.sizex) * bgcolor(col);
				end
				
				this.rgbdatars{n}( max(1, 1+this.shifty(n)) : min(this.sizey, this.sizey+this.shifty(n)), max(1, 1+this.shiftx(n)) : min(this.sizex, this.sizex+this.shiftx(n)), :) ...
					= this.rgbdatar{n}( max(1, 1-this.shifty(n)) : min(this.sizey, this.sizey-this.shifty(n)), max(1, 1-this.shiftx(n)) : min(this.sizex, this.sizex-this.shiftx(n)), :);
            else
				this.rgbdatars{n} = this.rgbdatar{n};
			end
		end


		
	%main data
		function datars = datarotateshift(this, data, n)
			datars = this.datashift(this.datarotate(data, n), n);
		end
	
		function datar = datarotate(this, data, n) %for raw data
			if this.angle(n)
				datar = imagerotate(data, -this.angle(n) * 180 /pi);
			else
				datar = data;
			end
		end
		
		function datars = datashift(this, datar, n)
			if any([this.shiftx(n), this.shifty(n)])
				datars = zeros(this.sizex, this.sizey);

				datars( max(1, 1+this.shiftx(n)) : min(this.sizex, this.sizex+this.shiftx(n)), max(1, 1+this.shifty(n)) : min(this.sizey, this.sizey+this.shifty(n)) ) ...
					= datar( max(1, 1-this.shiftx(n)) : min(this.sizex, this.sizex-this.shiftx(n)), max(1, 1-this.shifty(n)) : min(this.sizey, this.sizey-this.shifty(n)) );
			else
				datars = datar;
			end
		end
		
		
		
	%general functions, recommended to use these functions
		
		function datars = rotateshiftdata(this, data, shiftx, shifty, angle)
			if isempty(angle) || angle==0
				datars = this.shiftdata(data, shiftx, shifty);
			else
				datars = this.shiftdata(this.rotatedata(data, angle), shiftx, shifty);
			end
		end
		
		function datas = shiftdata(this, data, shiftx, shifty)
			datas = zeros(size(data));
			sizex = size(data, 1);
			sizey = size(data, 2);
			
			if shiftx==0 && shifty==0
				datas = data;
			else
				datas( max(1, 1+shiftx) : min(sizex, sizex+shiftx), max(1, 1+shifty) : min(sizey, sizey+shifty) ) ...
					= data( max(1, 1-shiftx) : min(sizex, sizex-shiftx), max(1, 1-shifty) : min(sizey, sizey-shifty) );
			end
		end
		
		function datar = rotatedata(this, data, angle) %for raw data
			if angle==0
				datar = data;
			else
				datar = imagerotate(data, -angle * 180 /pi);
			end
		end
		

		
		function [xrs,yrs] = rgbptrotateshift(this, x, y, n)
			xcenter = floor(this.sizex /2); %same algorithm as imagerotate.mex
			ycenter = floor(this.sizey /2); 
			
			xr =  cos(this.angle(n)) * (x - xcenter)  - sin(this.angle(n)) * (y - ycenter) + xcenter; 
			yr =  sin(this.angle(n)) * (x - xcenter)  + cos(this.angle(n)) * (y - ycenter) + ycenter;
			xrs = xr + this.shiftx(n);
			yrs = yr + this.shifty(n);
		end
		
		function [xr,yr] = rgbptrotate(this, x, y, n)
			xcenter = floor(this.sizex /2); %same algorithm as imagerotate.mex
			ycenter = floor(this.sizey /2); 
			
			xr =  cos(this.angle(n)) * (x - xcenter)  - sin(this.angle(n)) * (y - ycenter) + xcenter; 
			yr =  sin(this.angle(n)) * (x - xcenter)  + cos(this.angle(n)) * (y - ycenter) + ycenter;
		end

		function [xrs,yrs] = rgbptshift(this, xr, yr, n)
			xrs = xr + this.shiftx(n);
			yrs = yr + this.shifty(n);
		end

		
		function resetshift(this, varargin)
			nvarargin = length(varargin);
			
			if nvarargin
				if isnumeric(varargin)
					this.shiftx(varargin) = 0;
					this.shifty(varargin) = 0;
					this.angle(varargin) = 0;
				end
				
				if ischar(varargin) && strcmp(varargin, 'all')
					for n=1:this.ndata
						this.shiftx(n) = 0;
						this.shifty(n) = 0;
						this.angle(n) = 0;
					end
				end
			else
				for n=1:this.ndata
					this.shiftx(n) = 0;
					this.shifty(n) = 0;
					this.angle(n) = 0;
				end
			end
			
			this.imagerotated = 1;
			this.imageshifted = 1;
			this.updatec;
		end

		
		%sum image over series
		
		
		function sumdata = sumdata(this, sumrange)
			if nargin<2
				sumrange = 1:this.ndata;
			end
			
			sumdata = zeros(this.sizex, this.sizey);
			
			for t=sumrange
				datashift = this.datarotateshift(this.data{t}, t);
				sumdata = sumdata + datashift;
			end
				
			sumdata(1 : max(this.shiftx), :) = 0;
			sumdata(this.sizex+1+min(this.shiftx) : this.sizex, :) = 0;
			sumdata(:, 1 : max(this.shifty)) = 0;
			sumdata(:, this.sizey+1+min(this.shifty) : this.sizey) = 0;
		end
		
		function meandata = meandata(this, sumrange)
			if nargin<2
				sumrange = 1:this.ndata;
			end
			
			meandata = this.sumdata(sumrange) / length(sumrange);
		end
		
		
		function showimage(this, imagenum, varargin)
			this.currentdata = imagenum;
			this.update(varargin);
		end
		
		function n = t2n(this, t)
			n = (t -1) * this.sizez + this.current_z(t);
		end
		
		function setmin(this)
			this.contrast('min');
		end
		
		function setmax(this)
			this.contrast('max');
		end
		
		%{
		function contrast(this, varargin)
			adjustlevel = 'max';
			
			if any(strcmp(varargin, 'max'))
				adjustlevel = 'max';
			end
			if any(strcmp(varargin, 'min'))
				adjustlevel = 'min';
			end
			
			temproinum = length(this.nroipt) +1;
			this.setroi(temproinum, 'rect');
			
			roirangex = round(min(this.roipt{temproinum}(:,1))) : round(max(this.roipt{temproinum}(:,1)));
			roirangey = round(min(this.roipt{temproinum}(:,2))) : round(max(this.roipt{temproinum}(:,2)));
			
			
			for n=1:this.ndata
				datars = this.datarotateshift(this.data{n}, n);
				roidata = datars(roirangex, roirangey);
				
				if strcmp(adjustlevel, 'max')
					this.rgbmaxi(n) = mmax(roidata) * 0.5;
				end
				if strcmp(adjustlevel, 'min')
					this.rgbmini(n) = mmean(roidata);
				end
				
				this.endrgbmin(n) = this.rgbmini(n) * this.endrgbrate;
				this.endrgbmax(n) = this.rgbmaxi(n) * this.endrgbrate;
			end
			
			this.deleteroi(temproinum);
			this.update('contrastall');
		end
		%}
			

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%update function
	
% 		function updatec(this)
% 			this.update('contrastall');
% 		end
		function updatec(this, varargin)
			if isempty(varargin)
				this.update('contrastall');
			else
				this.contrastroi = varargin;
				this.update('contrastall');
			end
		end
		
		function updates(this)
			this.update('shiftall');
		end
		
		function updateci(this)
			this.update('contrast');
		end
	
	end %methods
    
end
