function  [b]=singletests(b);
bin=1;
aG= b.Ch2R1-b.Ch2R2;
at= b.time;
%at= Time0000000to951999500ms;

l=length(aG);
n=floor(l/bin);

for nc=1:l;
    nrm=mean(aG(1:10))-mean(aG(l-10:l)); 
    nrm_=nrm/l;
    aG_(nc,1)=aG(nc,1)+(nc-1)*nrm_;
end    
aG=aG_;


for k=1:n;
    bG(k)=mean(aG((k-1)*bin+1:k*bin));
   
end
bG;
bG_mean= mean(bG);
bG_dF=(bG-bG_mean)/bG_mean;
b.bG=bG_dF;
for k=1:n;
    bt(k)=mean(at((k-1)*bin+1:k*bin));
end
bt;
b.bt=bt;
figure_singletest;

%%

