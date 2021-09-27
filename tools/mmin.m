function r = mmin(data)

	if iscell(data)
		datam = cell2mat(data);
		r = min(datam(:));
	else
		r = min(data(:));
	end
end
