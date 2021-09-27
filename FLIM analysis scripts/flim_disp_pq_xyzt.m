%{
This program loads the histogram file and displays images for analyses


Fig. 1  
main - photon count
sub  - FV

Fig. 2
main - average lifetime
sub  - FV

Fig. 9
main - photon count zsum
sub  - FV zsum

Fig. 11
histogram

------

To change image time, use Home/PageUp/PageDown/End keys
To change image z, useÅ@a/s/d/f keys

%}


%%
histfile_version = 1;

pixcount_format		= 'int32';
avlifetime_format	= 'double';
hist_format			= 'int16';

pixcount_bytesperdata = 4;
avlifetime_bytesperdata = 8;
hist_bytesperdata = 2;

dataoffset = 1024;


%%
%photon count image

dc = imagedisp4('fig', 1, 'param', 'k', 'min',dc_rgbmin, 'max',dc_rgbmax, 'submim', dc_submin, 'submax', dc_submax); 
dc.subparam = 'm';
if exist('fvimg', 'var')
	dc.setparam(fvimg);
end
dc.sizez = zsize_b;


if use_fv
	dc.titlestr = ['PQ ' pq_datafolder '-' num2str(pq_filenumber, '%d ') '  FV ' fv_datafolder '-' fv_filename '  '];
else
	dc.titlestr = ['PQ ' pq_datafolder '-' num2str(pq_filenumber, '%d ')];
end
dc.roishift_allimages = 0;

fn = 1;
dc.fbuttonf{fn} = 'if dc.imageopacity; dc.imageopacity=0; else; dc.imageopacity=1; end; dc.updatec'; 
dc.fbuttonstr{fn} = 'disp main';	fn = fn +1;

dc.fbuttonf{fn} = 'if dc.subopacity; dc.subopacity=0; else; dc.subopacity=1; end; dc.updatec'; 
dc.fbuttonstr{fn} = 'disp sub';	fn = fn +1;

fn = fn +1;
dc.fbuttonf{fn} = 'dc.setroi; dt.setroi(dc);'; 
dc.fbuttonstr{fn} = 'set roi';	fn = fn +1;

fn = fn +1;
dc.fbuttonf{fn} = 'dc.setroir(101);'; 
dc.fbuttonstr{fn} = 'panel roi';	fn = fn +1;
dc.fbuttonf{fn} = 'dc.imagepanel(''fig'', 101, ''roi'', selectedroi(dc));'; 
dc.fbuttonstr{fn} = 'panel';	fn = fn +1;
dc.fbuttonf{fn} = 'dc.imagepanel(''fig'', 101, ''roi'', selectedroi(dc), ''tr''); '; 
dc.fbuttonstr{fn} = 'panel(tr)';	fn = fn +1;

%%
%zsum image

%{
ds = imagedisp4('fig', 9, 'param', 'g', 'subparam', 'gray', 'min', ds_rgbmin, 'max', ds_rgbmax, 'submin', ds_submin, 'submax', ds_submax);
if exist('fvimg', 'var')
	ds.setparam(fvimg);
end
ds.sizez = 1;
ds.titlestr = dc.titlestr;
ds.imageopacity = 0;

fn = 1;
ds.fbuttonf{fn} = 'if ds.imageopacity; ds.imageopacity=0; else; ds.imageopacity=1; end; ds.updatec'; 
ds.fbuttonstr{fn} = 'disp main';	fn = fn +1;
ds.fbuttonf{fn} = 'if ds.subopacity; ds.subopacity=0; else; ds.subopacity=1; end; ds.updatec'; 
ds.fbuttonstr{fn} = 'disp sub';	fn = fn +1;

fn = fn +1;
ds.fbuttonf{fn} = 'ds.align(''main''); dc.align(ds); dt.align(ds)'; 
ds.fbuttonstr{fn} = 'align main';	fn = fn +1;
ds.fbuttonf{fn} = 'ds.align(''sub''); dc.align(ds); dt.align(ds)'; 
ds.fbuttonstr{fn} = 'align sub';	fn = fn +1;

fn = fn +1;
ds.fbuttonf{fn} = 'ds.setroi(1);'; 
ds.fbuttonstr{fn} = 'bg roi';	fn = fn +1;
ds.fbuttonf{fn} = 'ds.setroi;'; 
ds.fbuttonstr{fn} = 'set roi';	fn = fn +1;

fn = fn +1;
ds.fbuttonf{fn} = 'rn=ds.selectedroi; fprintf(''%s\n'', ds.titlestr); for r=1:length(rn); sp_vol=ds.roisum(rn(r),''sub'')-ds.roimean(1,''sub'')*ds.roiarea(rn(r)); fprintf(''%d\t'', rn(r)); fprintf(''%.4f\t'', sp_vol*1e-6); fprintf(''\n''); end;'; 
ds.fbuttonstr{fn} = 'volume';	fn = fn +1;

fn = fn +1;
ds.fbuttonf{fn} = 'ds.setroir(109);'; 
ds.fbuttonstr{fn} = 'panel roi';	fn = fn +1;
ds.fbuttonf{fn} = 'ds.imagepanel(''fig'', 109, ''roi'', selectedroi(ds));'; 
ds.fbuttonstr{fn} = 'panel';	fn = fn +1;
ds.fbuttonf{fn} = 'ds.imagepanel(''fig'', 109, ''roi'', selectedroi(ds), ''tr''); '; 
ds.fbuttonstr{fn} = 'panel(tr)';	fn = fn +1;

%}

