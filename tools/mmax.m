function r = mmax(data)

	if iscell(data)
		datam = cell2mat(data);
		r = max(datam(:));
	else
		r = max(data(:));
	end
end
