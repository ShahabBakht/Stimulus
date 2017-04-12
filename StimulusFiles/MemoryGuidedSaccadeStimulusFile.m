function MemoryGuidedSaccadeStimulusFile


TargetAmplitudes    =   [2, 4, 6, 8, 10];   % in degree 
TargetAngles        =   [0, pi];            % in rad
FixationPoint       =   'centeric';         % centeric or eccentric
FixationTimeMin     =   0.5;                % in second
FixationTimeMax     =   1.5;                % in second
endFixationTime     =   1;                  % in second
delayTime           =   3;                  % in second
targetTime          =   0.2;                % in second
testTime            =   0.75;               % in second
jitterAmp           =   1;                  % in degree
jitterAngle         =   0;                  % in degree 
FixationSize        =   1;                % in degree
Targetsize          =   1;                % in degree
numTrials           =   1;                 % per condition 
types               =   {'saccade'};        % 'saccade', 'click', 'match'
PPDx                =   15;
PPDy                =   15;


numConditions = length(TargetAmplitudes) * length(TargetAngles);
[TargetAmplitudesRep,TargetAnglesRep] = meshgrid(TargetAmplitudes,TargetAngles);
TargetAmplitudesRep = reshape(TargetAmplitudesRep,numConditions,1);
TargetAnglesRep = reshape(TargetAnglesRep,1,numConditions);
for condcount = 1:numConditions
    conditions(1,condcount) = TargetAmplitudesRep(condcount);
    conditions(2,condcount) = TargetAnglesRep(condcount);
end

trials = [];
for condcount = 1:numConditions
    %     trials(:,((condcount-1)*numTrials + 1):numTrials(condcount)) = repmat(conditions(:,condcount),1,numTrials(condcount));
    trials = [trials,repmat(conditions(:,condcount),1,numTrials)];
end
trialorder = randperm(size(trials,2));

screenNumber=max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

ListenChar(2);

% try
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [winWidth, winHeight] = WindowSize(window);
    [FixationLocationOuter,FixationLocationMiddle,FixationLocationInner] = makebulleye();
%     FixationLocation = [winWidth/2 - (FixationSize*PPDx)./2, winHeight/2 - (FixationSize*PPDx)./2, ...
%         winWidth/2 + (FixationSize*PPDx)./2, winHeight/2 + (FixationSize*PPDx)./2];
    
    for trcount = 1:size(trials,2)
        thisTrialIdx = trialorder(trcount);
        thisTargetAmp = trials(1,thisTrialIdx) + (jitterAmp * rand - jitterAmp/2);
        thisTargetAngle = trials(2,thisTrialIdx) + (jitterAngle * rand - jitterAngle/2);
        thisTargetCenterH = winWidth/2 + cos( thisTargetAngle ) * thisTargetAmp *PPDx;
        thisTargetCenterV = winHeight/2 + sin( thisTargetAngle ) * thisTargetAmp *PPDy;
        thisTargetLocation = [thisTargetCenterH  - (Targetsize*PPDx)./2, thisTargetCenterV - (Targetsize*PPDx)./2, ...
            thisTargetCenterH + (Targetsize*PPDx)./2, thisTargetCenterV + (Targetsize*PPDx)./2];
        
        thisFixationTime = ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);
        
        
        Screen('FillOval',window,[255 255 255],FixationLocationOuter);
        Screen('FillOval',window,[0 0 0],FixationLocationMiddle);
        Screen('FillOval',window,[255 255 255],FixationLocationInner);       
        Screen('Flip', window);
        WaitSecs(thisFixationTime);
        
        Screen('FillOval',window,[255 255 255],FixationLocationOuter);
        Screen('FillOval',window,[0 0 0],FixationLocationMiddle);
        Screen('FillOval',window,[255 255 255],FixationLocationInner);       
        Screen('FillOval',window,[255 255 255],thisTargetLocation);
        Screen('Flip', window);
        WaitSecs(targetTime);
        
        
        Screen('FillOval',window,[255 255 255],FixationLocationOuter);
        Screen('FillOval',window,[0 0 0],FixationLocationMiddle);
        Screen('FillOval',window,[255 255 255],FixationLocationInner);       
        Screen('Flip', window);
        WaitSecs(delayTime);
        
        
        Screen('FillRect',window,black,windowRect);
        Screen('Flip', window);
        WaitSecs(testTime);
        
        Screen('FillOval',window,[255 255 255],FixationLocationOuter);
        Screen('FillOval',window,[0 0 0],FixationLocationMiddle);
        Screen('FillOval',window,[255 255 255],FixationLocationInner);       
        Screen('Flip', window);
        WaitSecs(endFixationTime);
        
    end
% catch
%     cleanup;
% end

ListenChar(0);
cleanup;


    function cleanup
        % Shutdown Eyelink:
        % Eyelink('Shutdown');
        Screen('CloseAll');
    end

    function [FixationLocationOuter,FixationLocationMiddle,FixationLocationInner] = makebulleye()
        FixationLocationOuter = [winWidth/2 - (FixationSize*PPDx)./2, winHeight/2 - (FixationSize*PPDx)./2, ...
            winWidth/2 + (FixationSize*PPDx)./2, winHeight/2 + (FixationSize*PPDx)./2];
        
        FixationLocationMiddle = [winWidth/2 - ((FixationSize - 0.3)*PPDx)./2, winHeight/2 - ((FixationSize - 0.3)*PPDx)./2, ...
            winWidth/2 + ((FixationSize - 0.3)*PPDx)./2, winHeight/2 + ((FixationSize - 0.3)*PPDx)./2];
        
        FixationLocationInner = [winWidth/2 - ((FixationSize - 0.7)*PPDx)./2, winHeight/2 - ((FixationSize - 0.7)*PPDx)./2, ...
            winWidth/2 + ((FixationSize - 0.7)*PPDx)./2, winHeight/2 + ((FixationSize - 0.7)*PPDx)./2];
    
    
        
    end
end