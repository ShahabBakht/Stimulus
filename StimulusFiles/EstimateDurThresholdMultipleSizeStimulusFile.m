% This function estimates the duration threshold using QUEST method for
% drifting gabor stimuli with multiple stimulus sizes. It only needs the
% enquired stimulus sizes and the contrast.

function trial = EstimateDurThresholdMultipleSizeStimulusFile(qin)


% Clear the workspace and the screen
sca;
% close all;
% clearvars;
FolderName = '/Users/shahab/MNI/Data/Psychophysics/Motion Discrimination/';
TestName = inputdlg('Test Name');
distance2Screen = 60; % in cm
stimulusSizes = 1;%1:2:11; % in degree
numTrials = 100; % trials per condition
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

% Set up QUEST
% QUEST parameters
pThreshold              = 0.82;%0.82;
beta                    = 3.5;
delta                   = 0.01;
gamma                   = 0.5;
range                   = 5;
grain                   = 0.01;
plotIt                  = 0;

if nargin == 1
    tGuess = QuestQuantile(qin);
else
tGuess = 5.0;%7;
end
% while isempty(tGuess)
%     tGuess=input('Estimate threshold (e.g. -1): ');
% end
tGuessSd=20;
% while isempty(tGuessSd)
%     tGuessSd=input('Estimate the standard deviation of your guess, above, (e.g. 2): ');
% end
questObjects = cell(1,length(stimulusSizes));
for sizecount = 1:length(stimulusSizes)
    q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,grain,range,plotIt);
    q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
    questObjects{sizecount} = q;
end

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 0);

% Open the screen

try;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

% Calculate pixel per degree
PPcm = windowRect(3)/(width/10);
widthDegree = 2 * atan((width/20)/distance2Screen) * 180/pi;
heightDegree = 2 * atan((height/20)/distance2Screen) * 180/pi;
cmPD_w = (width/10) / widthDegree;
cmPD_h = (width/10) / heightDegree;
PPD_w = PPcm * cmPD_w;
PPD_h = PPcm * cmPD_h;

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

%--------------------
% Gabor information
%--------------------

% Dimension of the region where will draw the Gabor in pixels
gaborDimPix = windowRect(4) / 1;


% Obvious Parameters
orientation = 0;
contrast = 0.92;
aspectRatio = 1.0;
phase = 0;
% duration = 1000; % ms
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
preContrastMultiplier = 1;%0.5;
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
topPriorityLevel = MaxPriority(window);
for trcount = 1:(length(stimulusSizes) * numTrials)
    thisSize = allConditions(trialsOrder(trcount));
    [~,whichCond] = find(stimulusSizes == thisSize);
    
    % Sigma of Gaussian
    sigma = (thisSize/2) * min(PPD_w,PPD_h);
    
    % Set Gabor parameters.
    propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];

    % initial fixation
    [xCenter, yCenter] = RectCenter(windowRect);
    Screen('DrawDots', window, [xCenter, yCenter], 20, white);
    vbl = Screen('Flip',window);
    KbWait;
    Screen('FillRect',window,grey);
%     Screen('DrawTextures', window, gabortex, [], [], orientation, [], [], [], [],...
%         kPsychDontDoRotation, propertiesMat');
    vbl = Screen('Flip',window);
    WaitSecs(.10);
    
    % Get recommended level.  Choose your favorite algorithm.
	tTest=QuestMean(questObjects{whichCond});	% Recommended by Pelli (1987), and still our favorite.
% 	tTest=QuestMean(q);		% Recommended by King-Smith et al. (1994)
% 	tTest=QuestMode(q);		% Recommended by Watson & Pelli (1983)
	
	% We are free to test any intensity we like, not necessarily what Quest suggested.
% 		tTest=min(-0.05,max(-3,tTest)); % Restrict to range of log contrasts that our equipment can produce.
    %   tTest=min(-0.05,max(-3,tTest));
    duration(trcount) = 2^tTest;
    DIR(trcount) = sign(rand - 0.5);
    numFrames = round(duration(trcount) / (1000 * ifi));
    waitframes = 1;
    
% Time0 = GetSecs;
% while GetSecs < Time0 + duration(trcount)/1000
Priority(topPriorityLevel);
for frame = 1:numFrames
    Screen('DrawTextures', window, gabortex, [], [], orientation, [], [], [], [],...
        kPsychDontDoRotation, propertiesMat');
    
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
    responseForQUEST(trcount) = 1;
    fixColor = [0 255 0];
else
    responseForQUEST(trcount) = 0;
    fixColor = [255 0 0];
end
Screen('DrawDots', window, [xCenter, yCenter], 20, fixColor);
Screen('Flip',window);
WaitSecs(0.3);
qtemp=QuestUpdate(questObjects{whichCond},tTest,responseForQUEST(trcount));
questObjects{whichCond} = qtemp;
Result.QUESTObject = questObjects;
save([FolderName,TestName{1}],'Result');


end

catch
end
% Clear screen
sca;

qfinal = Result.QUESTObject{end};
trial=QuestTrials(qfinal);
plot(2.^qfinal.intensity(1:numTrials));hold on;
t=QuestQuantile(qfinal);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(qfinal);
fprintf('Final threshold estimate (mean+-sd) is %.2f +- %.2f\n',2^t,2^sd);

% Result.SubjectResponse = Response;
% Result.DriftDirection = DIR;
Result.QUESTObject = questObjects;
Result.trial = trial;
save([FolderName,TestName{1}],'Result');

end