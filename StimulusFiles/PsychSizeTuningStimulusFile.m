% This function reconstructs the psychophysical surround suppression with
% drifting gratings. It needs the duration, to-be-tested stimulus sizes,
% and contrast.

function PsychSizeTuningStimulusFile()

% Clear the workspace and the screen
sca;
close all;
clearvars;

%--------- random dots parameters

FolderName          = '/Users/shahab/MNI/Data/Psychophysics/Motion Discrimination/';
TestName            = inputdlg('Test Name');
distance2Screen     = 57; % in cm
stimulusSizes       = 1:2:15; % in degree
numTrials           = 20; % trials per condition
CRTmonitor          = true;
gamepadUse          = true;
speed               = 2; % degree per second
spatialFreq         = 1; % cycle per degree
stimulusCenter      = [5,-5];
dummymode           = 1;       % set to 1 to initialize EyeLink in dummymod
numFrames           = 3;
orientation         = 0;
contrast            = 0.92;
aspectRatio         = 1.0;

%---------------------------------------------------------------------
allConditions = repmat(stimulusSizes,1,numTrials);
trialsOrder = randperm(length(allConditions));

% Setup PTB with some default values
PsychDefaultSetup(2);

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

if gamepadUse
    numGamepads = Gamepad('GetNumGamepads');
    if numGamepads == 0
        error('No Gamepad connected');
    end
end

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

ListenChar(2);

% Skip sync tests for demo purposes only
% Screen('Preference', 'SkipSyncTests', 2);
try
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);
if ~isempty(screenNumber2)
    [window2, windowRect2] = PsychImaging('OpenWindow', screenNumber2, black, [], 32, 2,...
        [], [],  kPsychNeed32BPCFloat);
end
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
EyelinkDoDriftCorrection(el);
% Calculate pixel per degree
PPcm = windowRect(3)/(width/10);
widthDegree = 2 * atan((width/20)/distance2Screen) * 180/pi;
heightDegree = 2 * atan((height/20)/distance2Screen) * 180/pi;
cmPD_w = (width/10) / widthDegree;
cmPD_h = (width/10) / heightDegree;
PPD_w = PPcm * cmPD_w;
PPD_h = PPcm * cmPD_h;
ppd = min(PPD_w,PPD_h);


% Query the frame duration
ifi = Screen('GetFlipInterval', window);

%--------------------
% Gabor information
%--------------------




% Obvious Parameters

phase = 0;
% duration = 45; % ms


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
disableNorm = 1;
preContrastMultiplier = .5;



% Drift speed for the 2D global motion
degPerSec = 360 * speed;
degPerFrame =  degPerSec * ifi;

%------------------------------------------
%    Draw stuff - button press to exit
%------------------------------------------

% Draw the Gabor. By default PTB will draw this in the center of the screen
% for us.
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
fixColor = [255 255 255];
allCondTrialCount = zeros(length(stimulusSizes),1);
tic;
for trcount = 1:(length(stimulusSizes) * numTrials)
    thisSize = allConditions(trialsOrder(trcount));
    [~,whichCond] = find(stimulusSizes == thisSize);
    allCondTrialCount(whichCond) = allCondTrialCount(whichCond) + 1;
    % Sigma of Gaussian
    sigma = (thisSize/2) * ppd;
    % Dimension of the region where will draw the Gabor in pixels
    gaborDimPix = ceil(2 * sigma);%windowRect(4) / 2;
    phase = 0;
    % Set Gabor parameters.
    propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
    [gabortex,gaborrect] = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
        backgroundOffset, disableNorm, preContrastMultiplier);
    
    % center of the stimulus
    [xCenter, yCenter] = RectCenter(windowRect);
%     stimulusRect = OffsetRect(gaborrect,stimulusCenter(1) * PPD_w + windowRect(3)/2,stimulusCenter(2) * PPD_h + windowRect(4)/2)
    stimulusRect = OffsetRect(gaborrect,xCenter + stimulusCenter(1) * PPD_w - thisSize * ppd/2,yCenter + stimulusCenter(2) * PPD_w - thisSize * ppd/2);
    
    Eyelink('StartRecording');
    WaitSecs(0.5);
    % initial fixation
    [xCenter, yCenter] = RectCenter(windowRect);
    Screen('DrawDots', window, [xCenter, yCenter], 20, white);
    vbl = Screen('Flip',window);
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
    Screen('DrawDots', window, [xCenter, yCenter], 10, [0.5 0.5 0.5])
    vbl = Screen('Flip',window);
    WaitSecs(.5);%0.5
    
    DIR(trcount) = sign(rand - 0.5);
    
    waitframes = 1;
    % Time0 = GetSecs;
    % while GetSecs < Time0 + duration/1000
    Priority(topPriorityLevel);
    
    for frame = 1:numFrames
        Screen('DrawTextures', window, gabortex, [], stimulusRect, orientation, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat');
        
        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        % Increment the phase of our Gabors
        phase = phase +  DIR(trcount) * degPerFrame;%
        propertiesMat(:, 1) = phase';
        
    end
    Priority(0);
    Eyelink('Message', 'ENDTIME');

vbl = Screen('Flip', window);

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
    fixColor = [0 0 255];
else
    responseTrueFalse(whichCond,allCondTrialCount(whichCond)) = 0;
    fixColor = [0 0 255];
end
Screen('DrawDots', window, [xCenter, yCenter], 20, fixColor);
Screen('Flip',window);
Eyelink('StopRecording');
WaitSecs(.2);

end
toc;

catch ME
    sca;
    rethrow(ME);
end

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

WaitSecs(2);
% Clear screen
sca;


Result.responseTrueFalse = responseTrueFalse;
% movefile('demo.edf',[TestName{1},'.edf']);

save([FolderName,TestName{1}],'Result');
ListenChar(0);
end