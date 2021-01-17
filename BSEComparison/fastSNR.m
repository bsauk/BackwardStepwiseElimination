function fastSNR(projectdir)

cd(projectdir)

fn1 = 'lasso.out';
fn2 = 'fss.out';
fn3 = 'bse.out';
fn4 = 'relaxedlasso.out';

y1=csvread(fn1);
y2=csvread(fn2);
y3=csvread(fn3);
y4=csvread(fn4);
 
l=length(y1);

x=zeros(l,1);

x = [0.05, 0.09, 0.14, 0.25, 0.42, 0.71, 1.22, 2.07, 3.52, 6];
%%%%%%%%%%%%%%%% Number of Basis Functions %%%%%%%%%%%%%%%%
f=figure;
set(f,'name','Compare NNZ') 
h=plot(x(:), y1(:,1), 'r+', x(:), y2(:,1), 'k^', x(:), y3(:,1), '*b', x(:), y4(:,1), 'mx');

label1='Lasso';
label2='Forward Stepwise Selection';
label3='Backwards Stepwise Elimination';
label4='Relaxed Lasso';
lgd=legend({label1,label2,label3,label4}, 'Box', 'off', 'Location', 'northeast');

xlabel('Signal to noise ratio') 
ylabel('Number of basis functions')
axis([0,6,0,90])

set(h,{'markers'},{10}) %Changes the marker size
set(h(1), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
set(h(2), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
set(h(3), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
set(h(4), 'MarkerEdgeColor', 'm', 'MarkerFaceColor', 'm');

%These parts are plot independent
set(gca,'fontsize',18,'fontweight','bold', 'Xscale', 'log') %Sets the fontsize of the axis labels to 18 and makes them bold
New_XTickLabel = get(gca,'xtick');
set(gca,'XTickLabel',New_XTickLabel);
x0=100; %Controls position where plot is placed
y0=100;
width=800; %Controls the dimensions of the plot to be consistent
height=400;
lgd.FontWeight='bold'; %Makes the legend text bold
set(gcf,'units','points','position',[x0,y0,width,height]) %Sets those values to the dimensions of the plot
saveas(gcf, 'terms', 'epsc')

%%%%%%%%%%% Relative Risk %%%%%%%%%%%%%%%%%%%%

set(f,'name','Compare RR') 
h=plot(x(:), y1(:,2), 'r+', x(:), y2(:,2), 'k^', x(:), y3(:,2), '*b', x(:), y4(:,2), 'mx');
ylabel('Relative Risk')
axis([0,6,0,1])

label1='Lasso';
label2='Forward Stepwise Selection';
label3='Backwards Stepwise Elimination';
label4='Relaxed Lasso';
lgd=legend({label1,label2,label3,label4}, 'Box', 'off', 'Location', 'northeast');

xlabel('Signal to noise ratio') 
set(h,{'markers'},{10}) %Changes the marker size
set(h(1), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
set(h(2), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
set(h(3), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
set(h(4), 'MarkerEdgeColor', 'm', 'MarkerFaceColor', 'm');

%These parts are plot independent
set(gca,'fontsize',18,'fontweight','bold', 'Xscale', 'log') %Sets the fontsize of the axis labels to 18 and makes them bold
New_XTickLabel = get(gca,'xtick');
set(gca,'XTickLabel',New_XTickLabel);
x0=100; %Controls position where plot is placed
y0=100;
width=800; %Controls the dimensions of the plot to be consistent
height=400;
lgd.FontWeight='bold'; %Makes the legend text bold
set(gcf,'units','points','position',[x0,y0,width,height]) %Sets those values to the dimensions of the plot

saveas(gcf, 'rr', 'epsc')

%%%%%%%%%%% Relative Test Error %%%%%%%%%%%%%%%%%%%%

set(f,'name','Compare RTE') 
h=plot(x(:), y1(:,3), 'r+', x(:), y2(:,3), 'k^', x(:), y3(:,3), '*b', x(:), y4(:,3), 'mx');
label1='Lasso';
label2='Forward Stepwise Selection';
label3='Backwards Stepwise Elimination';
label4='Relaxed Lasso';
lgd=legend({label1,label2,label3,label4}, 'Box', 'off', 'Location', 'northeast');
xlabel('Signal to noise ratio')
ylabel('Relative Test Error')
axis([0,6,1,1.5])
 
set(h,{'markers'},{10}) %Changes the marker size
set(h(1), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
set(h(2), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
set(h(3), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
set(h(4), 'MarkerEdgeColor', 'm', 'MarkerFaceColor', 'm');

%These parts are plot independent
set(gca,'fontsize',18,'fontweight','bold', 'Xscale', 'log') %Sets the fontsize of the axis labels to 18 and makes them bold
New_XTickLabel = get(gca,'xtick');
set(gca,'XTickLabel',New_XTickLabel);
x0=100; %Controls position where plot is placed
y0=100;
width=800; %Controls the dimensions of the plot to be consistent
height=400;
lgd.FontWeight='bold'; %Makes the legend text bold
set(gcf,'units','points','position',[x0,y0,width,height]) %Sets those values to the dimensions of the plot

saveas(gcf, 'rte', 'epsc')

%%%%%%%%%%% Proportion of Variance Explained %%%%%%%%%%%%%%%%%%%%

set(f,'name','Compare PVE') 
h=plot(x(:), y1(:,4), 'r+', x(:), y2(:,4), 'k^', x(:), y3(:,4), '*b', x(:), y4(:,4), 'mx');
ylabel('Proportion of Variance Explained')
axis([0,6,0,1])

label1='Lasso';
label2='Forward Stepwise Selection';
label3='Backwards Stepwise Elimination';
label4='Relaxed Lasso';
lgd=legend({label1,label2,label3,label4}, 'Box', 'off', 'Location', 'northeast');

xlabel('Signal to noise ratio') 
set(h,{'markers'},{10}) %Changes the marker size
set(h(1), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
set(h(2), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
set(h(3), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
set(h(4), 'MarkerEdgeColor', 'm', 'MarkerFaceColor', 'm');

%These parts are plot independent
set(gca,'fontsize',18,'fontweight','bold', 'Xscale', 'log') %Sets the fontsize of the axis labels to 18 and makes them bold
New_XTickLabel = get(gca,'xtick');
set(gca,'XTickLabel',New_XTickLabel);
x0=100; %Controls position where plot is placed
y0=100;
width=800; %Controls the dimensions of the plot to be consistent
height=400;
lgd.FontWeight='bold'; %Makes the legend text bold
set(gcf,'units','points','position',[x0,y0,width,height]) %Sets those values to the dimensions of the plot
saveas(gcf, 'pve', 'epsc')
