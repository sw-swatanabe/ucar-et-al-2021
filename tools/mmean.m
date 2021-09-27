function r = mmean(data)

	if iscell(data)
		datam = cell2mat(data);
		r = mean(datam(:));
	else
		r = mean(data(:));
	end
end
