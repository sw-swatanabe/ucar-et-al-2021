
clear

%%

%imgchannel1 is the variable for Ca-imaging, thus, set FV channelnumber of Ca/Glu for this one accordingly
imgchannel1 = 2;
imgchannel2 = 3;
imgchannel3 =[];

%leak coeefficient
I=0;


subtractsubimage = 0; subtractmainimage = 0;
displaysubimage = 0;
alignimages = 0;
calculateratio = 0;
displayoverlay=1;
calculatetav = 0;
endcolor = 0;

averagebg = 0;
bgrange = [];
starttime = 0;
usebgval = 0;
gaussianfiltersize = 0;
plotroiblock_excludedata = [101];
expstr_bg = ''; imagenum_bg = []; 

medfiltsize = [1];
avsize = [5];

bgroi_channel =1;
tbinsize = 1;

loadzcenter = 0;
zcenter = 2;

ratiomin = 0.15; ratiomax = 0.7;

expstr='_Cell'; zrange=[]; trange = []; tint = 0.3; prerange = 5; tunit = 10; normmin =-2 ; normmax = -8;
imagenum=61;


texpand = 5;

%%
tbinsize2 = tunit;
bleachimagenum = imagenum; 
rgbmin1 = 10; rgbmax1 = 100;
rgbmin2 = 10; rgbmax2 = 100;
rgbmin2 = 10; rgbmax3 = 100;
maskmin = 130; maskmax = 250;

normmin_norm=-2e4; normmax_norm=8e4;
ratiomin=1; ratiomax=5;

plotroiblock_dispmode = 'normal';
%plotroiblock_dispmode = 'twocolor';
%plotroiblock_dispmode = 'multicolor';
%plotroiblock_dispmode = 'postcolor';

plotroiblock_prerange = 10;
plotroiblock_prerange = 20;

roiblock_prerange = 1:20;
roiblock_postrange = 21:40;

%%
fvanalysisfast3_common_s;
