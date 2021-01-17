function ssePlot(projectdir, snr)

cd(projectdir)

fn1 = 'lasso.dat';
fn2 = 'fss.dat';
fn3 = 'bse.dat';
fn4 = 'relaxedlasso.dat';
fn5= 'alamo.dat';
top = snr+1;
y1=csvread(fn1);
y2=csvread(fn2);
y3=csvread(fn3);
y5=csvread(fn5);
l3=length(y3);

x3=zeros(l3,1);

for i=1:l3
	x3(i) = 601-i;
end

%This part is plot dependent
f=figure;
set(f,'name','ComparePlots') 
h=plot(y1(:,1), y1(:,2), 'r+', y2(:,1), y2(:,2), 'k^', x3, y3(:), ...
       '*b', y5(:,1), y5(:,2), 'gs');

label1='Lasso';
label2='Forward Stepwise Selection';
label3='Backwards Stepwise Elimination';
label4='ALAMO';
lgd=legend({label1,label2,label3,label4}, 'Box', 'off', 'Location', 'northeast');
xlabel('Number of basis functions') 
ylabel('Relative test error')
set(h,{'markers'},{10}) %Changes the marker size
set(h(1), 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
set(h(2), 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
set(h(3), 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
set(h(4), 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g');

axis([0,600,1,top]) %Controls the range of values on the two axis

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

saveas(gcf, 'results.png')
