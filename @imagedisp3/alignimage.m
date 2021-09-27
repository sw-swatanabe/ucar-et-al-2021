%this function will be combined with align 

function alignimage(this, varargin)
	%automatic alignment of all images, translation only (rotation not implemented)
	nvarargin = size(varargin, 2);

	alignrange = 80;
	coarsestep = 4;
	
	aligndata = 'main';

	for i=1:nvarargin
		if isnumeric(varargin{i}) && i==1
			alignrange = varargin{i};
		end
		if ischar(varargin{i})
			switch varargin{i}
				case 'range'
					alignrange = varargin{i+1};
				case 'coarse'
					coarsestep = varargin{i+1};
				case 'main'
					aligndata = 'main';
				case 'sub'
					aligndata = 'sub';
			end
		end
	end

% 			coarsestep = this.aligncoarsestep;
% 			alignrange_coarse = floor(this.alignrange / coarsestep);
% 			alignrange_fine = coarsestep *3;

	%coarsestep = aligncoarsestep;
	alignrange_coarse = floor(alignrange / coarsestep);
	alignrange_fine = coarsestep *3;
	
	switch aligndata
		case 'main'
			coarsedata1 =  this.data{1}(coarsestep:coarsestep:end, coarsestep:coarsestep:end);
		case 'sub'
			coarsedata1 =  this.subdata{1}(coarsestep:coarsestep:end, coarsestep:coarsestep:end);
	end
	
	for n=2:this.ndata
		fprintf('%d ', n);
		switch aligndata
			case 'main'
				coarsedata2 = this.data{n}(coarsestep:coarsestep:end, coarsestep:coarsestep:end);
			case 'sub'
				coarsedata2 = this.subdata{n}(coarsestep:coarsestep:end, coarsestep:coarsestep:end);
		end
		convmatrix_temp = ccorr2m(coarsedata1 - mmean(coarsedata1), coarsedata2 - mmean(coarsedata2), alignrange_coarse);

		[maxval, shiftxtemp] = max(max(convmatrix_temp, [], 2));
		[maxval, shiftytemp] = max(max(convmatrix_temp, [], 1));

		shiftx_coarse = ( shiftxtemp - (alignrange_coarse +1) ) * coarsestep;
		shifty_coarse = ( shiftytemp - (alignrange_coarse +1) ) * coarsestep;

		convmatrix = ccorr2m(this.data{1}, this.data{n}, alignrange_fine, shiftx_coarse, shifty_coarse);

		[maxval, shiftxtemp] = max(max(convmatrix, [], 2));
		[maxval, shiftytemp] = max(max(convmatrix, [], 1));

		this.shiftx(n) = shiftx_coarse + shiftxtemp - (alignrange_fine +1);
		this.shifty(n) = shifty_coarse + shiftytemp - (alignrange_fine +1);
	end

	fprintf('\n');
	this.imageshifted_all = 1;
	this.update;
end