%%
%average lifetime image

dt = imagedisp4('fig', 2, 'param', 'irainbow', 'min', dt_rgbmin, 'max', dt_rgbmax, 'maskmin', dt_maskmin, 'maskmax', dt_maskmax, 'submin', dt_submin, 'submax', dt_submax); %dt_rgbmaskmin instead of 50, dt_rgbmaskmax instead of 125
%dt = imagedisp4('fig', 2, 'param', 'k', 'min', dt_rgbmin, 'max', dt_rgbmax, 'maskmin', dt_maskmin, 'maskmax', dt_maskmax, 'submin', dt_submin, 'submax', dt_submax); %dt_rgbmaskmin instead of 50, dt_rgbmaskmax instead of 125
dt.subparam = 'm';
if exist('fvimg', 'var')
	dt.setparam(fvimg);
end
dt.sizez = zsize_b;
dt.titlestr = dc.titlestr;
dt.roishift_allimages = 0;


fn=1;
dt.fbuttonf{fn} = 'if dt.imageopacity; dt.imageopacity=0; else; dt.imageopacity=1; end; dt.updatec'; 
dt.fbuttonstr{fn} = 'disp main';	fn = fn +1;
dt.fbuttonf{fn} = 'if dt.subopacity; dt.subopacity=0; else; dt.subopacity=1; end; dt.updatec'; 
dt.fbuttonstr{fn} = 'disp sub';	fn = fn +1;

fn = fn +1;

dt.fbuttonf{fn} = 'dt.setroi; dc.setroi(dt);'; 
dt.fbuttonstr{fn} = 'set roi';	fn = fn +1;

fn = fn +1;

dt.fbuttonf{fn} = 'roinum=dt.selectedroi; flim_plothistogram_z(histfname, dt, mp); fprintf(''roi=%d\tz='', roinum); fprintf(''%d '', dt.ztarget); fprintf(''\n''); fittingtype=''free''; flim_fithistogram;'; 
dt.fbuttonstr{fn} = 'free';	fn = fn +1;
dt.fbuttonf{fn} = 'roinum=dt.selectedroi; flim_plothistogram_z(histfname, dt, mp); fprintf(''roi=%d\tz='', roinum); fprintf(''%d '', dt.ztarget); fprintf(''\n''); fittingtype=''fix_tauAD''; flim_fithistogram; '; 
dt.fbuttonstr{fn} = 'fix tau1';	fn = fn +1;
dt.fbuttonf{fn} = 'roinum=dt.selectedroi; flim_plothistogram_z(histfname, dt, mp); fprintf(''roi=%d\tz='', roinum); fprintf(''%d '', dt.ztarget); fprintf(''\n''); fittingtype=''fix_tauD''; flim_fithistogram; '; 
dt.fbuttonstr{fn} = 'fix tau2';	fn = fn +1;
dt.fbuttonf{fn} = 'roinum=dt.selectedroi; flim_plothistogram_z(histfname, dt, mp); fprintf(''roi=%d\tz='', roinum); fprintf(''%d '', dt.ztarget); fprintf(''\n''); fittingtype=''fix_tau''; flim_fithistogram; '; 
dt.fbuttonstr{fn} = 'fix all';	fn = fn +1;
dt.fbuttonf{fn} = 'roinum=dt.selectedroi; flim_plothistogram_z(histfname, dt, mp); fprintf(''roi=%d\tz='', roinum); fprintf(''%d '', dt.ztarget); fprintf(''\n''); fittingtype=''single''; flim_fithistogram; '; 
dt.fbuttonstr{fn} = 'single exp';	fn = fn +1;

fn = fn +1;

dt.fbuttonf{fn} = 'dt.setroir(102);'; 
dt.fbuttonstr{fn} = 'panel roi';	fn = fn +1;
dt.fbuttonf{fn} = 'dt.imagepanel(''fig'', 102, ''roi'', dt.selectedroi);'; 
dt.fbuttonstr{fn} = 'panel';	fn = fn +1;
dt.fbuttonf{fn} = 'dt.imagepanel(''fig'', 102, ''roi'', dt.selectedroi, ''tr''); '; 
dt.fbuttonstr{fn} = 'panel(tr)';	fn = fn +1;


pn = 1;

dt.fparamval{1} = tauAD_init;
dt.fparamstr{1} = 'tau1';	pn = pn +1;

