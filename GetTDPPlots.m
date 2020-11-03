function GetTDPPlots(StartHeatMap,EndHeatMap,SmoothingRange)

close all;

% This script uses a bunch of routine which reads all the HaMMY generated
% path files to prepare the TDP plot of the FRET transitions.
% This script also generates the FRET state transition density plots where
% in the heatmap normally goes from 0.0 to 1.0 but you can readjust the
% colormap by specifying the startpoint of the color map and endpoint of
% the color map in the parameters of this function (StartHeatMap,EndHeatMap)




% Example of Usage :
% StartHeatMap=0.1 ..the heatmap is colored from 0.0 to 1.0 by default, we can rescale that by specifying the new starting value here.
% EndHeatMap=0.1 ..the heatmap is colored from 0.0 to 1.0 by default, we can rescale that by specifying the new ending value here.
% SmoothingRange=0.1...the FRET transitions within the 0.1 ranged will be
% smoothed to a same value.
% GetTDPPlots(0.1,1.0,0.1);



% It makes use of the following function i.e
% getDwell.m
% So make sure that these are either in the directory or permanently in the matlab path

addpath('C:\Users\Digvijay Singh\Google Drive\Clound Sync_v1\smMATLAB\MATLABImportantPathFolder');
% This is a good way to manage all the important scripts, we are putting
% all the requisite functions in the folder above, this way it will be
% added onto the MATLAB path and we need not copy them every where where we
% might need them.


%This small routine reads in all the *path.dat files in the given directory
%and stitches them together to make a continuouspathfile which will then be
%used for later analysis.


files = dir('*path.dat') ;   %# list all *path.dat files which has the information about the entire fit HAMMY State
%               0         596.76        -12.373     -0.0211726     -0.0457079
%               1         738.76        -60.893     -0.0898303     -0.0457079
%               2         609.76         6.8468       0.011104     -0.0457079
%               3         691.76        -53.073      -0.083097     -0.0457079
%               4         710.76        -41.213     -0.0615536     -0.0457079
%               5         649.76         20.447      0.0305085     -0.0457079
%               6         629.76        -16.353     -0.0266593     -0.0457079
%              The path file will look something like above
%              The first column is simply the framenumber
%              The Second column is actual Donor Intensity Value
%              The Third column is actual Acceptor Intensity Value
%              The Fifth column is the state fit by HAMMY

files = {files.name}';  
CompleteSeries=[];
for i=1:numel(files)
   Contents_of_TheFile=textread(files{i});
   if isempty(Contents_of_TheFile) ==0
    HammyFRETSeries=Contents_of_TheFile(:,5);
    Numberseries=i*ones(numel(HammyFRETSeries),1);
    CompleteSeries=[CompleteSeries;[Numberseries HammyFRETSeries]];
   end
end

   NewFilename=sprintf('ContinuousPathFile.dat');
   dlmwrite(NewFilename,CompleteSeries,' ') ; 

%This routine below will use the path file which has single molecule time
%trajectories of many many molecules tied together, separated only by NaN
%values.

%It will use this massive path file to get the dwell times of transitions
%from one FRET region of interest to the other.

% Managed by Digvijay Singh(dgvjay@illinois.edu)



%**This small routine is to prep up the path file in a certain manner **
% Data=textread('ContinuousPathFile.dat');
% FileSeries=Data(:,1);
% FRETSeries=Data(:,2);
% FRETSeries( FRETSeries>=0.2 )=1;
% FRETSeries( FRETSeries<0.2 )=0;
% NewData=[FileSeries FRETSeries];
% dlmwrite('Corrected_ContinuousPathFile.dat',NewData,' ');



pathData=textread('ContinuousPathFile.dat');  % Reading the path data.


dwellData = getDwell(pathData);  % getDwell is a function which reads the pathData and basically
% records every kind of transition and the dwell times it takes to complete
% the transition.
% dwellData_3 = purifyDwell_3(dwellData); % Sometimes, the very first transition in each of the single molecule trajectory
% % is not really desired, so by doing this process, we can get rid of the
% % very first transition.
dwellData_temp=dwellData;
dwellData =purifyDwell(dwellData_temp, SmoothingRange);
    
FinalplotTDP(dwellData,24,StartHeatMap,EndHeatMap);

end