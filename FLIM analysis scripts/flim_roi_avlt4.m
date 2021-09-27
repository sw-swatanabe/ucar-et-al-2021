function avlt = flim_roi_avlt4(dc, dt, roinum)

% 	figure(20); 
	dcr_all = dc.roipixels(roinum); 
	dtr_all = dt.roipixels(roinum); 

	
	for t=1:size(dcr_all, 2)
		dcr_t = dcr_all{t};
		dtr_t = dtr_all{t};
		
		dcr = dcr_t(isfinite(dtr_t));
		dtr = dtr_t(isfinite(dtr_t));
	
		avlt(t) = sum(dcr .* dtr) ./ sum(dcr); 
	
	end
	
% 	plot(avlt, '-o');
% 	fprintf('%.4f\t', avlt);

end
