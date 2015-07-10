% dotsOnlyDemo
%
% Simple script for testing dots (dotsX)
%

try
    clear;
    
    % Initialize the screen
    % touchscreen is 34, laptop is 32, viewsonic is 38
    screenInfo = openExperiment(32,50,0);
    
    % Initialize dots
    % Check createMinDotInfo to change parameters
    for tr = 1:10
            targets = setNumTargets(1); % initialize targets        

        targets = newTargets(screenInfo,targets,[1],[0],[0],...
        [2],[0,255,255]);
    dotInfo = createDotInfo(1);
    dotInfo.numDotField = 1;
    % dotInfo.apXYD = [-50 0 50; 50 0 50];
    dotInfo.apXYD = [-20 0 40];
    dotInfo.speed = [0];
    dotInfo.cohSet = [0];
    dotInfo.dir = [0];
    dotInfo.maxDotTime = [1];
    
    dotInfo.trialtype = [2 1];
    dotInfo.dotColor = [255 255 255]; % default white dots
    dotInfo.dotSize = 2;
    [frames, rseed, start_time, end_time, response, response_time] = ...
        dotsX(screenInfo, dotInfo,targets); 
    
    
    pause(0)
    dotInfo.initTime = .125;
    dotInfo.speed = [5];
    dotInfo.cohSet = [.75];
    dotInfo.dir = [0];
    dotInfo.maxDotTime = [5];
    dotInfo.apXYD = [-20 0 40];
    
    dotInfo.isMovingCenter = true;
    [frames, rseed, start_time, end_time, response, response_time] = ...
        dotsX(screenInfo, dotInfo);
 pause(1)
    end
    % Clear the screen and exit
   
    closeExperiment;
    
catch
    disp('caught error');
    lasterr
    closeExperiment;
    
end;


