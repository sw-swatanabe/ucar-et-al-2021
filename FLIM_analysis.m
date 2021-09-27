%{
Program for the analysis of Pico-Quant FLIM

This program uses pq_makehistfile.m to creates a photon count histogram and save as a file, and
flim_disp_pq_xyzt.m to display fluorescence lifetime images.

%}

  
clearvars -except summary dt1 datafolder f00 l subfol_name0 foldername0 i s_roi_bindingfraction s_roi_photoncount;

%Set the following to 0 to skip calculation of the histogram
recalculate =1;


%%%%%%%%
%FLIM data

cd E:\Results\FW_FLIM;
%load('dt_all_large.mat');
%load('dt_all.mat');
load('dt_all_small.mat');
%load('dt_small.mat');
%change line 283, 284 accordingly

pq_datafolder = foldername0;
% 'E:\Results\FW_FLIM\2018\01\180117\1.sptw'; 

cd(pq_datafolder);
f0=dir('LSMMeasurement_*.ptu');
l2=length(f0);
%{
for i=1:l2;
    eval(['s_roi_bindingfraction' num2str(i) '= i']);
    eval(['s_roi_photoncount' num2str(i) '= i']);
    end;
  %}  
    
for i=1:l2;
      
  % subfol_name=f0(s).name;
   % foldername = [datafolder '\' subfol_name ];
   % cd(foldername);
    
%Folder to output the histogram
pq_histfolder = pq_datafolder;

%Data file name (common part);
pq_filename_base = 'LSMMeasurement_' ;%'IRF_900nm_6mW_150408_'; %;

%Data file number
pq_filenumber =i;

%Data channel
pq_channel = 1;

%%%%%%%%

%Fitting parameters
%free fraction tau
tauD_init = 3.7; %mCyRFP; 3.55, mScarlet; 3.9   mTq2; 3.7
%binding fraction tau
tauAD_init =0.4; %mCyRFP; 0.11(paper) or 0.9(my calc),  mTq2-Venus; 0.7, mTq2-ShG;0.4(when 1:4), 0.7 (when 1:6), mScarlet-mMrn; 0.6
%IRF width
tauG_init = 0.07; %0.16; %0.4505; %0.1;
%onset
t0_init = 1.0;


%%%%%%%%

%photon count
dc_rgbmin=10; 
dc_rgbmax=70;
dc_submin = 1000;
dc_submax = 10000;

%average lifetime
dt_rgbmin=2.5; 
dt_rgbmax=4;
dt_maskmin=10;  
dt_maskmax=75;
dt_submax = dc_submax;
dt_submin = dc_submin;

%z-sum image
ds_rgbmin = 5;
ds_rgbmax = 30;
ds_submin = 10000;
ds_submax = 100000;

 %%%%%%%%
%FV data
fv_datafolder = 'E:\FW_FLIM\1612\161221\1.sptw';

%FV file name (.oif); '' if FV data is not used
fv_filename = '';

%FV data channel
fv_channel = 1;


%%%%%%%%

%data size
zsize = 1;

%data range to analyze; [] when entire range is used
trange =   1:13; % 1:20 % if [], it is required to set tsize maually or by FV file ;
zrange =   []; %5:8;

%number of data for summation (0 for all)
tsumsize = 0;% 0;
zsumsize = 1;% 2;

%Binning of pixels
pix_binningsize = 2;

%Moving average of pixels
flim_pix_avsize = 4;

%Binning of histogram; multiples of 4 ns
hist_binningsize = 8;

%FV median filter and averaging
fv_medfiltsize = 2;
fv_pix_avsize = 2;

%Set the following to 1 to remove unnecessary frame timing signals with certain scanning conditions (XYZT, etc)
framegap = 0;

%Range of the histogram to fit; [] to use the entire histogram range
fitrange = [];


%mode of data averaging
tsum_mode = 'binning';
zsum_mode = 'overlap';

%%%%%%%%


%
datatype = 'PQ64'; 

if isempty(fv_filename) || strcmp(fv_datafolder, '')
    use_fv = 0;
else
    use_fv = 1;
end

if use_fv
	fvimg = fvdata(fv_datafolder, fv_filename, 'ch', fv_channel, 'nodata');
    xsize = fvimg.sizex;
    ysize = fvimg.sizey;
    zsize = fvimg.sizez;
    tsize = fvimg.sizet;
end


if ~exist(pq_histfolder, 'dir')
	mkdir(pq_histfolder);
end


if isempty(trange)
    trange = 1:tsize;
end
if isempty(zrange)
    zrange = 1:zsize;
end

if tsumsize==0
    tsumsize = length(trange);
end
if zsumsize==0
    zsumsize = length(zrange);
end
framesumsize = tsumsize * zsumsize;

switch tsum_mode
    case 'binning'
        tsumrange_start = trange(1:tsumsize:length(trange));
    case 'overlap'
        tsumrange_start = trange(1:length(trange)-tsumsize+1);
end
switch zsum_mode
    case 'binning'
        zsumrange_start = zrange(1:zsumsize:length(zrange));
    case 'overlap'
        zsumrange_start = zrange(1:length(zrange)-zsumsize+1);
end

tsize_b = length(tsumrange_start);
zsize_b = length(zsumrange_start);


dataframe_size = tsize_b * zsize_b;

for t=1:tsize_b
    tsumrange{t} = tsumrange_start(t):tsumrange_start(t)+tsumsize-1;
end
for z=1:zsize_b
    zsumrange{z} = zsumrange_start(z):zsumrange_start(z)+zsumsize-1;
end
for t=1:tsize_b
    for z=1:zsize_b
        framesumrange_temp = ones(zsumsize, 1) * (tsumrange{t} - 1) * zsize + (zsumrange{z}'-1) * ones(1, tsumsize) +1;
        framesumrange{(t-1)*zsize_b + z} = framesumrange_temp(:)';
    end
end



%
%Calculate the histogram and save

datafname = [pq_datafolder '\' pq_filename_base num2str(pq_filenumber) '.ptu'];

histfname = [pq_histfolder '\' pq_filename_base num2str(pq_filenumber) '-z' num2str(zsumsize) '-t' num2str(tsumsize) '-b' num2str(pix_binningsize) '.hist'];

if ~exist(histfname, 'file') || recalculate
	fprintf('Prcessing %s       file# %d   ', pq_datafolder, pq_filenumber);

    pq_makehistfile;
end


%Display images

flim_disp_pq_xyzt;

dt.setroi(dt_all_small);

flim_pixelfit;


end
clearvars -except summary dt1 datafolder f00 l subfol_name0 foldername0 i s_roi_bindingfraction s_roi_photoncount;
save s_roi_bindingfraction;
save s_roi_photoncount;

    