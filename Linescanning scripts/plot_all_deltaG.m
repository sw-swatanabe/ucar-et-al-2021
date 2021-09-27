%no win block, no bin

fig1=figure;
pos_fig1 = [0 0 300 880];
set(fig1,'Position',pos_fig1)

%plotbrowser('on');
hold on
title({'dF/F0 '},'FontSize',30);
xl1=25; xl2=45;
%xl1=150; xl2=250;
%xl1=400; xl2=650;
%yl2=2;

l=length(Pr_data);

for i=1:l, 
      yl2=2*max(Pr_data{1, 1}.b{1,1}.maxmaxbGp);
 
  end

for i=1:l-1;
    subplot(l,1,i);
    hold on 
    
%title( [filename,  'dF/F'], 'FontSize',30);

%xlabel({'Time (ms)'},'FontSize',20);
    xlim([xl1 xl2])
ylabel({'(F-F0)/F0 '},'FontSize',12);
    %ylim([-0.6 yl2])
  
    %rectangle('Position', [Pr_data{1, i}.b{1, 1}.bt(1), -2*Pr_data{1, i}.b{1, 1}.av_sigma_DeltaGp, Pr_data{1, i}.b{1, 1}.bt(end), 4*Pr_data{1, i}.b{1, 1}.av_sigma_DeltaG], 'FaceColor', [1 0.8 0.8], 'EdgeColor', 'none');
    
    p=length(Pr_data{1, i}.b);
    for n=1:p;
              plot(Pr_data{1, 1}.b{1, 1}.t,Pr_data{1, i}.b{1, n}.DeltaGp, 'k','LineWidth',1);
             %plot(b{1, 1}.bt,b{1, n}.bRp, 'r','LineWidth',2);
    end

     subplot(l,1,l);
    hold on  
%title( [filename,  'dF/F'], 'FontSize',30);

xlabel({'Time (ms)'},'FontSize',15);
     xlim([xl1 xl2])
ylabel({'(F-F0)/F0'},'FontSize',11);
   % ylim([-0.6 yl2])
  
    %rectangle('Position', [Pr_data{1, l}.b{1, 1}.bt(1), -2*Pr_data{1, l}.b{1, 1}.av_sigma_DeltaGp, Pr_data{1, l}.b{1, 1}.bt(end), 4*Pr_data{1, l}.b{1, 1}.av_sigma_DeltaG], 'FaceColor', [1 0.8 0.8], 'EdgeColor', 'none');
    p=length(Pr_data{1, l}.b);
    for n=1:p;
             plot(Pr_data{1, l}.b{1, n}.t,Pr_data{1, l}.b{1, n}.DeltaGp, 'k','LineWidth',1);
             %plot(b{1, 1}.bt,b{1, n}.bRp, 'r','LineWidth',2);
    end
end

for i=1:l;
    sft=1/(l+1);
     x = [0.5 0.5];  %for arrow
    y1(i) = [0.89-((i-1)*sft)];
    y2(i) = [0.87-(i-1)*sft];
    y = [y1(i), y2(i)]; %for arrow1
    %y2 = [0.73 0.71]; %for arrow2
    txt_title= [0.45 0.93 0.038 0.047]; %for text1_title
   
    valt1(i)= [0.89-(i-1)*sft] ;
    valt=[valt1(i)];
    txt_= [0.49 valt 0.038 0.026]; %for LED
    %txt3= [0.42 0.73 0.038 0.026]; %for text3
    annotation('arrow', x,y,'LineWidth',2,'Color',[1 0 0],'HeadStyle','vback2'); %'HeadStyle','cback2','HeadWidth',10, 'HeadLength',10, 'LineWidth',4
    %annotation('arrow',x,y2,'LineWidth',2,'Color',[1 0 0],'HeadStyle','vback2'); %'HeadStyle','cback2','HeadWidth',10, 'HeadLength',10, 'LineWidth',4
    annotation('textbox', txt_title,'String',{'dF'},'FontSize',10,'LineStyle','none');%'Color',[2 0 0]);
    annotation('textbox', txt_,'String',{'LED-stim'},'FontSize',10,'LineStyle','none','Color',[1 0 0]);
    %annotation('textbox', txt3,'String',{'LED-stim'},'FontSize',10,'LineStyle','none','Color',[1 0 0]);
end
