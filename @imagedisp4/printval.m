function printval(this, roinum, varargin)
	nvarargin = length(varargin);

	roirange = this.roilist;
	
	if exist('roinum', 'var') && ~isempty(roinum)
		nrois = length(roinum);
		roirange = roinum;
	else
		roirange = this.roilist;
	end

	outputtype = 'sum';
	
	for i=1:nvarargin
		if isnumeric(varargin{1})
			roirange = varargin{1};
		end
		
		if ischar(varargin{i})
			switch varargin{i}
				case 'roi'
					roirange = varargin{i+1};

				case 'mean'
					outputtype = 'mean';
				case 'sum'
					outputtype = 'mean';
				case 'meanm'
					outputtype = 'mean';
				case 'summ'
					outputtype = 'mean';
			end
		end
	end
	
	
	for r = 1:nrois
		
		switch outputtype
			case 'mean'
				roival_temp = this.roimean(roirange(r));
			case 'sum'
				roival_temp = this.roisum(roirange(r));
			case 'meanm'
				roival_temp = this.roimeanm(roirange(r));
			case 'summ'
				roival_temp = this.roisumm(roirange(r));
		end
		
		fprintf('%d\t', roirange(r));
		fprintf('%d\t\t', this.roiarea(r));

		for t=1:this.sizet
			roival = roival_temp(this.ztarget(t), t);
			fprintf('%.1f\t', roival);
		end

		fprintf('\n');
	end

	
end
