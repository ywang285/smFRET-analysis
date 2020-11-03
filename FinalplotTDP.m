% This function makes the FRET state transition plot based on the dwellData
% which is passed as the parameter.

% This function automatically scales the heatmap of the transitions from 0.0
% to 1.0, you can adjust it further by passing the parameter i.e.
% StartHeatMap and EndHeatMap
% i.e. if you put the StartHeatMap's value as 0.1 and EndHeatMap's value at
% 1.0. Then the 10% of overall transitions are discared and remaining 90%
% are plotted. 


function [X, Y, Z] = FinalplotTDP(dwellData, res,StartHeatMap,EndHeatMap)

% Example of Usage 
% FinalplotTDP(dwellData, 24,0.1,1.0);

% dwellData is a file that should have three columns 
% Each row in it signifies a FRET transition. HAMMY generates these FRET
% transitions output files for each smFRET trace, you can concatenate all
% those output files ( for a given experiment) to create a single file 
% The first column contains the startingFRET value of a given transition
% The second column contains the EndFRET value of the transition
% The third column is typically the duration of the time it was in the
% startingFRET state before transitioning to the final(EndFRET) value.
% The third column is not necessary as such.

% You can write some MATLAB scripts to retrieve the FRET transitions from
% many output files (of HAMMY analysis)

% Example of dwellData array :
% -0.0388240000000000	0.351950000000000	4
% 0.351950000000000	-0.0388240000000000	1
% -0.0388240000000000	0.351950000000000	11
% 0.351950000000000	-0.0388240000000000	2
% -0.0388240000000000	0.351950000000000	33
% 0.351950000000000	-0.0388240000000000	1
% -0.0388240000000000	0.351950000000000	48
% 0.351950000000000	-0.0388240000000000	1



    
        %size of gaussians in TDP
    VAR = 0.001;
    
    RESOLUTION = 800;
    
    X = linspace(-0.2, 1.2, res)';
    Y = X';

    %remove NaN transitions
    n = 1;
    ms = size(dwellData);
    while n <= ms(1)
        if isnan(dwellData(n, 2))
            if n == 1
                dwellData = dwellData(2:ms(1), :);
            elseif n == ms(1)
                dwellData = dwellData(1:(n-1), :);
                break;
            else
                dwellData = [dwellData(1:(n-1), :); dwellData((n+1):ms(1), :)];
            end
            ms = size(dwellData);
        else
            n = n + 1;
        end
    end
    
        %start and stop vectors
    start = dwellData(:, 1);
    stop = dwellData(:, 2);
    
    size(start);
    
        %build TDP function
    for j = (1:res)
        for i = (1:res)
            Z(j, i) = sum((1/(2*pi*VAR))*exp(-((X(i) - start).^2 + (Y(j) - stop).^2)/(2*VAR)));
        end
    end
    
    %figure, pcolor(X, Y, Z), colormap([0 0 0; jet]), shading flat, axis square tight
    
    %interpolate
    XI = linspace(-0.2, 1.2, RESOLUTION);
    ZI = interp2(X, Y, Z, XI', XI, 'cubic');
    MaximumZ=max(max(ZI));
    MinimumZ=min(min(ZI));
    ZI=ZI-(MinimumZ);
    MaximumZ=max(max(ZI));
    ZI=ZI./MaximumZ;
    figure, pcolor(XI', XI, ZI), colormap([1 1 1; jet]), shading flat, axis square tight;
    caxis([StartHeatMap EndHeatMap]);
    
    xtick = get(gca,'XTickLabel');  
    set(gca,'XTickLabel',xtick,'fontsize',10) % axis tick label size
    set(gca,'XTickLabelMode','auto')
    ylabel('FRET Efficiency','FontSize',10); % axis label size
    xlabel('FRET Efficiency','FontSize',10); % axis label size
    
    colorbar();
    TDPPlotName=sprintf('TDP Plot.png');
    print(TDPPlotName,'-dpng','-r600');