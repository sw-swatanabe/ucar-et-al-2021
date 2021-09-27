
f=dir('*.csv');
l=length(f);
b=cell(0);
for i=1:l;
    filename=f(i).name;
     %fprintf('loading %s\n','files',filename);
    b{i}=importfile_singletest(filename);
    b{i}.fname=filename;
   
end

%
for j=1:length(b);

    b{j}=singletests(b{j});

end
%}
sucrose300= b;

save sucrose300;
%%
    %figure_bGp; % ƒ¢F/F0
 
   % figure_bG_R;
   % figure_bG;  % ƒ¢F
   % figure_Graw;  % Fraw
   