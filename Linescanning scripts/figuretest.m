figure;
plotbrowser('on');
hold on
%title([expstr, '-', num2str(imagenum), ' roi', num2str(roinum(r)) '  dF/F'], 'FontSize',30);
title({'bGp'},'FontSize',30);

xlabel({'Time (ms)'},'FontSize',20);
    %xlim([470 1400])
ylabel({'(F-F0)/F0'},'FontSize',20);
    ylim([-1 2])
  
   % rectangle('Position', [b{1, 1}.bt(1), -2*b{1, 1}.av_sigma_bGp, b{1, 1}.bt(end), 4*b{1, 1}.av_sigma_bGp], 'FaceColor', [1 0.8 0.8], 'EdgeColor', 'none');
    p=length(Pr_data{1,1}.b);
    for n=1:p;
             plot(Pr_data{1, 1}.b{1,1}.bt,Pr_data{1, 4}.b{1,n}.bGp, 'b','LineWidth',1);
             %plot(b{1, 1}.bt,b{1, n}.bRp, 'r','LineWidth',2);
    end
    
    
    x = [4.8/7 4.8/7];
    y = [0.75 0.4];
    x1= [0.65 0.75];
    y1= [0.835 0.035];
   % annotation('arrow',x,y,'LineWidth',2,'Color',[1 0 0],'HeadStyle','vback2'); %'HeadStyle','cback2','HeadWidth',10, 'HeadLength',10, 'LineWidth',4
   % annotation('textbox', [x1, y1],'String',{'LED-Stimulation'},'FontSize',14,'LineStyle','none','Color',[1 0 0]);
%[0.6 0.5 0.05 0.03]

  
saveas(gcf,'stim.jpg');