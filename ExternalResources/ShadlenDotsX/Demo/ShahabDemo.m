screenInfo = openExperiment(38,50,0);  
% targets = setNumTargets(6);
dotInfo = createDotInfo;
dotIndo.numDotField = 1;
targets = newTargets(screenInfo,targets,[2,4,6],[],[0,-15,15],[],[]); 
[frames,rseed,start_time,end_time,response,response_time] = ...
        dotsX(screenInfo,dotInfo);
% pause(1);
closeExperiment; %