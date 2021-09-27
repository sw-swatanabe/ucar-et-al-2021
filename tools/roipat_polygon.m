function roipat = roipat_polygon(roipoints, sizex, sizey)

npt = size(roipoints, 1);

x = [roipoints(:,1); roipoints(1,1)];
y = [roipoints(:,2); roipoints(1,2)];

%	roipat = zeros(sizex,sizey);
	if nargin<3
		sizex = ceil(max(roipoints(:,1)));
		sizey = ceil(max(roipoints(:,2)));
	end
	
	roipat = zeros(sizex, sizey);

	if npt >= 3

	for n=1:npt
		if abs(x(n+1)-x(n)) > 0
			slope(n) = (y(n+1)-y(n)) / (x(n+1)-x(n));
			intercpt(n) = y(n) - slope(n) * x(n);
		else
			slope(n) = NaN;
			intercpt(n) = NaN;
		end
	end

	rotation = sum(diff(x(1:npt+1)) .* (y(1:npt)+y(2:npt+1))/2 ); % >0 anticlockwise, <0 clockwise


	[xmtemp,ymtemp] = meshgrid(1:sizex,1:sizey);
	xm = xmtemp'; ym = ymtemp';



	for n=1:npt

		if abs(x(n+1)-x(n)) > 0

			if rotation>0
				if x(n+1)>x(n)
					[rr, rc] = find((ym < (xm * slope(n) + intercpt(n))) .* (xm>x(n)) .* (xm<=x(n+1)) );
				else
					[rr, rc] = find((ym < (xm * slope(n) + intercpt(n))) .* (xm<=x(n)) .* (xm>x(n+1)) );
				end		
			else
				if x(n+1)>x(n)
					[rr, rc] = find((ym > (xm * slope(n) + intercpt(n))) .* (xm>x(n)) .* (xm<=x(n+1)) );
				else
					[rr, rc] = find((ym > (xm * slope(n) + intercpt(n))) .* (xm<=x(n)) .* (xm>x(n+1)) );
				end		
			end
			
			
			rlen = length(rr);
			roitemp = zeros(sizex,sizey);
			if x(n+1)>x(n)
				for r=1:rlen
					roitemp(rr(r), rc(r)) = 1;
				end
			else
				for r=1:rlen
					roitemp(rr(r), rc(r)) = -1;
				end
			end

			roipat = roipat + roitemp;
		end
	end


end