dt.fparamval{2} = tauD_init;
dt.fparamstr{2} = 'tau2';	pn = pn +1;

dt.fparamval{3} = tauG_init;
dt.fparamstr{3} = 'tauG';	pn = pn +1;

dt.fparamval{4} = t0_init;
dt.fparamstr{4} = 't0';	pn = pn +1;



%%
%load data

histfname = [pq_histfolder '\' pq_filename_base num2str(pq_filenumber) '-z' num2str(zsumsize) '-t' num2str(tsumsize) '-b' num2str(pix_binningsize) '.hist'];

histfname_s = dir(histfname);

if use_fv
	fvimg = fvdata(fv_datafolder, fv_filename, 'ch', fv_channel);
end


hfid = fopen(histfname, 'r');
histfile_version = fread(hfid, 1, 'int16');

pix_binningsize = fread(hfid, 1, 'int16');
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


%data size (in bytes)
%pixcountb - sizexb * sizeyb * pixcount_bytesperdata
%avlifetime - sizexb * sizeyb * avlifetime_bytesperdata
%histogram -  sizexb * sizeyb * histlength * hist_bytesperdata
%total size (pixcountb + avlifetime + histogram) * dataframe_size


%%
%display images

if use_fv
	fvimg = fvdata(fv_datafolder, fv_filename, 'med', fv_medfiltsize, 'av', fv_pix_avsize, 'ch', fv_channel);
	
	switch fvimg.scanmode
		case {'XYT', 'XY'}
			for t=1:tsize_b
				fvdata_sum_temp =  sum(fvimg.data(:,:, tsumrange{t}), 3);
				fvdata_sum{t} = double(binning(int32(fvdata_sum_temp), pix_binningsize));
				fvdata_sum_all = sum(fvimg.data(:, :, trange), 3);
			end

		case {'XYZT', 'XYZ'}
			for t=1:tsize_b
				for z=1:zsize_b
					fvdata_sum_temp =  sum( sum(fvimg.data(:,:, zsumrange{z}, tsumrange{t}), 4), 3);
					fvdata_sum{(t-1)*zsize_b + z} = double(binning(int32(fvdata_sum_temp), pix_binningsize));
				end
			end
			fvdata_sum_all = sum( sum(fvimg.data(:, :, zrange, trange), 4), 3);
	end
end


for t=1:dataframe_size

	pixcount_offset = dataoffset + (t-1) * ((pixcount_bytesperdata + avlifetime_bytesperdata) * sizexb*sizeyb + hist_bytesperdata * histlength* sizexb*sizeyb);
	fseek(hfid, pixcount_offset, 'bof');

	pixcount = fread(hfid, [sizexb, sizeyb], pixcount_format);
	pixcount_ma = conv2(double(pixcount), ones(flim_pix_avsize, flim_pix_avsize), 'same') / flim_pix_avsize^2;

	avlifetime = fread(hfid, [sizexb, sizeyb], avlifetime_format);
     avlifetime(isnan(avlifetime)) = 0;
	avlifetime_ma = conv2(avlifetime .* pixcount, ones(flim_pix_avsize, flim_pix_avsize), 'same') ./ (pixcount_ma * flim_pix_avsize^2);
    %avlifetime_ma_1=avlifetime_ma-IRF_6mW_avlifetime_ma; %(IRF effect should be included somehow_Hasan)

    
	if use_fv
		dc.append(double(pixcount_ma), 'sub', fvdata_sum{t}, 'noupdate');
		dt.append(double(avlifetime_ma), 'sub', fvdata_sum{t}, 'mask', pixcount, 'noupdate');
	else
		dc.append(double(pixcount_ma), 'noupdate');
	   dt.append(double(avlifetime_ma), 'mask', pixcount, 'noupdate');

    end


   %{
    if use_fv
		ds.append(pixcount_ma, 'sub', fvdata_sum{t}, 'noupdate');
	else
		ds.append(pixcount_ma, 'noupdate');
	end
   %}

end


%{
%% a1 fraction image

da = imagedisp4('fig', 5, 'param', 'rainbow', 'min', 0.25, 'max', 0.75, 'maskmin', dt_maskmin, 'maskmax', dt_maskmax);
da.sizez = dt.sizez;
da.titlestr = dt.titlestr;

for t=1:dataframe_size

	p_AD = tauD_init * (tauD_init - dt.data{t}) ./ ( (tauD_init - tauAD_init) .* (tauD_init + tauAD_init - dt.data{t}) );

	da.append(p_AD, 'mask', dt.maskdata{t}, 'noupdate');
end
%}
%%
fclose(hfid);

dc.update;
dt.update;
%da.update;
%ds.update;


%%
%display histogram

mparea{1} = [0.1 0.4 0.8 0.5];
mparea{2} = [0.1 0.1 0.8 0.2];
plottype = {'logy', 'linear'};

mp = multiplot('fig', 11, 'position', mparea, 'plottype', plottype);




