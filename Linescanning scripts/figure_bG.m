figure;
plotbrowser('on');
hold on
title({'bG'},'FontSize',30);

xlabel({'Time (ms)'},'FontSize',20);
    %xlim([450 600])
ylabel({'(F-F0)/F0'},'FontSize',20);
    %ylim([-10 10])
  
    rectangle('Position', [Pr_data{1, 1}.bt(1), -2*Pr_data{1, 1}.av_sigma_bG, Pr_data{1, 1}.bt(end), 4*Pr_data{1, 1}.av_sigma_bG], 'FaceColor', [1 0.8 0.8], 'EdgeColor', 'none');
    p=length(Pr_data);
    for n=1:p;
             plot(Pr_data{1, 1}.bt,Pr_data{1, n}.bG, 'b','LineWidth',3);
             %plot(Pr_data{1, 1}.bt,Pr_data{1, n}.bR, 'r','LineWidth',2);
    end
    
