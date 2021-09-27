function roinum = selectedroi(imgobj)

	roinum = [];
	
	for r = imgobj.roilist
		if imgobj.roi{r}.selected
			roinum = [roinum, r];
		end
	end
		
	if isempty(roinum)
		disp('no selected roi')
	end

end
