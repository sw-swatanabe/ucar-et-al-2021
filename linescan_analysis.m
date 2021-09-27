
datafolder= 'C:\raw_data\FV\2021\07\210726\Exp1';
graphname= '210726_Exp1_Fig';
%graphname2= '170928_raw';   

cd(datafolder);
f0=dir('s*');
l=length(f0);
c=cell(0);

for s=1:l
    filename=f0(s).name;
    foldername = [datafolder '\' filename ];
    cd(foldername);
       
    c{s}= f_command_iGlu(c);
 
    
end


cd(datafolder);
Pr_data=c;
%%
%{
%%calcualtes mean value at stim window
lp=length(Pr_data);
for s=1:lp
    k=length(Pr_data{1,s}.b{1,1}.mean_all);
    tempc{s,1} = {Pr_data{1,s}.b{1,1}.mean_all};

    %{
    tempn_mean= nan(lp,20);
    tempn_area= nan(lp,20);
    tempn_area_dif= nan(lp,20);
    tempn_peaks= nan(lp,20);
    %}
for sk=1:lp;
    tempn_mean(sk,1:length(Pr_data{1,sk}.b{1,1}.mean_all)) = Pr_data{1,sk}.b{1,1}.mean_all;
    av(sk)=mean(tempn_mean(sk,1:10));
    
    %{
    tempn_area(sk,1:length(Pr_data{1,sk}.b{1,1}.area_all_stim)) = Pr_data{1,sk}.b{1,1}.area_all_stim;
    av_area(sk)=mean(tempn_area(sk,1:10));
    
    tempn_area_dif(sk,1:length(Pr_data{1,sk}.b{1,1}.D_area_all)) = Pr_data{1,sk}.b{1,1}.D_area_all;
    av_area_dif(sk)=mean(tempn_area_dif(sk,1:10));
    
    tempn_peaks(sk,1:length(Pr_data{1,sk}.b{1,1}.peak_all)) = Pr_data{1,sk}.b{1,1}.peak_all;
    max_of_peaks=max(max(tempn_peaks));
    %}


end
    
tempn_mean;
Pr_data{1,1}.b{1,1}.all_means_all=tempn_mean;

%{
tempn_area;
tempn_area_dif;
tempn_peaks;

Pr_data{1,1}.b{1,1}.all_area_all_stim=tempn_area;
Pr_data{1,1}.b{1,1}.all_area_dif=tempn_area_dif;   
Pr_data{1,1}.b{1,1}.max_of_peaks=max_of_peaks;   
%}

Pr_data{1,1}.b{1,1}.averages_of_means=av;
%Pr_data{1,1}.b{1,1}.averages_of_areas=av_area;
%Pr_data{1,1}.b{1,1}.averages_of_area_difss=av_area_dif;
end 
means_of_stimwindow=Pr_data{1,1}.b{1,1}.all_means_all;
%}
%%
l=length(Pr_data);

for k=1:l
p=length(Pr_data{1, k}.b);

    for n=1:p;
          
        b(:,n)= (Pr_data{1, k}.b{1, n}.bGp);
                 
      c2(n,:)=mean(b(n,:));    
       
    end
    
    pl=length(Pr_data{1, k}.b{1, 1}.bGp);
    for s=1:pl;
   c2(s,1)=mean(b(s,:));
    end
Pr_data{1, k}.b{1, 1}.mean_trace=c2;
end
%clearvars -except Pr_data;

%%
kp1=[datafolder '\' 'keep_bin' num2str(c{1, 1}.b{1, 1}.bin) ];
%kp1=[datafolder '\' 'keep_bin' num2str(c{1, 1}.b{1, 1}.bin) '_time window' num2str(c{1, 1}.b{1, 1}.A_start) 'to' num2str(c{1, 1}.b{1, 1}.A_end) 'ms'];
mkdir(kp1);
cd(kp1);
 
plot_all_bGp;
set(gcf,'papersize',[650,880]);
  saveas(gcf,[graphname '_bGp']);
  % saveas(gcf,graphname, 'png');
  % saveas(gcf,graphname, 'jpeg');

  plot_mean_trace;
set(gcf,'papersize',[650,880]);
  saveas(gcf,[graphname 'mean_trace']);
 %{
figure;
  boxplot((Pr_data{1, 1}.b{1, 1}.all_area_dif(:,1:10))')
  saveas(gcf,[graphname '_boxplot_area-diff']);

figure;
boxplot((Pr_data{1, 1}.b{1, 1}.all_means_all(:,1:10))')
  saveas(gcf,[graphname '_boxplot_means']);

 
%}  
%%
%plot_all_delGp;
%plot_all_bdeltaGp;
%plot_all_deltaGp;
%saveas(gcf,graphname2);
 
%%
clearvars -except Pr_data means_of_stimwindow; %tempc; 
save Pr_data;
save means_of_stimwindow;
