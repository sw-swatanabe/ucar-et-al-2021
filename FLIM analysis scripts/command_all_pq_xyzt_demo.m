clear 
datafolder= 'E:\Results\Pushing_Paper\FLIM_Conv4\LatA\representative';

cd(datafolder);
f00=dir('*.sptw');
l=length(f00);

for s=1:l
    subfol_name0=f00(s).name;
    foldername0 = [datafolder '\' subfol_name0];
    cd(foldername0);
    
    fcommand_pq_xyzt_demo;
   
   %cd(datafolder);
   %graphname=['graph_' filename]; 
   %saveas(gcf,graphname);
   %saveas(gcf,graphname, 'jpeg');
   %print(gcf, graphname,'');
     
end
