function bicSNR(projectdir)

cd(projectdir)

fn1 = 'lassoBIC.out';
fn2 = 'fssBIC.out';
fn3 = 'bseBIC.out';
fn4 = 'relaxedlassoBIC.out';
y1=csvread(fn1);
y2=csvread(fn2);
y3=csvread(fn3);
y4=csvread(fn4);
  
l=length(y1);

x=zeros(l,1);

%for i=1:l
%	x(i) = i/10;
%end
x = [0.05, 0.09, 0.14, 0.25, 0.42, 0.71, 1.22, 2.07, 3.52, 6];
%This part is plot dependent
f=figure;
set(f,'name','ComparePlots') 
h=plot(x(:), y1(:,1), 'r+', x(:), y2(:,1), 'k^', x(:), y3(:,1), '*b', x(:), y4(:,1), 'mx');

label1='Lasso';
label2='Forward Stepwise Selection';
label3='Backwards Stepwise Elimination';
label4='Relaxed Lasso';
lgd=legend({label1,label2,label3,label4}, 'Box', 'off', 'Location', 'northeast');


xlabel('Signal to noise ratio') 
ylabel('BIC')
axis([0,6,-500,-100]) %Controls the range of values on the two axis

set(h,{'markers'},{10}) %Changes the marker size
set(h(1), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
set(h(2), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
set(h(3), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
set(h(4), 'MarkerEdgeColor', 'm', 'MarkerFaceColor', 'm');

%These parts are plot independent
%curtick=get(gca,'Xtick'); %Controls the tick usage on the x axis and y axis
%set(gca,'XTickLabel',cellstr(num2str(curtick(:)))); 
set(gca,'fontsize',18,'fontweight','bold') %Sets the fontsize of the axis labels to 18 and makes them bold
x0=100; %Controls position where plot is placed
y0=100;
width=800; %Controls the dimensions of the plot to be consistent
height=400;
lgd.FontWeight='bold'; %Makes the legend text bold
set(gcf,'units','points','position',[x0,y0,width,height]) %Sets those values to the dimensions of the plot

saveas(gcf, 'bic.png')
saveas(gcf, 'bic.eps')
