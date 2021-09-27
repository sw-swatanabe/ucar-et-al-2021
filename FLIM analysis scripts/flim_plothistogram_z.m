%plot histogram of the roi

%plot histogram for the roi in stack z = dt.current_z(t), t = 1:dt.sizet

%only one roi should be selected

function rhist =  flim_plothistogram_z(histfname, dt, mp, varargin)

	nvarargin = length(varargin);
	
	subtractbg = 0;
	

	datanum = [];

	for i=1:nvarargin
		if ischar(varargin{i})
			switch varargin{i}

			end
		end
	end
	
	mp.deletedata;


	roinum = dt.selectedroi;

	if isempty(roinum)
		disp('no selected roi')
		return;
	end
	

	hfid = fopen(histfname, 'r');
	version = fread(hfid, 1, 'int16');

	binsize = fread(hfid, 1, 'int16');
	tsumsize = fread(hfid, 1, 'int16');
	zsumsize = fread(hfid, 1, 'int16');
	dataframe_size = fread(hfid, 1, 'int16');

	sizexb = fread(hfid, 1, 'int16');
	sizeyb = fread(hfid, 1, 'int16');

	histlength = fread(hfid, 1, 'int16');
	dtstep = fread(hfid, 1, 'double');

	formatstr = fread(hfid, 8, 'char')';
	pixcount_format = char(formatstr(formatstr ~= ' '));
	formatstr = fread(hfid, 8, 'char')';
	avlifetime_format = char(formatstr(formatstr ~= ' '));
	formatstr = fread(hfid, 8, 'char')';
	hist_format = char(formatstr(formatstr ~= ' '));

	dataoffset = fread(hfid, 1, 'int32');	

	pixcount_bytesperdata = 4;
	avlifetime_bytesperdata = 8;
	hist_bytesperdata = 2;


	dtimeabs = (0:histlength-1) * dtstep; %ns

	roisize = dt.roiarea(roinum);


	rhist = zeros(histlength, dt.sizet);


	roipat_all = dt.roip(roinum);
	
	for t=1:dt.sizet	
		
		roipat = roipat_all(:,:, t);
		roipatarr = find(roipat(:));

		z = dt.ztarget(t);

		fn = (t-1) * dt.sizez + z;
		
		pixhist_offset = dataoffset + fn * ((pixcount_bytesperdata + avlifetime_bytesperdata) * sizexb*sizeyb) ...
						+ (fn-1) * (hist_bytesperdata * histlength* sizexb*sizeyb);

		for r = 1:length(roipatarr)
			rpt = roipatarr(r);
			fseek(hfid, pixhist_offset + (rpt-1) * hist_bytesperdata * histlength, 'bof');

			rhist(:, t) = rhist(:, t) + fread(hfid, histlength, hist_format);
		end

		mp.append(1, 1, t, dtimeabs', rhist(:,t), 'noupdate');
	end
	
	
	fclose(hfid);

	mp.update;

	mp.sp{1}.axrange = [0, max(dtimeabs), 1, mmax(rhist)*1.1];
	set(mp.sp{2}.axh, 'XLim', [0, max(dtimeabs)]);
	mp.titlestr = ([dt.titlestr, ' - roi ', num2str(roinum)]);
	mp.update;


end
