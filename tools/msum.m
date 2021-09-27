function r = msum(data)

	if iscell(data)
		datam = cell2mat(data);
		r = sum(datam(:));
	else	
		r = sum(data(:));
	end
end
