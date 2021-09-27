%{
minidata columns record as following
1-peak number 
2-position
3-height
4-width
5-area
%}

% 1-assign mEPSC raw data as lvm                lvm=mEPSC_200408_exp1; 
% 2-run first section of this script below 
% 3-refer to prepared  and plot select least noisy traces and exclude Rs traces and build cropped mEPSC cell
%   cr_mEPSC_200331 (1, 1:13)= lvm (1, 3:15); etc
% 4-assign selected mEPSC raw data as lvm2      lvm2=cr_mEPSC_200331; 
% 5-set bin, treshold etc if necessary  line# 39-44
% 6-run second section of this script
% 7 save summary, binneddata, rawdata, bin50_plotdata
% 8-copy summary.frequency, .amplitude, .width into excell file miniEPSC_data
% take average of ACSF, 20mm etc at corresponding place in excel
%%



figure;
hold on;

l2=size(lvm,2);


for n2=1:l2;
    pre_data=(lvm{1, n2}.Tab)*-1; %assign to `tab`
    tbin=lvm{1, n2}.Separator*1000;   % assign to `Separator` 1000x makes the output as ms
    timepointname=num2str(lvm{1, n2}.fname);
    timepointnumber=num2str(n2);
    legend=strcat(timepointnumber, {'_'},timepointname); 
    plot(tbin,pre_data, 'color', rand(1,3), 'LineWidth', 1, 'DisplayName' , {legend{1,1}} );

end

%%
figure;
hold on;

bin=200;
smoothwidth=5;
peakgroup=5;
smoothtype=2;
stdfactor=3;
treshold=5;

%lvm2=mEPSC_200331;
l3=size(lvm2,2);
for n2=1:l3;
pre_data=(lvm2{1, n2}.Tab)*-1; %assign to `tab`
tbin=lvm2{1, n2}.Separator*1000;   % assign to `Separator` 1000x makes the output as ms
timepointname=num2str(lvm2{1, n2}.fname);
timepointname=num2str(lvm2{1, n2}.fname);
    timepointnumber=num2str(n2);
    legend=strcat(timepointnumber, {'_'},timepointname);


abin=pre_data-mean(pre_data);


l=length(abin);
n=floor(l/bin);
bdata1=[];
btime=[];

for k=1:n;
    bdata1(k)=mean(abin((k-1)*bin+1:k*bin));
   
end
bdata1;

for k=1:n;
    btime(k)=mean(tbin((k-1)*bin+1:k*bin));
   
end
btime;
base=mean(bdata1);
tresh=std(bdata1);
%treshold=base+stdfactor*tresh;
minidata=findpeaksG(btime,bdata1,0,treshold,smoothwidth,peakgroup,smoothtype);
minidata(:,3)=minidata(:,3)*-1;
n_EPSC=size(minidata,1);
mEPSC_frequency=1000*(n_EPSC/max(tbin)); 

plot(btime,bdata1*-1, 'color', rand(1,3), 'LineWidth', 1, 'DisplayName' , {legend{1,1}} );

binned_data.bin_time{1,n2}=btime;
binned_data.bin_data{1,n2}=bdata1;
summary.Amp(1,n2)=mean(minidata(:,3));
summary.Width(1,n2)=mean(minidata(:,4));
summary.treshold{1,n2}=treshold;
summary.base{1,n2}=base;
summary.minidata{1,n2}=minidata;
summary.n_EPSC{1,n2}=n_EPSC;
summary.timepointnames(1,n2)={timepointname};
summary.frequency(1,n2)=mEPSC_frequency;
end
figure;
plot(summary.frequency)
%minidata(n_EPSC+1,1)=mEPSC_frequency;
%clearvars -except binned_data lvm lvm2 summary bin=50 smoothwidth peakgroup smoothtype stdfactor treshold
