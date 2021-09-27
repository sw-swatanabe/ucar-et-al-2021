%align images in the rect roi area
%alignment can be made only in an image of sizez==1

function align(this, varargin)
	nvarargin = size(varargin, 2);

	alignrange_local = 20;
	
	alignmode = 'roi';
	

	for i=1:nvarargin
		if isnumeric(varargin{i}) && i==1
			alignrange_local = varargin{i};
		end
		
		if isobject(varargin{i})
			alignmode = 'obj';
			alignobj = varargin{i};
		end
		
		if ischar(varargin{i})
			switch varargin{i}
				case 'image'
					alignmode = 'image';
				case 'range'
					alignrange_local = varargin{i+1};
			end
					
		end
	end

	if strcmp(alignmode, 'roi')
		
		if isempty(this.roilist)
			temproinum = 1;
		else
			temproinum = max(this.roilist) +1;
		end
		
		this.setroi(temproinum, 'rect');
		roirangex = round(min(this.roi{temproinum}.pt(:,1))) : round(max(this.roi{temproinum}.pt(:,1)));
		roirangey = round(min(this.roi{temproinum}.pt(:,2))) : round(max(this.roi{temproinum}.pt(:,2)));

		roidata1 = this.data{1}(roirangex, roirangey);

		for t=2:this.sizet
			datars = this.shift_data(this.data{t}, this.shiftx(t), this.shifty(t));
			roidata = datars(roirangex, roirangey);

			convmatrix = ccorr2m(roidata1 - mmean(roidata1), roidata - mmean(roidata), alignrange_local);
			%convmatrix = imagecrosscorr(roidata1 - mmean(roidata1), roidata - mmean(roidata), alignrange_local);
			[maxval, shiftxtemp] = max(max(convmatrix, [], 2));
			[maxval, shiftytemp] = max(max(convmatrix, [], 1));

			this.shiftx(t) = this.shiftx(t) + shiftxtemp - (alignrange_local +1);
			this.shifty(t) = this.shifty(t) + shiftytemp - (alignrange_local +1);
		end

		this.deleteroi(temproinum);
		this.imageshifted_all = 1;
		this.updatec;
	
	end
	
	if strcmp(alignmode, 'image')
		this.alignimage(varargin);
	end
	
	if strcmp(alignmode, 'obj')
		
% 		if ~isempty(this.sizet) && ~isempty(this.sizez) && ~isempty(alignobj.sizet) && ~isempty(alignobj.sizez)
% 			for t=1:this.sizet
% 				this.shiftx(t) = alignobj.shiftx(t);
% 				this.shifty(t) = alignobj.shifty(t);
% 			end
% 		else
			this.shiftx = alignobj.shiftx;
			this.shifty = alignobj.shifty;
			this.imageshifted_all = 1;
			this.updatec;
% 		end
		
	end
	
	
% 	function alignimage(this, varargin)
% 		%automatic alignment of all images, translation only (rotation not implemented)
% 		nvarargin = size(varargin, 2);
% 
% 		alignrange = 80;
% 		coarsestep = 4;
% 
% 		for i=1:nvarargin
% 			if isnumeric(varargin{i}) && i==1
% 				alignrange = varargin{i};
% 			end
% 			if ischar(varargin{i})
% 				switch varargin{i}
% 					case 'range'
% 						alignrange = varargin{i+1};
% 					case 'coarse'
% 						coarsestep = varargin{i+1};
% 				end
% 			end
% 		end
% 
% % 			coarsestep = this.aligncoarsestep;
% % 			alignrange_coarse = floor(this.alignrange / coarsestep);
% % 			alignrange_fine = coarsestep *3;
% 
% 		%coarsestep = aligncoarsestep;
% 		alignrange_coarse = floor(alignrange / coarsestep);
% 		alignrange_fine = coarsestep *3;
% 		coarsedata1 =  this.data{1}(coarsestep:coarsestep:end, coarsestep:coarsestep:end);
% 
% 		for n=2:this.ndata
% 			fprintf('%d ', n);
% 			coarsedata2 = this.data{n}(coarsestep:coarsestep:end, coarsestep:coarsestep:end);
% 
% 			convmatrix_temp = ccorr2m(coarsedata1 - mmean(coarsedata1), coarsedata2 - mmean(coarsedata2), alignrange_coarse);
% 
% 			[maxval, shiftxtemp] = max(max(convmatrix_temp, [], 2));
% 			[maxval, shiftytemp] = max(max(convmatrix_temp, [], 1));
% 
% 			shiftx_coarse = ( shiftxtemp - (alignrange_coarse +1) ) * coarsestep;
% 			shifty_coarse = ( shiftytemp - (alignrange_coarse +1) ) * coarsestep;
% 
% 			convmatrix = ccorr2m(this.data{1}, this.data{n}, alignrange_fine, shiftx_coarse, shifty_coarse);
% 
% 			[maxval, shiftxtemp] = max(max(convmatrix, [], 2));
% 			[maxval, shiftytemp] = max(max(convmatrix, [], 1));
% 
% 			this.shiftx(n) = shiftx_coarse + shiftxtemp - (alignrange_fine +1);
% 			this.shifty(n) = shifty_coarse + shiftytemp - (alignrange_fine +1);
% 		end
% 
% 		fprintf('\n');
% 		this.imageshifted_all = 1;
% 		this.update;
% 	end

end

