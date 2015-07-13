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
    RandomDraw = randn;
    if RandomDraw > 0
        1
        setdir = 0;
        stepsize = -20;
    elseif RandomDraw <= 0
        0
        setdir = 180;
        stepsize = 20;
    end
    
    dotInfo.apXYD = [stepsize 0 40];
    dotInfo.speed = [0];
    dotInfo.cohSet = [0];
    dotInfo.dir = [setdir];
    dotInfo.maxDotTime = [1];
    
    dotInfo.trialtype = [2 1];
    dotInfo.dotColor = [255 255 255]; % default white dots
    dotInfo.dotSize = 2;
    [frames, rseed, start_time, end_time, response, response_time] = ...
        dotsX(screenInfo, dotInfo,targets); 
    
    
    pause(0)
    dotInfo.initTime = 0;
    dotInfo.speed = [10];
    dotInfo.cohSet = [.05];
    
    dotInfo.dir = [setdir];
    dotInfo.maxDotTime = [1];
    
    
    dotInfo.apXYD = [stepsize 0 40];
    dotInfo.trialtype = [2, 1];
    dotInfo.isMovingCenter = true;
    [frames, rseed, start_time, end_time, response, response_time] = ...
        dotsX(screenInfo, dotInfo,targets );
 pause(1)
clear RandomDraw
    end
    % Clear the screen and exit
   
    closeExperiment;
    
catch
    disp('caught error');
    lasterr
    closeExperiment;
    
end;


