function AntiSaccadeStimulusFile


trialTime = 1; % in sec
samplingRate = 10; % in Hz (it takes 10 samples per one second)
samplingTimes = 0:(1/samplingRate):trialTime;
FixationSize = 1;
Targetsize = 1;
numTrials = 10;
trials = repmat(samplingTimes,1,numTrials);

targetLocationAmp = 10;
targetLocationAngle = [0,pi];
firstFixationAmp = 15;
firstFixationAngle = pi/2;
secondFixationAmp = 0;
secondFixationAngle = 0;
PPDx = 15;
PPDy = 15;

screenNumber=max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

ListenChar(2);


[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
[winWidth, winHeight] = WindowSize(window);

firstFixCenterH = winWidth/2 + cos( firstFixationAngle ) * firstFixationAmp *PPDx;
firstFixationCenterV = winHeight/2 + sin( firstFixationAngle ) * firstFixationAmp *PPDy;
firstFixationLocation = [firstFixCenterH  - (Targetsize*PPDx)./2, firstFixationCenterV - (Targetsize*PPDx)./2, ...
    firstFixCenterH + (Targetsize*PPDx)./2, firstFixationCenterV + (Targetsize*PPDx)./2];

secondFixCenterH = winWidth/2 + cos( secondFixationAngle ) * secondFixationAmp *PPDx;
secondFixationCenterV = winHeight/2 + sin( secondFixationAngle ) * secondFixationAmp *PPDy;
secondFixationLocation = [secondFixCenterH  - (Targetsize*PPDx)./2, secondFixationCenterV - (Targetsize*PPDx)./2, ...
    secondFixCenterH + (Targetsize*PPDx)./2, secondFixationCenterV + (Targetsize*PPDx)./2];


trialsorder = randperm(size(trials,2));

for trcount = 1:length(trialsorder);
    if rand>0.5
        thisTargetAngle = 0;
    else
        thisTargetAngle = pi;
    end
    
    thisTargetCenterH = winWidth/2 + cos( thisTargetAngle ) * targetLocationAmp *PPDx;
    thisTargetCenterV = winHeight/2 + sin( thisTargetAngle ) * targetLocationAmp *PPDy;
    thisTargetLocation = [thisTargetCenterH  - (Targetsize*PPDx)./2, thisTargetCenterV - (Targetsize*PPDx)./2, ...
        thisTargetCenterH + (Targetsize*PPDx)./2, thisTargetCenterV + (Targetsize*PPDx)./2];

    
    leftFix = false;
    
    
    while ~leftFix
        
        Screen('FillOval',window,[255 0 0],firstFixationLocation);
        Screen('FillOval',window,[0 255 0],secondFixationLocation);
        Screen('Flip', window);
        
        % online eye position tracker
        WaitSecs(2);
        leftFix = true;
    
    
    end
    
    Screen('FillOval',window,[0 255 0],secondFixationLocation);
    Screen('Flip', window);
    
    WaitSecs(trials(trialsorder(trcount)));
    
    Screen('FillOval',window,[0 255 0],thisTargetLocation);
    Screen('Flip', window);
    WaitSecs(2);
    
    Screen('FillRect',window,black,windowRect);
    Screen('Flip', window);
    WaitSecs(1);
    
end

ListenChar(0);
cleanup;


   

end

 function cleanup
 % Shutdown Eyelink:
 % Eyelink('Shutdown');
 Screen('CloseAll');
 end