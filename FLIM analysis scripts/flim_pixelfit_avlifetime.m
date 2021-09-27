%{
Set a rectangle ROI in the dt image (dt.setroir(1), etc) and click on the ROI to activate 
(active ROI has a yellow border).  Then run this program.

Figure 7 - pixel binding fraction 
Figure 8 - pixel average life time (calculated from the binding fraction)
%}

roinum = dt.selectedroi;


t = 1;	
z = 1;
ndata = 1;

roipat_all = dt.roip(roinum);
roipat = roipat_all(:,:,1);
roipatarr = find(roipat(:));
roi_npt = length(roipatarr);
roi_pt_xmin = ceil(min(dt.roi{roinum}.pt(:, 1)));
roi_pt_xmax = floor(max(dt.roi{roinum}.pt(:, 1)));
roi_pt_ymin = ceil(min(dt.roi{roinum}.pt(:, 2)));
roi_pt_ymax = floor(max(dt.roi{roinum}.pt(:, 2)));
roi_pt_xsize = roi_pt_xmax - roi_pt_xmin +1;
roi_pt_ysize = roi_pt_ymax - roi_pt_ymin +1;


hfid = fopen(histfname, 'r');
version = fread(hfid, 1, 'int16');

binsize = fread(hfid, 1, 'int16');
tsumsize = fread(hfid, 1, 'int16');
zsumsize = fread(hfid, 1, 'int16');
dataframe_size = fread(hfid, 1, 'int16');

sizexb = fread(hfid, 1, 'int16');
sizeyb = fread(hfid, 1, 'int16');

histlength = fread(hfid, 1, 'int16');
dtstep = fread(hfid, 1, 'double');

formatstr = fread(hfid, 8, 'char')';
pixcount_format = char(formatstr(formatstr ~= ' '));
formatstr = fread(hfid, 8, 'char')';
avlifetime_format = char(formatstr(formatstr ~= ' '));
formatstr = fread(hfid, 8, 'char')';
hist_format = char(formatstr(formatstr ~= ' '));

dataoffset = fread(hfid, 1, 'int32');	

pixcount_bytesperdata = 4;
avlifetime_bytesperdata = 8;
hist_bytesperdata = 2;

dtimeabs = (0:histlength-1) * dtstep; %ns

roisize = dt.roiarea(roinum);

rhist = zeros(histlength, roi_npt);


pixhist_offset = dataoffset + ((pixcount_bytesperdata + avlifetime_bytesperdata) * sizexb*sizeyb);

pixcount_data = dt.maskdata{1};
pixcount_data_r = pixcount_data(:);
pixcount_data_roi_r = pixcount_data_r(roipatarr);
pixcount_data_roi = reshape(pixcount_data_roi_r, [roi_pt_xsize, roi_pt_ysize]);

for r = 1:roi_npt
	rpt = roipatarr(r);
	
	fseek(hfid, pixhist_offset + (rpt-1) * hist_bytesperdata * histlength, 'bof');

	rhist(:, r) = fread(hfid, histlength, hist_format);
end

n_photons = sum(rhist, 1);

fclose(hfid);

xdata = (0:histlength-1) * dtstep;

clear data_est params_est sse exitflag

fprintf('total %d pixels  ', roi_npt);
for r = 1:roi_npt
	if ~mod(r, 50)
		fprintf('%d ', r);
	end
	
	%fitting with free parameters
	%[data_est{r}, params_est(:,r), sse(r), exitflag(r)] = flim_doubleexpfit(xdata, rhist(:,r), 'tauD', tauD_init, 'tauAD', tauAD_init, 'tauG', tauG_init, 't0', t0_init);

	%fitting with fixed parameters
	%[data_est{r}, params_est(:,r), sse(r), exitflag(r)] = flim_doubleexpfit(xdata, rhist(:,r), 'tauD_fix', tauD_init, 'tauAD_fix', tauAD_init, 'tauG', tauG_init, 't0', t0_init);
    [data_est{r}, params_est(:,r), sse(r), exitflag(r)] = flim_doubleexpfit_offset(xdata, rhist(:,r), 'tauD_fix', tauD_init, 'tauAD_fix', tauAD_init, 'tauG', tauG_init, 't0', t0_init);

end
fprintf('\n');

roi_boundfraction = reshape(params_est(2,:) ./ (params_est(1,:) + params_est(2,:)), [roi_pt_xsize, roi_pt_ysize]);
roi_photoncount = reshape(n_photons, [roi_pt_xsize, roi_pt_ysize]);

% average lifetime from the binding fraction
% 	aD_est = params_est_all(1);
% 	aAD_est = params_est_all(2);
% 	tauD_est = params_est_all(3);
% 	tauAD_est = params_est_all(4);
% 	tauG_est = params_est_all(5);
% 	t0_est = params_est_all(6);
tauD_est =reshape(params_est(3, :), [roi_pt_xsize, roi_pt_ysize]);
tauAD_est =reshape(params_est(4, :), [roi_pt_xsize, roi_pt_ysize]);
roi_avlifetime = ( roi_boundfraction .* (tauAD_est.^2 - tauD_est.^2) + tauD_est.^2) ./  ( roi_boundfraction .* (tauAD_est - tauD_est) +  tauD_est);


% dbc = imagedisp4('fig', 6, 'param', 'gray');
% dbc.append(roi_photoncount);
% dbc.updatec;

dbp = imagedisp4('fig', 7, 'param', 'rainbow');
dbp.append(roi_boundfraction);
dbp.maskdata{1} = pixcount_data_roi;
dbp.rgbmax = 1;
dbp.maskmin = dc.rgbmin;
dbp.maskmax = dc.rgbmax;
dbp.updatec;

dlp = imagedisp4('fig', 8, 'param', 'rainbow');
dlp.append(roi_avlifetime);
dlp.maskdata{1} = pixcount_data_roi;
dlp.rgbmax = max(roi_avlifetime(:));
dlp.rgbmin = 0;
dlp.maskmin = dc.rgbmin;
dlp.maskmax = dc.rgbmax;
dlp.updatec;


