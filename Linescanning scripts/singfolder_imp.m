 f=dir('*.csv');
l=length(f);
b=cell(0);
for i=1:l;
    filename=f(i).name;
     %fprintf('loading %s\n','files',filename);
    b{i}=imp_iGlu(filename);
    b{i}.fname=filename;
   
end