if ~exist('dataversion', 'var')
	dataversion = 2;
end

if ~isempty(imagenum_bg)
	usebgimage = 1;
else
	usebgimage = 0;
end

if usebgimage
	[filepath_bg, filename_bg] = getfvpath(expstr_bg, imagenum_bg);
	bgimg1 = fvdata(filepath_bg, filename_bg, 'med', medfiltsize, 'av', avsize, 'ch', imgchannel1);
	if ~isempty(imgchannel2)
		bgimg2 = fvdata(filepath_bg, filename_bg, 'med', medfiltsize, 'av', avsize, 'ch', imgchannel2);
	end
	if ~isempty(imgchannel3)
		bgimg3 = fvdata(filepath, filename, 'med', medfiltsize, 'av', avsize, 'ch', imgchannel3);
	end
end

d1 = imagedisp3('fig', 1, 'min', rgbmin1, 'max', rgbmax1); d1.titlestr = [expstr '-' num2str(imagenum) '  Ch1']; d1.scalebarlength = 1;
if ~isempty(imgchannel2)
	d2 = imagedisp3('fig', 2, 'min', rgbmin2, 'max', rgbmax2); d2.titlestr = [expstr '-' num2str(imagenum) '  Ch2']; d2.scalebarlength = 1;
end
if ~isempty(imgchannel3)
	d3 = imagedisp3('fig', 3, 'min', rgbmax3, 'max', rgbmax3); d3.titlestr = [expstr '-' num2str(imagenum) '  Ch3']'; d3.scalebarlength = 1;
end



%% load data

ndata = length(imagenum);
nframesloaded = 0;

for i=1:ndata
	
	[filepath, filename] = getfvpath(expstr, imagenum(i));

	disp('loading img1');
	if dataversion==1
		img1 = fvdata_ver1(filepath, filename, 'med', medfiltsize, 'av', avsize, 'ch', imgchannel1, 'z', zrange, 't', trange);
	else
		img1 = fvdata(filepath, filename, 'med', medfiltsize, 'av', avsize, 'ch', imgchannel1, 'z', zrange, 't', trange);
	end
	if img1.nzstacks>1
		data1raw(:,:, nframesloaded+1:nframesloaded+img1.nframes) = squeeze(sum(img1.data, 3));
	else
		data1raw(:,:, nframesloaded+1:nframesloaded+img1.nframes) = img1.data;
	end
	
	if ~isempty(imgchannel2)
		disp('loading img2');
		img2 = fvdata(filepath, filename, 'med', medfiltsize, 'av', avsize, 'ch', imgchannel2, 'z', zrange, 't', trange);
		if img1.nzstacks>1
			data2raw(:,:, nframesloaded+1:nframesloaded+img1.nframes) = squeeze(sum(img2.data, 3));
		else
			data2raw(:,:, nframesloaded+1:nframesloaded+img1.nframes) = img2.data;
		end
	end

	if ~isempty(imgchannel3)
		disp('loading img3');
		img3 = fvdata(filepath, filename, 'med', medfiltsize, 'av', avsize, 'ch', imgchannel3, 'z', zrange, 't', trange);
		if img1.nzstacks>1
			data3raw(:,:, nframesloaded+1:nframesloaded+img1.nframes) = squeeze(sum(img3.data, 3));
		else
			data3raw(:,:, nframesloaded+1:nframesloaded+img1.nframes) = img3.data;
		end
	end

	
	fprintf('%d frames\n', img1.nframes);

	if i==1
		d1.setparam(img1);
		if ~isempty(imgchannel2)
			d2.setparam(img1);
		end
		if ~isempty(imgchannel3)
			d3.setparam(img1);
		end
	end
	
	if ~isempty(img1.bleachpt) && dataversion==2
		d1.setbleachpt(img1.bleachpt, 'noupdate', 'comb', img1.comb, 'compmode', img1.compmode,  'compint', img1.compint );

		if ~isempty(imgchannel2)
			d2.setbleachpt(img1.bleachpt, 'noupdate', 'comb', img1.comb, 'compmode', img1.compmode,  'compint', img1.compint );
		end
		if ~isempty(imgchannel3)
			d3.setbleachpt(img1.bleachpt, 'noupdate', 'comb', img1.comb, 'compmode', img1.compmode,  'compint', img1.compint );
		end
	end
		

	nframesloaded = nframesloaded + img1.nframes;
