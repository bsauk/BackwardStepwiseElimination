function plotRR(projectdir)

cd(projectdir)

fn1 = 'lasso.dat';
fn2 = 'fss.dat';
fn3 = 'avgrr.dat';
fn4 = 'relaxedlasso.dat';

y1=csvread(fn1);
y2=csvread(fn2);
y3=csvread(fn3);
y4=csvread(fn4);
 
l=length(y1);

x=zeros(l,1);
x = linspace(100,1,100);

%This part is plot dependent
f=figure;
set(f,'name','RR vs NNZ') 
h=plot(y1(:,1), y1(:,2), 'r+', y2(1:2:end,1), y2(1:2:end,2), 'k^', x(1:2:end), y3(1:2:end), '*b', y4(1:4:end,1), y4(1:4:end,2), 'mx');

label1='Lasso';
label2='Forward Stepwise Selection';
label3='Backwards Stepwise Elimination';
label4='Relaxed Lasso';
lgd=legend({label1,label2,label3,label4}, 'Box', 'off', 'Location', 'northeast');


xlabel('Number of nonzero coefficients')
ylabel('Relative Risk')
%axis([0,100,0,1]) %Controls the range of values on the two axis

set(h,{'markers'},{10}) %Changes the marker size
set(h(1), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
set(h(2), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
set(h(3), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
set(h(4), 'MarkerEdgeColor', 'm', 'MarkerFaceColor', 'm');

%New_XTickLabel = get(gca,'xtick');
%set(gca,'XTickLabel',New_XTickLabel);
set(gca,'fontsize',18,'fontweight','bold') %Sets the fontsize of the axis labels to 18 and makes them bold
x0=100; %Controls position where plot is placed
y0=100;
width=800; %Controls the dimensions of the plot to be consistent
height=400;
lgd.FontWeight='bold'; %Makes the legend text bold
set(gcf,'units','points','position',[x0,y0,width,height]) %Sets those values to the dimensions of the plot

saveas(gcf, 'rr.png')

