% This function reconstructs the psychophysical surround suppression with
% drifting gratings. It needs the duration, to-be-tested stimulus sizes,
% and contrast.

function PsychSizeTuningStimulusFile()

% Clear the workspace and the screen
sca;
close all;
clearvars;
FolderName = 'D:\Data\Psychophysics\Motion Discrimination\';
TestName = inputdlg('Test Name');
distance2Screen = 60; % in cm
stimulusSizes = 1:2:11; % in degree
numTrials = 40; % trials per condition
allConditions = repmat(stimulusSizes,1,numTrials);
trialsOrder = randperm(length(allConditions));

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
% Screen('Preference', 'SkipSyncTests', 2);

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


% Obvious Parameters
orientation = 0;
contrast = 0.92;
aspectRatio = 1.0;
phase = 0;
duration = 32; % ms

% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles = 10;%5;%40;
freq = numCycles / gaborDimPix;

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


% Drift speed for the 2D global motion
degPerSec = 360 * 2;
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
    sigma = (thisSize/2) * min(PPD_w,PPD_h);
    
    % Set Gabor parameters.
    propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];

    % initial fixation
    [xCenter, yCenter] = RectCenter(windowRect);
    Screen('DrawDots', window, [xCenter, yCenter], 20, white);
    Screen('Flip',window);
    KbWait;
    WaitSecs(0.5);
    
    DIR(trcount) = sign(rand - 0.5);
    
Time0 = GetSecs;
while GetSecs < Time0 + duration/1000
    Screen('DrawTextures', window, gabortex, [], [], orientation, [], [], [], [],...
        kPsychDontDoRotation, propertiesMat');
    
    % Flip to the screen
    Screen('Flip', window);
    
    % Increment the phase of our Gabors
    phase = phase +  DIR(trcount) * degPerFrame;%
    propertiesMat(:, 1) = phase';
    
end

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
toc;
% Clear screen
sca;


Result.responseTrueFalse = responseTrueFalse;

save([FolderName,TestName{1}],'Result');

end