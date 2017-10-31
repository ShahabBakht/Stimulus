
% This function estimates the contrast response function by testing the
% subject at multiple contrasts of drifting gabor stimuli. It needs to set
% the contrast enquiries, size of the stimulus, and duration.

function ContrastResponseRhythmStimulusFile()

% Clear the workspace and the screen
sca;
close all;
clearvars;

%--------- drifiting grating parameters -----------------------------------------

FolderName              = '/Users/shahab/MNI/Data/Psychophysics/Motion Discrimination/';
TestName                = inputdlg('Test Name');

distance2Screen         = 57; % in cm
stimulusSize            = 5; % in degree
stimulusContrasts       = [0.055];%[0.22,0.46,0.92];%[.014, 0.028, 0.055, 0.11, 0.22];%[0.028, 0.055, 0.11, 0.22, 0.46];%
stimulusCenter          = [5,-5]; % [x,y] in degrees
spatialFreq             = 1; % cycle per degree
speed                   = 2; % degree per second
CRTmonitor              = true;
numTrials               = 100;%50;%40;% % trials per condition
dummymode               = 1;       % set to 1 to initialize EyeLink in dummymod
gamepadUse              = true;
numFrames               = 5;
orientation             = 0;
aspectRatio             = 1.0;
phase                   = 0;

%--------------------------------------------------------------------------

allConditions = repmat(stimulusContrasts,1,numTrials);
trialsOrder = randperm(length(allConditions));

% save stimulus parameters in a variable
parameters.distance2Screen = distance2Screen;
parameters.stimulusSize = stimulusSize;
parameters.stimulusContrasts = stimulusContrasts;
parameters.stimulusCenter = stimulusCenter;
parameters.spatialFreq = spatialFreq;
parameters.speed = speed;
parameters.CRTmonitor = CRTmonitor;
parameters.numTrials = numTrials;
parameters.gamepadUse = gamepadUse;
parameters.numFrames = numFrames;
parameters.orientation = orientation;
parameters.aspectRatio = aspectRatio;
parameters.phase = phase;



% Setup PTB with some default values
PsychDefaultSetup(2);
ListenChar(2);
% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));
screenNumber2 = [];
if length(Screen('Screens')) > 1
    screenNumber2 = min(Screen('Screens'));
end

[width, height]=Screen('DisplaySize', screenNumber);
if CRTmonitor
    width = 360;
    height = 300;
end

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);


Screen('Preference', 'SkipSyncTests', 0);

try
    if gamepadUse
        numGamepads = Gamepad('GetNumGamepads');
        if numGamepads == 0
            error('No Gamepad connected');
        end
    end
    % Open the screen
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
        [], [],  kPsychNeed32BPCFloat);
    if ~isempty(screenNumber2)
        [window2, windowRect2] = PsychImaging('OpenWindow', screenNumber2, black, [], 32, 2,...
        [], [],  kPsychNeed32BPCFloat);
    end
    
