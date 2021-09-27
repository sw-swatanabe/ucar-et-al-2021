function plotf(this)

	fignum = 1001;
	roinum = 1001;
	plottype = 'mean';
	
	this.setroi(roinum);
	
	figure(fignum);
	
	switch plottype
		case 'mean'
			roival = this.roimean(roinum);
		case 'sum'
			roival = this.roisum(roinum);
		case 'meanm'
			roival = this.roimeanm(roinum);
		case 'summ'
			roival = this.roisumm(roinum);
	end
	
	if isempty(this.time)
		plot(roival);
	else
		plot(this.time, roival);
	end
end