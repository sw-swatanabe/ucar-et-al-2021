%{
Pixel-by-pixel fitting of FLIM data

1. Run pq_xyzt_demo.m
2. Set a rectangular ROI in the average lifetime image (Fig.2) (use the
'panel roi' button).  Keep the ROI selected (yellow edges).
3. Run this program.

For free parameter fitting, uncomment line 101 and comment line 104.
For fixed parameter fitting, comment line 101 and uncomment line 104.

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

xdata = (0:histlength-1)' * dtstep;

clear data_est params_est sse exitflag

fprintf('total %d pixels  ', roi_npt);
fprintf('total %d pixels  ');


for r = 1:roi_npt
	if ~mod(r, 50)
		fprintf('%d ', r);
	end
	
	%fitting with free parameters
	%[data_est{r}, params_est(:,r), sse(r), exitflag(r)] = flim_doubleexpfit_offset(xdata, rhist(:,r), 'tauD', tauD_init, 'tauAD', tauAD_init, 'tauG', tauG_init, 't0', t0_init);

	%fitting with fixed parameters
    [data_est{r}, params_est(:,r), sse(r), exitflag(r)] = flim_doubleexpfit_offset(xdata, rhist(:,r), 'tauD_fix', tauD_init, 'tauAD_fix', tauAD_init, 'tauG', tauG_init, 't0', t0_init);
   
end
fprintf('\n');


roi_bindingfraction = reshape(params_est(2,:) ./ (params_est(1,:) + params_est(2,:)), [roi_pt_xsize, roi_pt_ysize]);
roi_photoncount = reshape(n_photons, [roi_pt_xsize, roi_pt_ysize]);

% dbc = imagedisp4('fig', 6, 'param', 'gray');
% dbc.append(roi_photoncount);
% dbc.updatec;
%%
dbp = imagedisp4('fig', 7, 'param', 'rainbow');
dbp.append(roi_bindingfraction);
%dbp.append(pixcount_data_roi);
%dbp.append(pixcount_data_roi_r);
dbp.maskdata{1} = pixcount_data_roi;
dbp.rgbmin = 0.0;
dbp.rgbmax = 0.5;
dbp.maskmin = 10; %dc.rgbmin;
dbp.maskmax = 50; %dc.rgbmax;
dbp.titlestr = ['A1% ' pq_datafolder '-' num2str(pq_filenumber, '%d ')];

dbp.updatec;

cd(pq_datafolder);
   graphname=['A1_LSM_' num2str(pq_filenumber)]; 
   saveas(gcf,graphname);
   saveas(gcf,graphname, 'jpeg');
%%
tauD_est =reshape(params_est(3, :), [roi_pt_xsize, roi_pt_ysize]);
tauAD_est =reshape(params_est(4, :), [roi_pt_xsize, roi_pt_ysize]);
roi_avlifetime = ( roi_bindingfraction .* (tauAD_est.^2 - tauD_est.^2) + tauD_est.^2) ./  ( roi_bindingfraction .* (tauAD_est - tauD_est) +  tauD_est);

%%
%{
%dlp = imagedisp4('fig', 8, 'param', 'k');
dlp = imagedisp4('fig', 8, 'param', 'irainbow');
dlp.append(roi_avlifetime);
dlp.maskdata{1} = pixcount_data_roi;
dlp.rgbmin = 2;
dlp.rgbmax = 4; % max(roi_avlifetime(:));
dlp.maskmin = 15; %dc.rgbmin;
dlp.maskmax = 50; %dc.rgbmax;
dlp.titlestr = ['Lifetime ' pq_datafolder '-' num2str(pq_filenumber, '%d ')];

dlp.updatec;

cd(pq_datafolder);
   graphname=['ltime_LSM_' num2str(pq_filenumber)]; 
   saveas(gcf,graphname);
   saveas(gcf,graphname, 'jpeg');
%}
%%