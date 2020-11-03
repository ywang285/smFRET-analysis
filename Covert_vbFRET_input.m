%This script will delete time column for vbFRET input.

clear all
files = dir('*.dat') ;  

files = {files.name}';  
close all;
for i=1:numel(files)
   Contents_of_TheFile=textread(files{i});
   if isempty(Contents_of_TheFile) ==0
   DonorIntensityValue=Contents_of_TheFile(:,2);
   AcceptorIntensityValue=Contents_of_TheFile(:,3);
   vbFRET_input=[DonorIntensityValue,AcceptorIntensityValue];
   close all;
   TruncatedFileName_temp=files{i};
   TruncatedFileName=TruncatedFileName_temp(1:end-4);
   filenamez=sprintf('%s_vbFRETinput.dat',TruncatedFileName);
   save(filenamez,'vbFRET_input','-ascii') ;
   end
end
%zip('Pseudo HaMMY States for Step Detection in Images','*.jpg');
%delete('*.jpg');