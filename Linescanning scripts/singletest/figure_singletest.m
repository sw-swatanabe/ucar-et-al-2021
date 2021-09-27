figure;
plotbrowser('on');
hold on
%title([expstr, '-', num2str(imagenum), ' roi', num2str(roinum(r)) '  dF/F'], 'FontSize',30);
%title({''},'FontSize',30);

xlabel({'Time (ms)'},'FontSize',20);
    %xlim([470 1400])
ylabel({'Count'},'FontSize',20);
    ylim([-2 2])
  
plot(b.bt, b.bG);
  