end

nframes = nframesloaded;


%% temporal binning

ntbins = floor(nframes / tbinsize);
if nframes==1
	tbinsize = 1;
	ntbins = 1;
end

data1 = zeros(img1.sizex, img1.sizey, ntbins);
if ~isempty(imgchannel2)
	data2 = zeros(img1.sizex, img1.sizey, ntbins);
end
if ~isempty(imgchannel3)
	data3 = zeros(img1.sizex, img1.sizey, ntbins);
end

for t=1:ntbins
	binrange = (t-1) * tbinsize+1 : t * tbinsize;
	
	data1(:,:,t) = mean(data1raw(:,:,binrange), 3);
	if ~isempty(imgchannel2)
		data2(:,:,t) = mean(data2raw(:,:,binrange), 3);
	end
	if ~isempty(imgchannel3)
		data3(:,:,t) = mean(data3raw(:,:,binrange), 3);
	end
end
	
for t=1:ntbins
	d1.append(data1(:,:,t), 'obj', img1, 'noupdate');
	if ~isempty(imgchannel2)
		d2.append(data2(:,:,t) - I * data1(:,:,t), 'obj', img1, 'noupdate');    % this line was modified
	end
	if ~isempty(imgchannel3)
		d3.append(data3(:,:,t), 'obj', img1, 'noupdate');
	end
end



if ~isempty(imgchannel2)
	imagedisp_fbuttonsetting(d1, 'd1', {'d2'});
	imagedisp_fbuttonsetting(d2, 'd2', {'d1'});
else
	imagedisp_fbuttonsetting(d1, 'd1');
end


d1.rgbmax = mmax(d1.data{1});
d1.updatec;
if ~isempty(imgchannel2)
	d2.rgbmax = mmax(d2.data{1});
	d2.updatec;
end
if ~isempty(imgchannel3)
	d3.rgbmax = mmax(d3.data{1});
	d3.updatec;
end

%% background subtraction

%set background
if usebgimage || usebgval
	if usebgimage
		bg1raw = mmean(bgimg1.data) / bgimg1.nzstacks * img1.nzstacks;
		if ~isempty(imgchannel2)
			bg2raw = mmean(bgimg2.data) / bgimg2.nzstacks * img2.nzstacks;
		end
		if ~isempty(imgchannel3)
			bg3raw = mmean(bgimg3.data) / bgimg3.nzstacks * img3.nzstacks;
		end
	end
	
	if usebgval
		if length(bg1_ext) >1
			bg1raw = bg1_ext;
			if ~isempty(imgchannel2)
				bg2raw = bg2_ext;
			end
			if ~isempty(imgchannel3)
				bg3raw = bg3_ext;
			end
		else
			bg1raw = bg1_ext * ones(1, img1.nframes);
			if ~isempty(imgchannel2)
				bg2raw = bg2_ext * ones(1, img1.nframes);
			end
			if ~isempty(imgchannel3)
				bg3raw = bg3_ext * ones(1, img1.nframes);
			end
		end
			
		
	end
	
