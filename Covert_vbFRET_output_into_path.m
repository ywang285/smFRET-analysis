clear all
close all

load('vbFRETautosave_D082620_T1355.mat');
for n=1:length(session_settings.dat.labels)

pathcontent=[(1:length(session_settings.dat.raw{n}))',session_settings.dat.raw{n},...
    session_settings.dat.FRET{n},session_settings.dat.x_hat{1,n}];
pathfilename=strcat(session_settings.dat.labels{n},'_path.dat');
save(pathfilename,'pathcontent','-ascii') ;
end