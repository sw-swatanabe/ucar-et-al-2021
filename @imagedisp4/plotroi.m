function plotroi(this, roinum, varargin)
	nvarargin = length(varargin);

	fignum = [];
	plottype = 'mean';
	
	for i=1:nvarargin
		if ischar(varargin{i})
			switch varargin{i}
				case 'fig'
					fignum = varargin{i+1};
				case 'mean'
					plottype = 'mean';
				case 'sum'
					plottype = 'mean';
				case 'meanm'
					plottype = 'mean';
				case 'summ'
					plottype = 'mean';
			end
		end
	end
	
	if ~isempty(fignum)
		figure(fignum);
	else
		figure;
	end
	
	switch plottype
		case 'mean'
			roival_temp = this.roimean(roinum);
		case 'sum'
			roival_temp = this.roisum(roinum);
		case 'meanm'
			roival_temp = this.roimeanm(roinum);
		case 'summ'
			roival_temp = this.roisumm(roinum);
	end
	
	for t=1:this.sizet
		roival(t) = roival_temp(this.ztarget(t), t);
	end
	
	if isempty(this.time)
		plot(roival);
	else
		plot(this.time, roival);
	end
end