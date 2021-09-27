%win blocked, binned
%colorstring = 'kbgrcmkbgrcmkbgrcmkbgrcm';
colorstring = 'kbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcmkbgrcm';
fig1=figure;
pos_fig1 = [0 0 400 1000];
set(fig1,'Position',pos_fig1)

%plotbrowser('on');
hold on
title({'dF/F0'},'FontSize',30);
xl1=0; xl2=130;
%xl1=150; xl2=250;
%xl1=0; xl2=length(Pr_data{1, 1}.b{1, 1}.bGp);
%yl2_2= 0.3;

l=length(Pr_data);

for i=1:l, 
      yl2_11(i,:)=max(Pr_data{1, i}.b{1,1}.mean_trace);
      yl1_11(i,:)=min(Pr_data{1, i}.b{1,1}.mean_trace); 
  end
yl2_3=1.05*max(yl2_11);
yl1_3=1.05*min(yl1_11);
for i=1:l-1;
    subplot(l,1,i);
    hold on 
    
%title( [filename,  'dF/F'], 'FontSize',30);

%xlabel({'Time (ms)'},'FontSize',20);
    xlim([xl1 xl2])
%ylabel({'(F-F0)/F0'},'FontSize',12);
    ylim([yl1_3 yl2_3])
  
   % rectangle('Position', [Pr_data{1, i}.b{1, 1}.bt(1), -2*Pr_data{1, i}.b{1, 1}.av_sigma_bGp, Pr_data{1, i}.b{1, 1}.bt(end), 4*Pr_data{1, i}.b{1, 1}.av_sigma_bGp], 'FaceColor', [1 0.8 0.8], 'EdgeColor', 'none');
    
    p=length(Pr_data{1, i}.b);
    for n=1:p;
              %plot(Pr_data{1, 1}.b{1, 1}.bt, Pr_data{1, i}.b{1, n}.bGp,  colorstring(n),'LineWidth',2);
             
              %plot(b{1, 1}.bt,b{1, n}.bRp, 'r','LineWidth',2);
    end
     plot(Pr_data{1, 1}.b{1, 1}.bt, Pr_data{1, i}.b{1, 1}.mean_trace, 'k','LineWidth',3);
end 
  
     subplot(l,1,l);
    hold on  
%title( [filename,  'dF/F'], 'FontSize',30);

xlabel({'Time (ms)'},'FontSize',15);
        xlim([xl1 xl2])
% ylabel({'(F-F0)/F0'},'FontSize',10);
    ylim([yl1_3 yl2_3])
  
    %rectangle('Position', [Pr_data{1, l}.b{1, 1}.bt(1), -1.5*Pr_data{1, l}.b{1, 1}.av_sigma_bGp, Pr_data{1, l}.b{1, 1}.bt(end), 3*Pr_data{1, l}.b{1, 1}.av_sigma_bGp], 'FaceColor', [1 0.8 0.8], 'EdgeColor', 'none');
    p=length(Pr_data{1, l}.b);
    for n=1:p;
            % plot(Pr_data{1, l}.b{1, n}.bt,Pr_data{1, l}.b{1, n}.bGp, colorstring(n),'LineWidth',2);
            
             %plot(b{1, 1}.bt,b{1, n}.bRp, 'r','LineWidth',2);
    end
     plot(Pr_data{1, l}.b{1, n}.bt, Pr_data{1, l}.b{1, 1}.mean_trace, 'k','LineWidth',3);

for i=1:l;
    sft=1/(l+1);
     x = [0.5 0.5];  %for arrow
    y1(i) = [0.89-((i-1)*sft)];
    y2(i) = [0.87-(i-1)*sft];
    y = [y1(i), y2(i)]; %for arrow1
    %y2 = [0.73 0.71]; %for arrow2
    txt_title= [0.45 0.93 0.038 0.047]; %for text1_title 
    %annotation('textbox', txt_title,'String',{'dF/F'},'FontSize',30,'LineStyle','none');%'Color',[2 0 0]);
    valt1(i)= [0.89-(i-1)*sft] ;
    valt=[valt1(i)];
   
    %{
    txt_= [0.49 valt 0.038 0.026]; %for LED
    %txt3= [0.42 0.73 0.038 0.026]; %for text3
    annotation('arrow', x,y,'LineWidth',2,'Color',[1 0 0],'HeadStyle','vback2'); %'HeadStyle','cback2','HeadWidth',10, 'HeadLength',10, 'LineWidth',4
    %annotation('arrow',x,y2,'LineWidth',2,'Color',[1 0 0],'HeadStyle','vback2'); %'HeadStyle','cback2','HeadWidth',10, 'HeadLength',10, 'LineWidth',4
    
    annotation('textbox', txt_,'String',{'LED-stim'},'FontSize',10,'LineStyle','none','Color',[1 0 0]);
    %annotation('textbox', txt3,'String',{'LED-stim'},'FontSize',10,'LineStyle','none','Color',[1 0 0]);
%}
end
