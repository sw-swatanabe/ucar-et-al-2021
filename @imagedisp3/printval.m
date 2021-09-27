function printval(this, roinum)
% 			if isnumeric(roinum)
% 				roirange = roinum;
% 			end
% 			if strcmp(roinum, 'all')
% 				roirange = find(this.nroipt);
% 			end

	if nargin <2
% 		roirange = find(this.nroipt);
		roirange = this.roilist;
	else
		roirange = roinum;
	end

	for r = roirange
		fprintf('%d\t', r);
		fprintf('%d\t\t', this.roiarea(r));
		fprintf('%.1f\t', this.roival(r));
		fprintf('\n');
	end

	
end
