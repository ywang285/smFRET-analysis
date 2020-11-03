% Written by Digvijay Singh  ( dgvjay@illinois.edu)
% This script will let you go over the .traces file in the given folder (
% i.e. the folder you input)
% It will pick the time series from each .traces file and for each of the
% time series, it will take the first five frame events and calculate their
% five separate FRET events and pool all of these kind of FRET events
% from all the time series present in all the .traces file
% For e.g. 
% If hel3.traces has 400 time series in it. For each time series, we will pick the first five frame events, calculate
% their FRET efficiency values and add them to a list of FRETValues.
% Therefore hel3.traces will generate 400*5 =2000 FRET event values.
% 
% If hel4.traces has 300 time series, it will contribute to 300*5= 1500 FRET event values.
% 
% Keep adding these FRET events from all the .traces values and in the end you will have large number
% of such FRET event values. These values are then plotted in a histogram to check their distribution.
% 
% Not all the time series will essentially be coming from good and viable single molecule spots.
% Spots which are either too bright  or too dim are generally not the good single molecule spots,
% so you will be asked to mention a range of the intensity and only the spots which fall with in the required
% intensity profile will be considered for the analysis.

% And in the end you will have the histogram solely from those range of
% intensitiy spot events.
function Make_a_FRET_Histogram_SOM

%For SOM 310D:
%L12=0.08;
%L13=0.00;
%L23=0.035;
ChannelLeakage=0;
DonorBackgroundLevel=0;
AcceptorBackgroundLevel=0;
LowerIntensity_cutoff=100;
UpperIntensity_cutoff=1000;
%Frames from a to b will be averaged for FRET histogram
a=1;
b=5;

% Example of Usage 
% Make_a_FRET_Histogram (0.07,50,80,450,2000)
% where 0.07 is the Channel Leakage Coefficienct
% 50 is the residual donor channel background level
% 80 is the residual acceptor channel background level
% 450 is the lower level of thce intensity cut off i.e the traces below this intensity (i.e. total) will not be used for the FRET histograms
% 2000 is the upper level of the intensity cut off i.e the traces above this intensity (i.e. total) will not be used for the FRET histograms
close all;
fclose('all');
% This script assumes that the .traces file in the folder(input above) is
% in the following order in your directory
% like hel1.traces...hel2.traces...hel3.traces
List_of_Everything_in_theGivenDirectory=dir;  % We are listing all the files present in the directory input

%ChannelLeakage=str2num(input('Enter the value of the Channel Leakage ? [0.22 for Andor1  0.07 for Andor2] :','s'));
%ChannelLeakage=0.07;
%DonorBackgroundLevel=input('Enter the value of the Donor Background Intensity Level :: '); 
%AcceptorBackgroundLevel=input('Enter the value of the Acceptor Background Intensity Level :: '); 

Result=zeros(1,2);
for i=1:numel(List_of_Everything_in_theGivenDirectory)
   if List_of_Everything_in_theGivenDirectory(i).isdir == 0
         FileName=List_of_Everything_in_theGivenDirectory(i).name;
      if strcmp(FileName(end-5:end),'traces')==1  % Pulling all .traces file only from the given directory
%          disp('The filename being analysed ::\n');         
%          disp(FileName);  % Showing the name of the file being currently analysed
         File_id=fopen(FileName,'r');
         
         Length_of_the_TimeTraces=fread(File_id,1,'int32');
%          disp('The length of the time traces is: ');
%          disp(Length_of_the_TimeTraces);
         Number_of_traces=fread(File_id,1,'int16');
%          disp('The number of traces in this file is:')
%          disp(Number_of_traces/2);
         % Reading in the entire raw data from the .traces binary file encoded in
         % int16 format as noted above that .traces is a binary file and
         % this is the way it was binarized and we are just extracting the
         % information from the binary file.
         Raw_Data=fread(File_id,Number_of_traces*Length_of_the_TimeTraces,'int16');