else
    
    
    disp('set roi for bg');
	bgroinum = 1;
	
	d1.updatec;
	if ~isempty(imgchannel2)
		d2.updatec;
	end
	if ~isempty(imgchannel3)
		d3.updatec;
	end
	
	if isempty(imgchannel2)
		bgroi_channel = 1;
	end
	
	if bgroi_channel==1
		d1.setroir(bgroinum);
		if ~isempty(imgchannel2)
			d2.setroi(d1);
		end
		if ~isempty(imgchannel3)
			d3.setroi(d1);
		end
		
	end
	
	if bgroi_channel==2
		d2.setroir(bgroinum);
		d1.setroi(d2);
		if ~isempty(imgchannel3)
			d3.setroi(d2);
		end
		
	end
	
	if bgroi_channel==22
		d2fine.setroir(bgroinum);
		d1fine.setroi(d2fine);
		if ~isempty(imgchannel3)
			d3fine.setroi(d2fine);
		end
		
	end
    
    
    if any(bgroi_channel==[1:2])
		bg1raw = d1.roimean(bgroinum); %nframes elements
		if ~isempty(imgchannel2)
			bg2raw = d2.roimean(bgroinum);
		end
		if ~isempty(imgchannel3)
			bg3raw = d3.roimean(bgroinum);
		end
		
	end
	
	if bgroi_channel==22
		bg1raw = d1fine.roimean(bgroinum); %nframes elements
		bg2raw = d2fine.roimean(bgroinum);
	end
end	

if averagebg
	if isempty(bgrange)
		bgrange = 1:ntbins;
	end
	
	bg1 = ones(size(bg1raw)) * mean(bg1raw(bgrange));
	if ~isempty(imgchannel2)
		bg2 = ones(size(bg1raw)) * mean(bg2raw(bgrange));
	end
	if ~isempty(imgchannel3)
		bg3 = ones(size(bg1raw)) * mean(bg3raw(bgrange));
	end
	
else
	bg1 = bg1raw;
	if ~isempty(imgchannel2)
		bg2 = bg2raw;
	end
	if ~isempty(imgchannel3)
		bg3 = bg3raw;
	end
	


%% bg image


for t=1:ntbins
	data1s(:,:,t) = data1(:,:,t) - bg1(t);
% 	data1s(:,:,t) = data1(:,:,t) - bgimage1(:,:,t);
	d1.data{t} = data1s(:,:,t);
end
if ischar(rgbmax1) && strcmp(rgbmax1, 'auto')
	rgbmax1 = mmax(d1.data{1});
end
d1.rgbmax = rgbmax1;
d1.updatec;
	

d1.updatec;
if ~isempty(imgchannel2)
	for t=1:ntbins
		data2s(:,:,t) = (data2(:,:,t) - bg2(t)) - I * (data1(:,:,t) - bg1(t));  %this line was modified
% 		data2s(:,:,t) = data2(:,:,t) - bgimage2(:,:,t);
		d2.data{t} = data2s(:,:,t);
	end
	if ischar(rgbmax2) && strcmp(rgbmax2, 'auto')
		rgbmax2 = mmax(d2.data{1});
	end
	d2.rgbmax = rgbmax2;
	d2.updatec;
end
if ~isempty(imgchannel3)
	for t=1:ntbins
		data3s(:,:,t) = data3(:,:,t) - bg3(t);
		d3.data{t} = data3(:,:,t) - bg3(t);
	end
	if ischar(rgbmax3) && strcmp(rgbmax3, 'auto')
		rgbmax3 = mmax(d3.data{1});
	end
	d3.rgbmax = rgbmax3;
	d3.updatec;
end




disp('image subtracted');

if isfield(img1, 'time')
	d1.time = img1.time(1:tbinsize:tbinsize*ntbins)/1000;
	if ~isempty(imgchannel2)
		d2.time = img1.time(1:tbinsize:tbinsize*ntbins)/1000;
	end
end



