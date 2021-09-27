%only for FV version 2 or later
%for FV version 1, use fvdata_ver1
%last updated 131215

function this = fvdata(filepath, filename, varargin) %varargin - medfiltsize, averagesize, 'ch', 't', 'z', 'paramonly'
	
	nvarargin = length(varargin);


	this.filepath = filepath;
	this.filename = filename; 

	medfiltsize = 1;
	averagesize = 1;
	paramonly = 0;
	
	chrange = [];
	trange = [];
	zrange = [];

	loadtime = 1;
	dispt = 0;
	zsum = 0;

	for i=1:nvarargin

		if ischar(varargin{i})
			switch(varargin{i})
				case 'paramonly'
					paramonly = 1;

				case 'ch'
					chrange = varargin{i+1};
				case 't'
					trange = varargin{i+1};
				case 'z'
					zrange = varargin{i+1};

				case 'med'
					medfiltsize = varargin{i+1};
				case 'av'
					averagesize = varargin{i+1}; %scalar or vector [fsizex,fsizey]

				case 'zsum'
					zsum = 1;

				case 'dispt'
					dispt = 1;
			end

		end
	end

	this.bleachpt = [];
	this.nbleachpt = 0;
	this.comb = [];
	this.compmode = [];
	this.compint = [];
	
	this.roix = [];
	this.roiy = [];
	
	
	%%%%%% get parameters from the oif file %%%%%% 
	
