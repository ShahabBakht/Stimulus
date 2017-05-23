% This function estimates the contrast response function by testing the
% subject at multiple contrasts of drifting gabor stimuli. It needs to set
% the contrast enquiries, size of the stimulus, and duration.

function PsychContrastResponseStimulusFile()

% Clear the workspace and the screen
sca;
close all;
clearvars;
FolderName = 'D:\Data\Psychophysics\Motion Discrimination\';
TestName = inputdlg('Test Name');
distance2Screen = 60; % in cm
stimulusSize = 3; % in degree
stimulusContrasts = [0.028, 0.055, 0.11, 0.22, 0.46, 0.92];
numTrials = 40; % trials per condition
allConditions = repmat(stimulusContrasts,1,numTrials);
trialsOrder = randperm(length(allConditions));

% Obvious Parameters
orientation = 0;
aspectRatio = 1.0;
phase = 0;
duration = 170; % ms





% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));
[width, height]=Screen('DisplaySize', screenNumber);

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;



% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 0);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

% Calculate pixel per degree
PPcm = windowRect(3)/(width/10);
widthDegree = 2 * atan((width/20)/distance2Screen) * 180/pi;
heightDegree = 2 * atan((height/20)/distance2Screen) * 180/pi;
cmPD_w = (width/10) / widthDegree;
cmPD_h = (width/10) / heightDegree;
PPD_w = PPcm / cmPD_w;
PPD_h = PPcm / cmPD_h;

% Query the frame duration
ifi = Screen('GetFlipInterval', window);


%--------------------
% Gabor information
%--------------------

% Dimension of the region where will draw the Gabor in pixels
gaborDimPix = windowRect(4);%windowRect(4) / 2;

% Sigma of Gaussian
sigma = (stimulusSize/2) * min(PPD_w,PPD_h);


% Drift speed for the 2D global motion
degPerSec = 360 * 2;
degPerFrame =  degPerSec * ifi;
% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles = 10;%5;%40;
freq = numCycles / gaborDimPix;

topPriorityLevel = MaxPriority(window);

% Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% we set a grey background offset, disable normalisation, and set a
% pre-contrast multiplier of 0.5.
% For full details see:
% https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/topics/9174
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
preContrastMultiplier = 0.5;
gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
    backgroundOffset, disableNorm, preContrastMultiplier);



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
    % Set Gabor parameters.
    propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
    
    % initial fixation
    [xCenter, yCenter] = RectCenter(windowRect);
    Screen('DrawDots', window, [xCenter, yCenter], 20, white);
    vbl = Screen('Flip',window);
    KbWait;
    WaitSecs(0.5);
    
    DIR(trcount) = sign(rand - 0.5);
    numFrames = round(duration / (1000 * ifi));
    waitframes = 1;
    
%     Time0 = GetSecs;
%     while GetSecs < Time0 + duration/1000
    Priority(topPriorityLevel);
    
    for frame = 1:numFrames

        Screen('DrawTextures', window, gabortex, [], [], orientation, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat');
        Screen('DrawingFinished', window);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
       
        % Increment the phase of our Gabors
        phase = phase +  DIR(trcount) * degPerFrame;%
        propertiesMat(:, 1) = phase';
        
    end
    
    Priority(0);
    
    vbl = Screen('Flip', window);
    [secs,KeyCode,deltaSecs] = KbWait;
    if KeyCode(leftKey)
        Response(trcount) = 1;
    elseif KeyCode(rightKey)
        Response(trcount) = -1;
        
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
    WaitSecs(0.2);
    
end

% Clear screen
sca;


Result.responseTrueFalse = responseTrueFalse;

save([FolderName,TestName{1}],'Result');

end