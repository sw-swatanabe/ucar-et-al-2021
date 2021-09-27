function roipat = roipat_circle(roipoints, roiradius, sizex, sizey)

	cx = roipoints(1, 1);
	cy = roipoints(1, 2);
	
	if nargin<4
		sizex = ceil(cx + roiradius);
		sizey = ceil(cy + roiradius);
	end
	
	roipat = zeros(sizex, sizey);


	[xmtemp,ymtemp] = meshgrid(1:sizex,1:sizey);
	xm = xmtemp'; ym = ymtemp';

	
	[rr, rc] = find((xm - cx).^2 + (ym - cy).^2 <= roiradius^2);

	rlen = length(rr);

	for r=1:rlen
		roipat(rr(r), rc(r)) = 1;
	end

end
