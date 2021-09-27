function [b]= iGlu_imaging(b)
%%
% set the following

% when stimulation is at CA3, total scan 170 ms

stim= 60; %25; %520; % timing of LED stim in ms
bin= 6;
remove_a=6;
remove_b=6;%0 is fine
baseline_cut=stim;
stim_sig=4;
%stim_sig=floor((stim-remove_b)/bin)-1;

%bin4 is mostly better than bin2
%{
A_s= 65; %area calculation start point
A_e= 85; %area calculation end poin
P_s= 65; %peak calculation start point(171006; 80 gave a good result)
P_e= 85; %peak calculation end point
b.bin=bin;
%}
%baseline_cut=stim;


G_back=0;
l_sample=length(b.Ch1_bouton);
G_bouton=b.Ch1_bouton (2:l_sample);

t=b.Time(2:l_sample);
intrvl=t(2);
cut_baseline= floor(baseline_cut/intrvl);


%{
pA_s=floor(A_s/intrvl)+1;
pA_e=floor(A_e/intrvl)+1;

b.A_start=A_s;
b.A_end=A_e;
b.A_start_elemntnumber=pA_s;
b.A_end_elemntnumber=pA_e;
%}
%%
rem_a=cut_baseline+floor(remove_a/intrvl);
rem_b=cut_baseline-floor(remove_b/intrvl);
dif=rem_a-rem_b;
l_sample2=l_sample-dif;


%removes LED artifact


G_bouton_2(1:rem_b-1)=G_bouton(1:rem_b-1);
G_bouton_2(rem_b:l_sample2-2)=G_bouton(rem_a:l_sample-2);
G_bouton(rem_b:l_sample2-2)=G_bouton_2(rem_b:l_sample2-2);

%
l_sample=l_sample2-2;

%raw data is prepared
Graw=G_bouton-G_back;


%%
l=length(t);
Graw_=[];

%Belach correction only; here, uses Graw instead of Graw_ 

for nc=1:l;
    nrm=mean(Graw(1:10))-mean(Graw(l-10:l)); 
    nrm_=nrm/l;
    Graw_(nc,1)=Graw(nc,1)+(nc-1)*1.2*nrm_;
end    
Graw=Graw_;



%%

%if evoked-release is analyzed
 MG=mean(Graw(1:cut_baseline)); %beware to set baseline position limit

%if spontaneous/mini-release is analyzed
%MG=mean(Graw);

DeltaG=(Graw-MG); % 

    b.DeltaG_sigma=std(DeltaG(:));

DeltaGp=((Graw-MG)/MG);

    b.DeltaGp_sigma=std(DeltaGp(:));


%% 
%binning

at=t(1:l_sample);
l=length(at);
n=floor(l/bin);

%time
bt=[];

for k=1:n;
    bt(k)=mean(at((k-1)*bin+1:k*bin));
end
bt;
b.bt=bt';

%DeltaGp
aG=DeltaGp;
bGp=[];

for k=1:n;
    bGp(k)=mean(aG((k-1)*bin+1:k*bin));
   
end
bGp;

b.t=t;
b.stim=stim;
b.G_bouton=G_bouton;
b.G_back=G_back;
b.Graw=Graw;
b.DeltaG=DeltaG;
b.DeltaGp=DeltaGp;
b.bGp=bGp';

b.Graw_sigma = std(Graw(:));
b.deltaG_sigma = std(DeltaG(:));
b.deltaGp_sigma = std(DeltaGp(:));
b.bGp_sigma = std(b.bGp(1:stim_sig));

b.maxbGp=max(b.bGp);
b.bin=bin;

%{
b.area_stim=trapz(b.bGp(floor(pA_s/bin)+1:floor(pA_e/bin)+1));
b.area_base=trapz(b.bGp(1:floor((pA_s-1)/bin)));
b.D_area=b.area_stim-b.area_base;


b.peak=max(b.bGp(floor(pA_s/bin)+1:floor(pA_e/bin)+1));
b.mean=mean(b.bGp(floor(pA_s/bin)+1:floor(pA_e/bin)+1));
%b.area=trapz(b.bGp(floor(stim/t(1)/bin)-floor(15/t(1)/bin):floor(stim/t(1)/bin)+floor(110/t(1)/bin)));
b.pA_start_time=b.t(pA_s);
b.pA_end_time=b.t(pA_e);
b.pA_start_th_elementof_binneddata=floor(pA_s/bin)+1;
b.pA_end_th_elementof_binneddata=floor(pA_e/bin)+1;
b.pA_s_time_of_binneddata=b.bt(floor(pA_s/bin)+1);
b.pA_e_time_of_binneddata=b.bt(floor(pA_e/bin)+1);

%}
