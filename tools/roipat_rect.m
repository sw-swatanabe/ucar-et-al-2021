function roipat = roipat_rect(roipoints, sizex, sizey)
	if iscell(roipoints)
		roipoints = cell2mat(roipoints);
	end
	
	xmin = min(roipoints(:,1));
	xmax = max(roipoints(:,1));
	ymin = min(roipoints(:,2));
	ymax = max(roipoints(:,2));
	
	if nargin<3
		sizex = ceil(xmax);
		sizey = ceil(ymax);
	end
	
	roipat = zeros(sizex, sizey);


	[xmtemp,ymtemp] = meshgrid(1:sizex,1:sizey);
	xm = xmtemp'; ym = ymtemp';

	
	[rr, rc] = find((xm>xmin) .* (xm<=xmax) .* (ym>ymin) .* (ym<=ymax));

	rlen = length(rr);

	for r=1:rlen
		roipat(rr(r), rc(r)) = 1;
	end

end
