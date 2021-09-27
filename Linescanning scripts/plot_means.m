function createaxes(Parent1, X1, Y1)
%CREATEAXES(PARENT1, X1, Y1)
%  PARENT1:  axes parent
%  X1:  vector of x data
%  Y1:  vector of y data

%  Auto-generated by MATLAB on 02-Nov-2017 17:51:02

% Create axes
axes1 = axes('Parent',Pr_data{1, 1}.b{1, 1}.xaxis,'FontSize',20);
box(axes1,'on');
hold(axes1,'all');

% Create plot
plot(Pr_data{1, 1}.b{1, 1}.xaxis,Pr_data{1, 1}.b{1, 1}.averages_of_means,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],...
    'Marker','square',...
    'LineWidth',2,...
    'Color',[0 0 0]);

% Create xlabel
xlabel({'Time (min)'},'FontSize',30);

% Create ylabel
ylabel({'dF'},'FontSize',30);

