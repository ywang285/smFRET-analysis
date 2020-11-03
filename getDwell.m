function dwellData = getDwell(pathData)
    

% This function reads the continuous pathfile and basically jots down all
% the transitions present in the continous path file
    fileno = pathData(:, 1);
    FRET = pathData(:, 2);
    
        %transition no
    t = 1;
        %frame no in current transition
    n = 1;
    for (i=(1:(length(FRET)-1)))
        
            %new file
        if diff(fileno(i:i+1))
            dwellData(t, :) = [FRET(i) NaN n];
            t = t + 1;
            n = 1;
            continue;
        end
            
            %transition
        if diff(FRET(i:i+1))
            dwellData(t, :) = [FRET(i) FRET(i + 1) n];
            t = t + 1;
            n = 1;        
            %no transition
        else
            n = n + 1;
        end
    end
    
    
    % This routine is specific to a particular class of analysis. 
    % We are simply noting down the actual number of transitions that occur from given FRET ranges and printin them out in the same folder.
    selection = find(dwellData(:,1) > 0.2 & dwellData(:,1) < 0.6  & dwellData(:,2) > -0.3 & dwellData(:,2) < 0.2);
    dlmwrite('NumberofTransition_IL.dat',numel(dwellData(selection,3)),' ');
    
    selection = find(dwellData(:,1) > 0.6 & dwellData(:,1) < 1.4  & dwellData(:,2) > -0.3 & dwellData(:,2) < 0.2);
    dlmwrite('NumberofTransition_HL.dat',numel(dwellData(selection,3)),' ');
    
    selection = find(dwellData(:,1) > 0.6 & dwellData(:,1) < 1.4  & dwellData(:,2) > 0.2 & dwellData(:,2) < 0.6);
    dlmwrite('NumberofTransition_HI.dat',numel(dwellData(selection,3)),' ');
    
    selection = find(dwellData(:,1) > 0.2 & dwellData(:,1) < 0.6  & dwellData(:,2) > 0.6 & dwellData(:,2) < 1.4);
    dlmwrite('NumberofTransition_IH.dat',numel(dwellData(selection,3)),' ');
    
    selection = find(dwellData(:,1) > -0.3 & dwellData(:,1) < 0.2  & dwellData(:,2) > 0.6 & dwellData(:,2) < 1.4);
    dlmwrite('NumberofTransition_LH.dat',numel(dwellData(selection,3)),' ');

    selection = find(dwellData(:,1) > -0.3 & dwellData(:,1) < 0.2  & dwellData(:,2) > 0.2 & dwellData(:,2) < 0.6);
    dlmwrite('NumberofTransition_LI.dat',numel(dwellData(selection,3)),' ');

    