bin=1;

aG= Ch1Region3IntensityAverage;
aR= Ch2Region3IntensityAverage;
at= Time0000000to7123200000ms;

aGraw=aG;

ratioG_R=aG./aR;

%{
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

for k=1:n;
    bt(k)=mean(at((k-1)*bin+1:k*bin));
end
bt;
%}
%figure 
plot(at,aGraw);

%{
figure;
plot(at,aG);
figure;
plot(bt,bG);
figure;
plot(at,ratioG_R);
%}