clear

FileList=dir('*.dat');

LifetimeList=[];
for i=1:size(FileList,1)
    
    Data=importdata(FileList(i).name);
    LifetimeList=[LifetimeList;Data(end,1)-Data(1,1)];
    
end

%MeanLifetime=expfit(LifetimeList);

X_tmBleaching = (0:1:max(LifetimeList));
Y_tmBleaching = (sum(LifetimeList>=X_tmBleaching)./size(LifetimeList,1));
plot(X_tmBleaching,Y_tmBleaching);

F = @(x,xdata)exp(-(x(1)/60)*xdata)*x(2)+x(3);
x0 = [12 1 0];
[x,resnorm,resid,exitflag,output,lambda,J] = lsqcurvefit(F,x0,X_tmBleaching',Y_tmBleaching');
ci = nlparci(x,resid,'Jacobian',J);

Yfit1=exp(-(x(1)/60)*X_tmBleaching)*x(2)+x(3);
%Yfit2=exp(-(1/MeanLifetime*X));


plot(X_tmBleaching,Y_tmBleaching,'LineWidth',2,'Color','g');
hold on
%plot(X_tmBleaching,Yfit1,'LineWidth',2,'Color','g');
%hold on
%plot(X,Yfit2,'r');
xtick = get(gca,'XTickLabel');  
set(gca,'XTickLabel',xtick,'fontsize',14) % axis tick label size
set(gca,'XTickLabelMode','auto')
ylabel('Survival Probability','FontSize',14); % axis label size
xlabel('Time (s)','FontSize',14); % axis label size
xlim([0 100]);