%     Uncomment these parts for eyelink
    el=EyelinkInitDefaults(window);
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % open file for recording data
    edfFile = 'demo.edf';
    Eyelink('Openfile', edfFile);
    EyelinkDoTrackerSetup(el);

    % Calculate pixel per degree
    PPcm = windowRect(3)/(width/10);
    widthDegree = 2 * atan((width/20)/distance2Screen) * 180/pi;
    heightDegree = 2 * atan((height/20)/distance2Screen) * 180/pi;
    cmPD_w = (width/10) / widthDegree;
    cmPD_h = (height/10) / heightDegree;
    PPD_w = PPcm * cmPD_w;
    PPD_h = PPcm * cmPD_h;
    ppd = min(PPD_w,PPD_h);
    
    
    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);
    
    %--------------------
    % Gabor information
    %--------------------
    
    
    
    % Sigma of Gaussian
    sigma = (stimulusSize/2) * ppd;%(stimulusSize/1) * min(PPD_w,PPD_h);%
    
    % Dimension of the region where will draw the Gabor in pixels
    gaborDimPix = ceil(2 * sigma);%windowRect(4) / 2;
    
    % Drift speed for the 2D global motion
    degPerSec = 360 * speed;
    degPerFrame =  degPerSec * ifi;
    % Spatial Frequency (Cycles Per Pixel)
    % One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe

    freq = spatialFreq * 1/ppd;
    
    topPriorityLevel = MaxPriority(window);
    
    % Build a procedural gabor texture (Note: to get a "standard" Gabor patch
    % we set a grey background offset, disable normalisation, and set a
    % pre-contrast multiplier of 0.5.
    % For full details see:
    % https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/topics/9174
    backgroundOffset = [0.5 0.5 0.5 0.0];
    disableNorm = 1;%;
    preContrastMultiplier = .5;%1;%0.5;
    [gabortex,gaborrect] = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
        backgroundOffset, disableNorm, preContrastMultiplier);
    
    
    % center of the stimulus
    [xCenter, yCenter] = RectCenter(windowRect);
    stimulusRect = OffsetRect(gaborrect,xCenter + stimulusCenter(1) * PPD_w - stimulusSize * ppd/2,yCenter + stimulusCenter(2) * PPD_w - stimulusSize * ppd/2);
    
    %------------------------------------------
    %    Draw stuff - button press to exit
    %------------------------------------------
    
    % Draw the Gabor. By default PTB will draw this in the center of the screen
    % for us.
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    fixColor = [255 255 255];
    allCondTrialCount = zeros(length(stimulusContrasts),1);
    
    for trcount = 1:(length(stimulusContrasts) * numTrials)
        thisContrast = allConditions(trialsOrder(trcount));
        [~,whichCond] = find(stimulusContrasts == thisContrast);
        allCondTrialCount(whichCond) = allCondTrialCount(whichCond) + 1;
        contrast = thisContrast;
        phase = 0;
        % Set Gabor parameters.
        propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
        
        % initial fixation
        Eyelink('StartRecording');
        WaitSecs(0.5);
        [xCenter, yCenter] = RectCenter(windowRect);
        Screen('DrawDots', window, [xCenter, yCenter], 20, white);
        vbl = Screen('Flip',window);
        
        % wait for the key press to start the trial (keyboard or gamepad)
        if ~gamepadUse
            KbWait;
        else
            gamepadnotpressed = true;
            while gamepadnotpressed
                buttonState = Gamepad('GetButton', 1, 1);
                if buttonState
                    gamepadnotpressed = false;
                end
            end
        end
        Eyelink('Message', 'SYNCTIME');
        Screen('FillRect',window,grey);
        Screen('DrawDots', window, [xCenter, yCenter], 20, [1 1 1]);
        Screen('DrawDots', window, [xCenter, yCenter], 10, [0.5 0.5 0.5]);
        vbl = Screen('Flip',window);
        whichDelay(trcount) = randi(10);
        ThispostButtonPress = (whichDelay(trcount) - 1) * 100 + 50;
        WaitSecs(ThispostButtonPress/1000);%0.5
       
        
        DIR(trcount) = sign(rand - 0.5);
        if isempty(numFrames)
            numFrames = round(duration / (1000 * ifi));
        end
        waitframes = 1;
        
        
        Priority(topPriorityLevel);
        
        for frame = 1:numFrames
            
            Screen('DrawTextures', window, gabortex, [], stimulusRect, orientation, 0, [], [], [],...
                kPsychDontDoRotation, propertiesMat');
            Screen('DrawingFinished', window);
            
            % Flip to the screen
            vblold = vbl;
            [vbl, ~, ~, Missed(frame,trcount)] = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            IFI(frame,trcount) = vbl - vblold;
            
            % Increment the phase of our Gabors
            phase = phase +  DIR(trcount) * degPerFrame;%
            propertiesMat(:, 1) = phase';
            
        end
        
        
        Eyelink('Message', 'ENDTIME');
        vbl = Screen('Flip', window);
        
        % wait for the response (on gamepad or keyboard)
        if ~gamepadUse
            [secs,KeyCode,deltaSecs] = KbWait;
            if KeyCode(leftKey)
                Response(trcount) = 1;
            elseif KeyCode(rightKey)
                Response(trcount) = -1;
                
            end
            
        else
            gamepadnotpressed = true;
            while gamepadnotpressed
                buttonStateLeft = Gamepad('GetButton', 1, 5);
                buttonStateRight = Gamepad('GetButton', 1, 6);
                responseSate = buttonStateLeft || buttonStateRight;
                if responseSate
                    gamepadnotpressed = false;
                    if buttonStateLeft
                        Response(trcount) = 1;
                    else
                        Response(trcount) = -1;
                    end
                end
            end
        end
        
        
        if (Response(trcount) == DIR(trcount))
            responseTrueFalse(whichCond,allCondTrialCount(whichCond)) = 1;
            fixColor = [0 255 0];
        else
            responseTrueFalse(whichCond,allCondTrialCount(whichCond)) = 0;
            fixColor = [255 0 0];
        end
        Screen('DrawDots', window, [xCenter, yCenter], 20, fixColor);
        Screen('Flip',window);
        Eyelink('StopRecording');
        
        WaitSecs(0.2);
        
    end
    Priority(0);
catch ME
    sca;
    rethrow(ME);
end
% Clear screen
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
    

Eyelink('Shutdown');
ListenChar(0);

sca;

Result.responseTrueFalse = responseTrueFalse;
Result.InterFrames = IFI;
Result.parameters = parameters;
Result.whichDelay = whichDelay;

% movefile('demo.edf',[TestName{1},'.edf']);

save([FolderName,TestName{1}],'Result');
end