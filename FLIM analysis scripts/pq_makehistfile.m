%Creates histogram from the PicoQuant data

%%

%load data
fid = fopen(datafname, 'r');

tttr = Read_PTU_tag(fid); %function provided by PicoQuant

tttr.data = fread(fid, tttr.TTResult_NumberOfRecords, 'uint32');
tttr.resolution = tttr.MeasDesc_Resolution;
fclose(fid);

%image size from FV data
if use_fv
	tttr.sizex = fvimg.sizex;
	tttr.sizey = fvimg.sizey;
end

sizex = tttr.sizex;						
sizey = tttr.sizey;
sizeall = sizex * sizey;
sizexb = floor(tttr.sizex / pix_binningsize);	
sizeyb = floor(tttr.sizey / pix_binningsize);
sizex1 = sizexb * pix_binningsize;				
sizey1 = sizeyb * pix_binningsize;


pulserate = 80000000;

%number of histogram bins
histlength = round(1 / pulserate / tttr.resolution / hist_binningsize);

%bin size of the histogram
dtstep = tttr.resolution * 1e9 * hist_binningsize; %in ns


%max number of photons per pixel
maxphotons_per_pix = 200; 
maxphotons_per_line = maxphotons_per_pix * 100;


%% 
%write parameters to file

histfile_version = 2;

pixcount_format		= 'int32';
avlifetime_format	= 'double';
hist_format			= 'int16';

dataoffset = 1024;


%header
hfid = fopen(histfname, 'w');

fwrite(hfid, histfile_version, 'int16');

fwrite(hfid, pix_binningsize, 'int16'); 

fwrite(hfid, tsumsize, 'int16');
fwrite(hfid, zsumsize, 'int16');

fwrite(hfid, dataframe_size, 'int16');

fwrite(hfid, sizexb, 'int16');
fwrite(hfid, sizeyb, 'int16');			

fwrite(hfid, histlength, 'int16');
fwrite(hfid, dtstep, 'double');			

formatstr = '        '; formatstr(1:length(pixcount_format)) = pixcount_format;
fwrite(hfid, formatstr, 'char');
formatstr = '        '; formatstr(1:length(avlifetime_format)) = avlifetime_format;
fwrite(hfid, formatstr, 'char');
formatstr = '        '; formatstr(1:length(hist_format)) = hist_format;
fwrite(hfid, formatstr, 'char');		

fwrite(hfid, dataoffset, 'int32');		

cnt = ftell(hfid);

for ofst=1:dataoffset-cnt
	fwrite(hfid, 0, 'int8');
end


%% 
%sort photons to pixels and export to file

if dataframe_size>1
	fprintf('total %d images\n', dataframe_size);
end

for tout=1:dataframe_size 
	
	if dataframe_size>1
		fprintf('%d ', tout);
	end

	pixcountb = int32( zeros(sizexb, sizeyb) );
	pixdtimeb = int16( zeros(sizexb, sizeyb, maxphotons_per_pix *framesumsize *pix_binningsize^2) ); %micro time

	for f=1:framesumsize

		if ~framegap
			frame = framesumrange{tout}(f); 
		else
			frame = framesumrange{tout}(f) *2 -1; 
		end
		
		%pixcount - [sizex, sizey]
		%pixdtime - [sizex, sizey, maxphotons_per_pix]
		[pixcount, pixdtime_raw] = pq_image(uint32(tttr.data), pq_channel, frame, sizex, sizey, maxphotons_per_pix, maxphotons_per_line); %mex function
		pixdtime = round(pixdtime_raw / hist_binningsize);

		for x=1:sizex
			for y=1:sizey
				pixdtime(x,y, pixcount(x,y)+1:maxphotons_per_pix) = -1; %fill the unused part with -1
			end
		end

		pixcountb = pixcountb + int32(binning( pixcount, pix_binningsize)); %combine photons for bin size

		%pixel binning 
		for xb = 1:pix_binningsize
			for yb = 1:pix_binningsize
				pixdtimeb(:, :, (0:maxphotons_per_pix-1) * framesumsize * pix_binningsize^2 + (f-1)*pix_binningsize^2 + (yb-1)*pix_binningsize + xb ) ...
										= pixdtime(xb:pix_binningsize:sizex1, yb:pix_binningsize:sizey1, :); %combine timing
			end
		end
	end


	%write photon count to hist file
	fwrite(hfid, pixcountb, pixcount_format);

	
	%calculate histogram
	pixhistb = flimhistogram(int16(pixdtimeb), int16(histlength)); %mex function
	for h=1:histlength
        pixhistb_conv(h, :, :) = conv2(squeeze(double(pixhistb(h, :, :))), ones(flim_pix_avsize), 'same');
    end
     
	%fit the histogram to calculate the average lifetime and t0
	
	hist_allpixels = squeeze(sum(sum(pixhistb, 2), 3));
	
	if ~isempty(fitrange)
		fit_points =  max(round(fitrange(1) / dtstep),1) :  min(round(fitrange(2) / dtstep), histlength);
	else
		fit_points = 1:histlength;
	end
	hist_xdata = (0:histlength-1)' * dtstep;

	[data_est_all, params_est_all, sse_all, exitflagsse_all] = flim_doubleexpfit_offset(hist_xdata(fit_points), hist_allpixels(fit_points), ...
                                                                            'tauD', tauD_init, 'tauAD', tauAD_init, 'tauG', tauG_init, 't0', t0_init);
	onsettime = params_est_all(6); 
	fprintf('onset time %.4f ns\n', onsettime);

	
	%average lifetime
	avlifetime =  double(  sum(pixdtimeb, 3) +  sum(pixdtimeb==-1, 3) ) ./ double(pixcountb) * dtstep  - onsettime;

	%write average lifetime to hist file
	fwrite(hfid, avlifetime, avlifetime_format);
    
	
	%write histogram to hist file
    fwrite(hfid, pixhistb_conv, hist_format);
end


if dataframe_size>1
	fprintf('\n');
end

fclose(hfid);