% 	if iscell(filepath)
% 		paramfname = [filepath{:} '\' filename{:} '.oif'];
% 	else
		paramfname = [filepath '\' filename '.oif'];
% 	end
	
	paramfid = fopen(paramfname, 'r');

	sectionstr = '';

	pointcombstr = {''};
	pointposxstr = {''};
	pointposystr = {''};
	
	while 1

		tline = fgetl(paramfid);
		if ~ischar(tline);  break;  end
		tempstrext = tline(2:2:end);

		if ~isempty(tempstrext) && tempstrext(1)=='['
			sectionstr = tempstrext(2:end-1);
		end

		if any(tempstrext == '=')
			tokens = regexp(tempstrext, '(.*)=(.*)', 'tokens');
			key = tokens{1, 1}{1,1};
			val = tokens{1, 1}{1,2};

			if ~isempty(sectionstr) && strcmp(sectionstr, 'Acquisition Parameters Common')

				switch key
					case 'ScanMode'
						this.scanmode = val(2:end-1);

					case 'SamplingClock'
						this.samplingclock = str2num(val);

					case 'ZoomValue'
						this.zoomvalue = str2num(val);

				end
			end

			if ~isempty(sectionstr) && strcmp(sectionstr, 'Bleach GUI Parameters Common')
				switch key
					case 'Comb 0 Complement Mode'
						this.compmode(1) = str2num(val);
					case 'Comb 0 Complement Mode Interval'
						this.compint(1) = str2num(val);
					case 'Comb 1 Complement Mode'
						this.compmode(2) = str2num(val);
					case 'Comb 1 Complement Mode Interval'
						this.compint(2) = str2num(val);
					case 'Comb 2 Complement Mode'
						this.compmode(3) = str2num(val);
					case 'Comb 2 Complement Mode Interval'
						this.compint(3) = str2num(val);

					case 'Number Of Point'
						this.nbleachpt = str2num(val);
				end
				
				
				for i=1:this.nbleachpt

					if strcmp(key, ['Point ', num2str(i-1), ' Comb'])
						this.comb(i) =  str2num(val) +1;
					end
					
					if strcmp(key,  ['Point ', num2str(i-1), ' Position X'])
						this.bleachx_abs(i) =  str2num(val) +1;
					end
					
					if strcmp(key,  ['Point ', num2str(i-1), ' Position Y'])
						this.bleachy_abs(i) =  str2num(val) +1;
					end

				end
			end

			switch key

				case 'AxisCode'
					currentaxis = val(2:end-1);

				case 'EndPosition';
					switch currentaxis
						case 'X'
							lengthx = str2num(val);
						case 'Y'
							lengthy = str2num(val);
						case 'Z'
							zstackendposition = str2num(val);
						case 'T'
							this.totaltime = str2num(val);
					end

				case 'StartPosition'
					switch currentaxis
						case 'Z'
							zstackstartposition = str2num(val);
					end

				case 'MaxSize'
					switch currentaxis
						case 'X'
							this.sizex = str2num(val);
						case 'Y'
							this.sizey = str2num(val);
						case 'C'
							this.nchannelsall = str2num(val);
							this.sizec_all = str2num(val);
						case 'Z'
							this.nzstacksall = str2num(val);
							this.sizez_all = str2num(val);
						case 'T'
							this.nframesall = str2num(val);
							this.sizet_all = str2num(val);
					end

				case 'IniFileName0'
					inifilename = val(2:end-1);

				case 'RoiFileName0'
					roifilename = val(2:end-1);

				case 'SystemVersion'
					this.systemversion = str2num(val(2));
			end

		end %if any

	end %while 1

	fclose(paramfid);


	for i=1:this.nbleachpt
		this.bleachptabs(i,1) = this.bleachx_abs(i);
		this.bleachptabs(i,2) = this.bleachy_abs(i);
	end


	if this.nframesall == 0
		this.nframesall = 1;
	end
	if this.sizet_all == 0
		this.sizet_all = 1;
	end
	if this.nzstacksall == 0
		this.nzstacksall = 1;
	end
	if this.sizez_all == 0
		this.sizez_all = 1;
	end

	if ~isempty(this.totaltime) && this.sizet_all >1
		this.frametime = this.totaltime / (this.sizet_all -1);
	else
		this.frametime = 0;
	end

	if exist('zstackendposition', 'var') && exist('zstackstartposition', 'var') && this.sizez_all >1
		this.zstep = (zstackendposition - zstackstartposition) / (this.sizez_all -1) / 1000;
		this.stepz = this.zstep;
	else
		this.stepz = 0;
	end
	if exist('lengthx', 'var') && this.sizex >1
		this.pixelsize = lengthx / (this.sizex -1);
	else
		this.pixelsize = 0;
	end


	%%%%% get roi and bleaching parameters from the roi file %%%%%

	roifname = [filepath '\' roifilename];
	roifid = fopen(roifname, 'r');

	nbleachpt = 0;

	while 1

		tline = fgetl(roifid);
		if ~ischar(tline),   break,   end

		tempstrext = tline(2:2:end);


		if any(tempstrext == '=')
			tokens = regexp(tempstrext, '(.*)=(.*)', 'tokens');
			key = tokens{1, 1}{1,1};
			val = tokens{1, 1}{1,2};


			switch key
				case 'SCAN'
					switch str2num(val)
						case 1
							scanroi = 1;
						case 0
							scanroi = 0;
					end
				case 'BLEACH'
					switch  str2num(val)
						case 1
							bleachroi = 1;
						case 0
							bleachroi = 0;
					end

				case 'X'
					if scanroi
						this.roix = str2num(val);
					end
					
				case 'Y'
					if scanroi
						this.roiy = str2num(val);
					end
					
			end

		end %if any

	end %while 1

	fclose(roifid);


	for n=1:this.nbleachpt

		if length(this.bleachx_abs(1))==1

			if ~isempty(this.roix) && any(this.scanmode == 'Y') %2D roi scan
				this.bleachpt(n, 1) = this.bleachptabs(n, 1) - min(this.roix) +1;
				this.bleachpt(n, 2) = this.bleachptabs(n, 2) - min(this.roiy) +1;
			else
				this.bleachpt(n, 1) = this.bleachptabs(n, 1);
				this.bleachpt(n, 2) = this.bleachptabs(n, 2);
			end					

		else %roi stim, etc

			if ~isempty(this.roix) && any(this.scanmode == 'Y') %2D roi scan
				this.bleachpt(n, 1, :) = this.bleachptabs(n, 1, :) - min(this.roix) +1;
				this.bleachpt(n, 2, :) = this.bleachptabs(n, 2, :) - min(this.roiy) +1;
			else
				this.bleachpt(n, 1, :) = this.bleachptabs(n, 1, :);
				this.bleachpt(n, 2, :) = this.bleachptabs(n, 2, :);
			end

		end
		
	end

	%%%%% load the data %%%%%

	if ~paramonly

		if isempty(chrange)
			chrange = 1:this.sizec_all;
		end
		if isempty(trange)
			trange = 1:max(this.sizet_all, 1);
		end
		if isempty(zrange)
			zrange = 1:max(this.sizez_all, 1);
		end

		this.chrange = chrange;
		this.trange = trange;
		this.zrange = zrange;

		channels = length(chrange);
		frames = length(trange);
		stacks = length(zrange);

		this.nchannels = channels;
		this.nframes = frames;
		this.nzstacks = stacks;
		this.sizec = length(chrange);
		this.sizet = length(trange);
		this.sizez = length(zrange);

% 		if this.systemversion==1
% 			datafnamecommon = [this.filepath '\' this.filename '.oif.files\' this.filename '_'];	% FV version 1
% 		else
			datafnamecommon = [this.filepath '\' this.filename '.oif.files\s_'];	% FV version 2
% 		end

		if dispt
			fprintf('%d - ', frames);
		end

		switch this.scanmode
			case 'XY'
				this.data = zeros(this.sizex, this.sizey, channels); 
				for ch = 1:channels
					datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d') '.tif'];
					this.data(:,:, ch) = filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
				end

			case 'XYT'
				this.data = zeros(this.sizex, this.sizey, frames, channels); 
				this.time = zeros(1, frames); 
				for ch = 1:channels
					for t = 1:frames
						if dispt
							fprintf('%d ', t);
						end
						datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  'T' num2str(trange(t), '%.3d') '.tif'];
						this.data(:,:, t, ch) = filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
						if loadtime && ch==1
							ptyfname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  'T' num2str(trange(t), '%.3d') '.pty'];
							this.time(t) = gettime(ptyfname);
						end
					end
				end

			case 'XYZ'
				if ~zsum
					this.data = zeros(this.sizex, this.sizey, stacks, channels); 
					for ch = 1:channels
						for z = 1:stacks
							datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  'Z' num2str(zrange(z), '%.3d') '.tif'];
							this.data(:,:, z, ch) = filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
						end
					end
				else
					this.data = zeros(this.sizex, this.sizey, channels); 
					for ch = 1:channels
						for z = 1:stacks
							datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  'Z' num2str(zrange(z), '%.3d') '.tif'];
							this.data(:,:, ch) = this.data(:,:, ch) + filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
						end
					end
				end

			case 'XYZT'
				if ~zsum
					this.data = zeros(this.sizex, this.sizey, stacks, frames, channels); 
					this.time = zeros(1, frames); 
					for ch = 1:channels
						for t = 1:frames
							if dispt
								fprintf('%d ', t);
							end
							for z = 1:stacks
								datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  'Z' num2str(zrange(z), '%.3d') 'T' num2str(trange(t), '%.3d') '.tif'];
								this.data(:,:, z, t, ch) = filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
								if loadtime && z==1 && ch==1
									ptyfname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  'Z' num2str(zrange(z), '%.3d') 'T' num2str(trange(t), '%.3d') '.pty'];
									this.time(t) = gettime(ptyfname);
								end
							end
						end
					end
				else
					this.data = zeros(this.sizex, this.sizey, frames, channels); 
					this.time = zeros(1, frames); 
					for ch = 1:channels
						for t = 1:frames
							if dispt
								fprintf('%d ', t);
							end
							for z = 1:stacks
								datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  'Z' num2str(zrange(z), '%.3d') 'T' num2str(trange(t), '%.3d') '.tif'];
								this.data(:,:, t, ch) = this.data(:,:, t, ch) + filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
								if loadtime && z==1 && ch==1
									ptyfname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  'Z' num2str(zrange(z), '%.3d') 'T' num2str(trange(t), '%.3d') '.pty'];
									this.time(t) = gettime(ptyfname);
								end
							end
						end
					end
				end

			case 'XT'
				this.data = zeros(this.sizex, frames, channels); 
				for ch = 1:channels
					datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  '.tif'];
					this.data(:, :, ch) = filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
				end

			case 'XZ'
				this.data = zeros(this.sizex, this.stacks, channels); 
				for ch = 1:channels
					datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  '.tif'];
					this.data(:, :, ch) = filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
				end

			case 'XZT'
				this.data = zeros(this.sizex, stacks, channels); 
				this.time = zeros(1, frames); 
				for ch = 1:channels
					for t = 1:frames
						if dispt
							fprintf('%d ', t);
						end
						datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d') 'T' num2str(t, '%.3d') '.tif'];
						this.data(:, :, t, ch) = filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
						if loadtime&& ch==1
							ptyfname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d') 'T' num2str(t, '%.3d') '.pty'];
							this.time(t) = gettime(ptyfname);
						end
					end
				end

			case 'PT' %sizex times nframes points of data, with gaps between the lines of data
				this.data = zeros(this.sizex, frames, channels); 
				for ch = 1:channels
					datafname = [datafnamecommon 'C' num2str(chrange(ch), '%.3d')  '.tif'];
					this.data(:, :, ch) = filterdata( imread(datafname, 'tif')', medfiltsize, averagesize);
				end

		end

		if dispt
			fprintf('\n');
		end


		%%%%% load the ref image %%%%%
		for ch = 1:channels

			chstr = num2str(chrange(ch), '%.3d');

			if ~isempty(this.roix) || this.nbleachpt
				switch this.scanmode
					case {'XY', 'XT', 'XZ', 'PT'}
						reffname = [datafnamecommon 'C' chstr '-R' chstr '.tif'];
					case 'XYZ'
						reffname = [datafnamecommon 'C' chstr 'Z001-R' chstr '.tif'];
					case {'XYT', 'XZT'}
						reffname = [datafnamecommon 'C' chstr 'T001-R' chstr '.tif'];
					case 'XYZT'
						reffname = [datafnamecommon 'C' chstr 'Z001T001-R' chstr '.tif'];
				end

				if exist(reffname, 'file')
					temprefdata(:, :, ch) = filterdata( double(imread(reffname, 'tif'))', medfiltsize, averagesize);
				end
			end

			if exist('temprefdata', 'var')
				this.refdata = sum(temprefdata, 3);
			end
		end

	end %if ~paramonly

end %constructor


%filter data

function fdata = filterdata(data, medfiltsize, averagesize) %data is 2D


	if medfiltsize >1
		fdatatemp = medfilt2(double(data), medfiltsize); %mex function
	else
		fdatatemp = double(data);
	end

	if any(averagesize >1) %averagesize is either a scalar or a vector
		if length(averagesize)==1
			fdata = conv2(fdatatemp, ones(averagesize), 'same') / averagesize^2;
		else %length(averagesize)==2
			fdata = conv2(fdatatemp, ones(averagesize(1), averagesize(2)), 'same') / prod(averagesize);
		end
	else
		fdata = fdatatemp;
	end
end


function time = gettime(ptyfname)

	ptyfid = fopen(ptyfname, 'r');

	sectionstr = '';

	while 1
		tline = fgetl(ptyfid);
		if ~ischar(tline);  break;  end
		tempstrext = tline(2:2:end);

		if ~isempty(tempstrext) && tempstrext(1)=='['
			sectionstr = tempstrext(2:end-1);
		end

		if any(tempstrext == '=')
			tokens = regexp(tempstrext, '(.*)=(.*)', 'tokens');
			key = tokens{1, 1}{1,1};
			val = tokens{1, 1}{1,2};

			if ~isempty(sectionstr) && strcmp(sectionstr, 'Axis 4 Parameters')

				switch key
					case 'AbsPositionValue'
						time = str2num(val);
						break;
				end
			end
		end 

	end %while 1

	fclose(ptyfid);

end


