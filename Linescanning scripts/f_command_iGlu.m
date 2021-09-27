function [c]=fcommand_iGlu(c)
%%

%cd E:\Results\FW_FLIM\FV\2017\03\170331\sucrose01\stim;

f=dir('*.csv');
l=length(f);
b=cell(0);
for i=1:l;
    filename=f(i).name;
     %fprintf('loading %s\n','files',filename);
    b{i}=importfile_0609(filename);
    b{i}.fname=filename;
   
end


for j=1:length(b);

    b{j}=iGlu_imaging(b{j});


b{1,1}.av_sigma_bGraw(j)=mean(b{1,j}.Graw_sigma);
b{1,1}.avs_sigma_DeltaG(j)=mean(b{1,j}.DeltaG_sigma);
b{1,1}.avs_sigma_DeltaGp(j)=mean(b{1,j}.DeltaGp_sigma);
b{1,1}.avs_sigma_bGp(j)=mean(b{1,j}.bGp_sigma);

b{1, 1}.mmaxbGp(j)=b{1,j}.maxbGp;
%{
b{1,1}.area_all_stim(1,j)=b{1,j}.area_stim;
b{1,1}.D_area_all(1,j)=b{1,j}.D_area;

b{1,1}.peak_all(1,j)=b{1,j}.peak;
%}
%b{1,1}.mean_all(1,j)=b{1,j}.mean;
%b{1,1}.avs_sigma_bG(j)=b{1,j}.bG_sigma;


%b{1,1}.av_sigma_delG(j)=mean(b{1,j}.delG_sigma);
%b{1,1}.av_sigma_delGp(j)=mean(b{1,j}.delGp_sigma);
%b{1,1}.av_sigma_bG(j)=mean(b{1,j}.bG_sigma);
%b{1,1}.av_sigma_bG_R(j)=mean(b{1,j}.bG_R_sigma);

%b{1,1}.av_sigma_bG_Rraw(j)=mean(b{1,j}.bG_Rraw_sigma);
%b{1, 1}.av_sigma_bG_R(j)=mean(b{1,j}.bG_R_sigma);


end

%b{1,1}.av_sigma_bG=mean(b{1,1}.avs_sigma_bG);
b{1,1}.av_sigma_bGp=mean(b{1,1}.avs_sigma_bGp);
b{1,1}.av_sigma_DeltaG=mean(b{1,1}.avs_sigma_DeltaG);
b{1,1}.av_sigma_DeltaGp=mean(b{1,1}.avs_sigma_DeltaGp);
b{1, 1}.maxmaxbGp=max(b{1,1}.mmaxbGp);

c.b=b;
%save Pr_data;
%%
    %figure_bGp; % ƒ¢F/F0
 
   % figure_bG_R;
   % figure_bG;  % ƒ¢F
   % figure_Graw;  % Fraw
   