%%

%Mean value at around peak gives best result
bin_width_m=0.04;  
%0.04 is best for 171005 (bin=4, combine 171003 and 171004 quantal data, adding previous ES data makes the graph complicated
%0.02 is best for 171005 (bin=2, combine 171003 and 171004 quantal data)
%0.02 is best for 171005 (bin=5, combine 171003 and 171004 quantal data)
%bin4 is better than bin2, bin3 or bin5

fitt_m=Pr_data{1, 1}.b{1, 1}.mean_all;
%fitt(136:180)=Pr_data{1, 2}.b{1, 1}.area_all;
%fitt(181:191)=Pr_data{1, 3}.b{1, 1}.area_all;
range=max(fitt_m)-min(fitt_m);
bins=range/bin_width_m;
figure; hist(fitt_m, bins);


%%
bin_width_p=0.06; 
%0.03 is best for 171005 (bin=2, combine 171003 and 171004 quantal data)

fitt_p=Pr_data{1, 1}.b{1, 1}.peak_all;
%fitt(136:180)=Pr_data{1, 2}.b{1, 1}.area_all;
%fitt(181:191)=Pr_data{1, 3}.b{1, 1}.area_all;
range=max(fitt_p)-min(fitt_p);
bins=range/bin_width_p;
figure; hist(fitt_p, bins);

%%
bin_width_a=0.06;
%0.6 is best for 171005 (combine 171003 and 171004 quantal data)

fitt_a=Pr_data{1, 1}.b{1, 1}.D_area_all;
%fitt(136:180)=Pr_data{1, 2}.b{1, 1}.area_all;
%fitt(181:191)=Pr_data{1, 3}.b{1, 1}.area_all;
range=max(fitt_a)-min(fitt_a);
bins=range/bin_width_a;
figure; hist(fitt_a, bins);