%          disp('Done reading data');
         fclose(File_id);
         % Converting into Donor and Acceptor traces of several selected spots in
         % the movie
         Index_of_SelectedSpots=(1:Number_of_traces*Length_of_the_TimeTraces);
         DataMatrix=zeros(Number_of_traces,Length_of_the_TimeTraces);
         Donors=zeros(Number_of_traces/2,Length_of_the_TimeTraces);
         Acceptors=zeros(Number_of_traces/2,Length_of_the_TimeTraces);
         DataMatrix(Index_of_SelectedSpots)=Raw_Data(Index_of_SelectedSpots);
         GammaFactor=6.0;    
         for i=1:(Number_of_traces/2)
           Donors(i,:)=DataMatrix(i*2-1,:)-DonorBackgroundLevel; %So this will be a matrix where each column will be the Donor time series of each selected spot of the movie
           Acceptors(i,:)=GammaFactor.*DataMatrix(i*2,:)-AcceptorBackgroundLevel; %So this will be a matrix where each column will be the Acceptor time series of each selected spot of the movie
         end

         FRETValueSeries=zeros(1,1); % Is empty now will later get filled...we are just initiating this series here...the value to 
         % it will be added later
	     Averaged_Combined_Intensity=zeros(1,1);  % Is empty now will later get filled...we are just initiating this series here...the value to 
         % it will be added later
         
	     for i=1:(Number_of_traces/2)
            for j=a:b
            Averaged_Combined_Intensity(i*j)=Donors(i,j)+Acceptors(i,j);
            FRETValueSeries(i*j)=(Acceptors(i,j)-ChannelLeakage*Donors(i,j))/(Donors(i,j)+Acceptors(i,j));
            end
         end
         
         % As mentioned in the very start:
         % It will pick the time series from each .traces file and for each of the
         % time series, it will take the first five frame events and calculate their
         % five separate FRET events and pool all of these kind of FRET events
         % from all the time series present in all the .traces file
         % FRETValueSeries is the variable which is used to pool the FRET value of a single frame even  from  each time
         % series of each .traces file
         
         % Averaged_Combined_Intensity stores the combined intensity
         % value(both donor and acceptor ) for each of the value stored in
         % the FRETValueSeries...i.e. the intensity of the selected spot as
         % well as it's FRET value is stored in the two arrays (list) in
         % the same order.
        

         
			Temporary_Result=[FRETValueSeries ; Averaged_Combined_Intensity];
            Result=[Result; Temporary_Result']; % This is a matrix which in its column is simply storying the FRET values in one column and the total intensity value series in the other column
      end
   end
end
         
% figure;
% subplot(2,1,1);
% hist(Result(:,1),80); % Making aFRET Histogram here since the column number 1 of the Result Matrix is the FRETValue Series
% zoom on;
% xlabel('FRET Efficiency States');
% ylabel('Counts');
% % The one above is making the FREt histogram for ALL the selected spots in
% % all the .traces file
% subplot(2,1,2);
% AverageIntensity=mean(Result(:,2))
% hist(Result(:,2),80); % Making a Histogram of the intensity value distribution here since the column number 2 of the Result Matrix is the averaged intensity values
% zoom on;
% xlabel('Intensity Values');
% ylabel('Counts');
% The one above is making the Intensity value histogram for ALL the selected spots in
% all the .traces file. By looking at this one, you can design on the most
% optimum intensity range i.e. the lower and the upper limit and input it
% below.
% LowerIntensity_cutoff=str2num(input('Enter the value for lower cutoff intensity: ','s'));
% UpperIntensity_cutoff=str2num(input('Enter the value for upper cutoff intensity: ','s'));

%Selecting FRET values solely based on the intensity range input below.
%Only the values that fall within the range will be selected.
Intensity=Result((Result(:,2)>0) & (Result(:,2)<2000),2);
Indexes_of_Cases_That_Fall_WithInTheIntensityRange=(Result(:,2)>LowerIntensity_cutoff) & (Result(:,2)<UpperIntensity_cutoff);
Result=Result(Indexes_of_Cases_That_Fall_WithInTheIntensityRange,:);
NumberofSingleMolecules_That_Fall_WithInTheIntensityRange=numel(Result)/5;
disp(NumberofSingleMolecules_That_Fall_WithInTheIntensityRange/20);
%Making the same things as above but now we have refined everything based
%on the cut offs.
Series=-0.2:0.02:1.2;
hist(Result(:,1),Series)
[X,Y]=hist(Result(:,1),Series);  %Here I am interested in getting the distribution values at specific points of FRET efficiency i.e from -0.2 to 1.0
close all;
hist(Result(:,1),Series)
xlabel('FRET Efficiency States');
ylabel('Counts');
FilenameForTheHistogram_Saving=sprintf('Histogram_LowerIntenCut_%d_HigherIntenCut_%d.png',LowerIntensity_cutoff,UpperIntensity_cutoff);
print(FilenameForTheHistogram_Saving,'-dpng','-r600');
FRETresultFor=[Y' X'];  % We will save this matrix later on
%What this matrix is simply the FRET values in one column and number of
%events that fall with in the range of this FRET value. You can use this to
%plot histogram in Origin or other programs
FRETresultForNormalized=[Y' X'./(sum(X))];  % We will save this later on
disp(sum(FRETresultForNormalized(42:end,:))); %FRET>0.6
%disp(sum(FRETresultForNormalized(22:end,:))); %FRET>0.2
% This matrix is doing the same thing as above but it is normalizing the
% counts.
save('FRETresultForPlotting_FromTraces.txt','FRETresultFor','-ascii');  % Just saving the FRET distribution into a .dat which can be later exported into origin and all for plotting purposes
save('NormalizedFRETresultForPlotting_FromTraces.txt','FRETresultForNormalized','-ascii');  % Saving the same FRET distribution but this time in normalized format so as to plot a normalized FRET distribution in origin or something later on
hist(Intensity,0:25:2000)
xlabel('Intensity');
ylabel('Counts');
print('Intensity_Plot','-dpng','-r600');
[M,N]=hist(Intensity,0:25:2000);
Nomalized_Intensity_Plot=[N',M'./sum(M)];
save('Nomalized_Intensity_Plot.txt','Nomalized_Intensity_Plot','-ascii');
end