%%
if calculateratio
	dr = imagedisp3('fig', 9); dr.rgbparam = 'rainbow';
	dr.maskmin = maskmin; dr.maskmax = maskmax; dr.scalebarlength = 1;

	dr.setparam(img1);
	if displaysubimage
		dr.subopacity = 0.5;
	end
	
	dr.time = d1.time;

	dr.titlestr = [expstr '-' num2str(imagenum)];
	

	for t=1:ntbins
		ratioval_temp = data1s(:,:,t) ./ max(data2s(:,:,t), 0.01);
		dr.append(ratioval_temp, 'noupdate');
		dr.maskdata{t} = data2(:,:,t);

		if ~isempty(imgchannel3) && displaysubimage
			dr.subdata{t} = data3(:,:,t);
			dr.submin = 0;
			dr.submax = mmax(data3) * 0.6;
		end

		dr.filename{t} = img1.filename;
	end
	dr.rgbmax = ratiomax; dr.rgbmin = ratiomin;

	if ~isempty(img1.bleachpt)
		dr.setbleachpt(img1.bleachpt, 'noupdate', 'comb', img1.comb, 'compmode', img1.compmode,  'compint', img1.compint );
	end
	
	imagedisp_fbuttonsetting(dr, 'dr')
	dr.showimage(1);
	dr.update('contrastall');

end


%% align images

if ntbins>1 && alignimages
	disp('set roi for alignment');
	d1.align;
	d2.align(d1);
	if ~isempty(imgchannel3)
		d3.align(d1);
	end
end


%%
if displayoverlay
	do = imagedisp3('fig', 11); do.rgbparam = 'g'; do.subparam = 'm';
	do.scalebarlength = 1;
	do.rgbmin = d1.rgbmin; do.rgbmax = d1.rgbmax;
	do.submin = d2.rgbmin; do.submax = d2.rgbmax;

	do.setparam(img1);
	do.time = d1.time;
	do.subopacity = 1;
	
	do.titlestr = [expstr '-' num2str(imagenum)];


	for t=1:ntbins
		do.append(d1.data{t}, 'noupdate');
		do.subdata{t} = d2.data{t};
	end
	
	imagedisp_fbuttonsetting(do, 'do')

	do.updatec;

end


%% time average

if calculatetav

	ntbins2 = floor(nframes / tbinsize2);

	da1 = imagedisp3('fig', 151);
	da2 = imagedisp3('fig', 152);
	
	
	for t=1:nframes
		data1rs(:,:,t) = d1.datarotateshift(d1.data{t}, t);
		if ~isempty(imgchannel2)	
			data2rs(:,:,t) = d2.datarotateshift(d2.data{t}, t);
		end
	end

	for t=1:ntbins2
		data1m(:,:,t) = mean(data1rs(:, :, (t-1)*tbinsize2+1:t*tbinsize2), 3);
		if ~isempty(imgchannel2)
			data2m(:,:,t) = mean(data2rs(:, :, (t-1)*tbinsize2+1:t*tbinsize2), 3);
		end
	end


	for t=1:ntbins2
		da1.append(data1m(:,:,t), 'noupdate');
		da2.append(data2m(:,:,t) - I * data1m(:,:,t), 'noupdate');  % this line was modified
		
		da2.subdata{t} = data2m(:,:,1);
	end
	
	da2.rgbparam = 'm';
	da2.subparam = 'g';
	da1.setbleachpt(img1.bleachpt, 'noupdate', 'comb', img1.comb, 'compmode', img1.compmode,  'compint', img1.compint );
	da2.setbleachpt(img1.bleachpt, 'noupdate', 'comb', img1.comb, 'compmode', img1.compmode,  'compint', img1.compint );

	da1.rgbmax = d1.rgbmax; 
	da2.rgbmax = d2.rgbmax; 
	da2.submax = d2.rgbmax; 
	
	da1.titlestr = d1.titlestr;
	da2.titlestr = d2.titlestr;
	
	if ~isempty(imgchannel2)
		imagedisp_fbuttonsetting(da1, 'da1', {'da2'});
		imagedisp_fbuttonsetting(da2, 'da2', {'da1'});
	else
		imagedisp_fbuttonsetting(da1, 'da1');
	end

	da1.updatec;
	da2.updatec;
end




%%

fclose all;

