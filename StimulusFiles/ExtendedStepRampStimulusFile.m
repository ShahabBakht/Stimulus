function ExtendedStepRampStimulusFile(S)

% set the parameters
NumTrials       =   S.NumTrials;         % Number of trials per condition
% PPD_X           =   S.PPD_X;             % Pixels per degree
% PPD_Y           =   S.PPD_Y;
FixationTimeMin =   S.FixationTimeMin;
FixationTimeMax =   S.FixationTimeMax;
GapTime         =   S.GapTime;
TRIAL_TIMER     =   S.TRIAL_TIMER;       % (ms)
SaveFolder      =   S.SaveFolder;
diameter        =   S.TargetSize;
type            =   S.type;
NumConditions   =   S.NumConditions;
conditions      =   S.conditions;

trials = nan(6,NumConditions*NumTrials);
for condcount = 1:NumConditions
    trials(:,((condcount-1)*NumTrials + 1):condcount*NumTrials) = repmat(conditions(:,condcount),1,NumTrials);
end

S.trials = trials;

% set the eyelink file

if ~IsOctave
    commandwindow;
else
    more off;
end



dummymode = 0;


%%%%%%%%%%
% STEP 1 %
%%%%%%%%%%

% Added a dialog box to set your own EDF file name before opening
% experiment graphics. Make sure the entered EDF file name is 1 to 8
% characters in length and only numbers or letters are allowed.

if IsOctave
    edfFile = 'DEMO';
else
    prompt = {'Enter tracker EDF file name (1 to 8 letters or numbers)'};
    dlg_title = 'Create EDF file';
    num_lines= 1;
    def     = {'DEMO'};
    answer  = inputdlg(prompt,dlg_title,num_lines,def);
    edfFile = answer{1};
    fprintf('EDFFile: %s\n', edfFile );
end

% open the experiment screen
screenInfo = openExperiment(90,57,0);
window = screenInfo.curWindow;
Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
[winWidth, winHeight] = WindowSize(window);

% set up the Eyelink
el = SetupEyeLink(S,window,edfFile);

% start the main experiment
order = randperm(NumTrials * NumConditions);
S.order = order;

[keyPress, keyTime, keyID] = KbCheck(-1);
oldKeyID = keyID;


NumIterations = NumTrials * NumConditions;

for i = 1 : (NumIterations)
    
    [keyPress, keyTime, keyID] = KbCheck(-1);
    if any(keyID-oldKeyID)
        keyPressID = keyID;
        oldKeyID = keyID;
    else
        keyPressID = zeros(size(keyID));
    end
    % determine current trial type and send msg to edf
    if keyPressID(KbName('q'))
        break
    end
    
    center_x = winWidth/2;
    center_y = winHeight/2;
    amplitudeX = winWidth/4;
    amplitudeY = winHeight/4;
    perm = trials(:,order(i));
    
    Eyelink('Command', 'set_idle_mode');
    Eyelink('Command', 'clear_screen %d', 0);
    
    % calculate locations of target peripheries so that we can draw
    % matching lines and boxes on host pc
    dots(2,1) = winHeight/2;
    dots(1,1) = winWidth/2;
    
    %% Generating the Path
    
    t = 0;
    Angle = perm(1);
    velocity = perm(2) * 10;
    amplitude = perm(3) * 10;
    velocityX = velocity * cos(Angle);
    velocityY = velocity * sin(Angle);
    XInitialPosition = perm(4) * 10;
    YInitialPosition = perm(5) * 10;
    Contrast = perm(6) / 100;
    
    if velocityX > 0
        FixationPositionX = 0;
    else
        FixationPositionX = 0;
    end
    FixationPositionY = 0;
    
    x = (velocityX * t) + XInitialPosition;

    y = (velocityY * t) + YInitialPosition;
    
    if ((velocityX * t)^2 + (velocityY * t)^2) > amplitude^2
        StopFlag = true;
    else
        StopFlag = false;
    end
    
    
    %%
    ball([1 3]) = [x-10 x+10];
    ball([2 4]) =  [y-10 y+10];
    
    
    WaitSecs(0.1);
    EyelinkDoDriftCorrection(el);
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);
    Eyelink('StartRecording');
    WaitSecs(0.1);
    eye_used = Eyelink('EyeAvailable');
    
    fixationTime = ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);

    targets = setNumTargets(2);
    targets = newTargets(screenInfo,targets,[1,2],[x, FixationPositionX],[y, FixationPositionY],[diameter,diameter/3],round([Contrast*[255 0 0];255 0 0]));
    showTargets(screenInfo, targets, [1,2]);
    WaitSecs(fixationTime);
%     fixationTime = ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);
%     showTargets(screenInfo, targets, [1,2]);
%     WaitSecs(fixationTime);

    
    trialTime = GetSecs + TRIAL_TIMER/1000;
    sttime = GetSecs;
    resetInit = true;
    while GetSecs < trialTime
        
        Eyelink('Message', 'SYNCTIME');
        
        t = GetSecs - sttime;
        x = (velocityX * t) + XInitialPosition;
        y = (velocityY * t) + YInitialPosition;
        
        if ((velocityX * t)^2 + (velocityY * t)^2) > amplitude^2
            StopFlag = true;
        else
            StopFlag = false;
        end
        
        if StopFlag
            break
        end
        targets = newTargets(screenInfo,targets,[1,2],[x, FixationPositionX],[y, FixationPositionY],[diameter,diameter/3],round([Contrast*[255 0 0];255 0 0]));
        showTargets(screenInfo, targets, [1,2]);
        
        ball([1 3]) = [x-10 x+10];
        ball([2 4]) = [y-10 y+10];
    end
    
    fixationTime = ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);
    showTargets(screenInfo, targets, [1]);
    WaitSecs(fixationTime);
    
    WaitSecs(0.1);
    Eyelink('StopRecording');
    Screen('FillRect', window, el.backgroundcolour);
%     Screen('FillRect', window, [0 0 0]);
    Screen('Flip', window);
    
    
    gapTime = GetSecs + GapTime/1000;
    while GetSecs < gapTime
        
        Screen('FillRect', window, el.backgroundcolour);
% Screen('FillRect', window, [0 0 0]);
        Screen('Flip', window);
        
    end
end
    


%%%%%%%%%%
% STEP 8 %
%%%%%%%%%%

% End of Experiment; close the file first
% close graphics window, close data file and shut down tracker
Eyelink('Command', 'set_idle_mode');
WaitSecs(0.5);
Eyelink('CloseFile');

try
    fprintf('Receiving data file ''%s''\n', edfFile );
    status=Eyelink('ReceiveFile');
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
    end
catch %#ok<*CTCH>
    fprintf('Problem receiving data file ''%s''\n', edfFile );
end





%% Save the Stimulus Object

save([SaveFolder, '\', edfFile, '.mat'],'S');



end