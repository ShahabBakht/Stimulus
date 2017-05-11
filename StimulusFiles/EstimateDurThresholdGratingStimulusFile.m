function EstimateDurThresholdGratingStimulusFile()
% Clear the workspace and the screen
sca;
close all;
clearvars;
FolderName = 'C:\Users\Shahab\Documents\Shahab\Psychophysics Data\Motion Discrimination\';
TestName = inputdlg('Test Name');
PPD_X = 15;
PPD_Y = 15;
% Setup PTB with some default values
PsychDefaultSetup(2);

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

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

tGuess=[];
while isempty(tGuess)
    tGuess=input('Estimate threshold (e.g. -1): ');
end
tGuessSd=[];
while isempty(tGuessSd)
    tGuessSd=input('Estimate the standard deviation of your guess, above, (e.g. 2): ');
end

q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,grain,range,plotIt);
q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
fprintf('Your initial guess was %g +- %g\n',tGuess,tGuessSd);


% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);


% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);


% Query the frame duration
ifi = Screen('GetFlipInterval', window);

%--------------------
% Gabor information
%--------------------

% Dimension of the region where will draw the Gabor in pixels
gaborDimPix = windowRect(4) / 2;

% Sigma of Gaussian
sigma = gaborDimPix / 15;

% Obvious Parameters
orientation = 0;
contrast = 0.8;
aspectRatio = 1.0;
phase = 0;
duration = 1000; % ms
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

% Randomise the phase of the Gabors and make a properties matrix.
propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];

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
for trcount = 1:50
    
    % initial fixation
    [xCenter, yCenter] = RectCenter(windowRect);
    Screen('DrawDots', window, [xCenter, yCenter], 20, white);
    Screen('Flip',window);
    KbWait;
    WaitSecs(0.3);
    % Get recommended level.  Choose your favorite algorithm.
	tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
% 	tTest=QuestMean(q);		% Recommended by King-Smith et al. (1994)
% 	tTest=QuestMode(q);		% Recommended by Watson & Pelli (1983)
	
	% We are free to test any intensity we like, not necessarily what Quest suggested.
% 		tTest=min(-0.05,max(-3,tTest)); % Restrict to range of log contrasts that our equipment can produce.
    %   tTest=min(-0.05,max(-3,tTest));
    duration(trcount) = 2^tTest;
    DIR(trcount) = sign(rand - 0.5);
    
Time0 = GetSecs;
while GetSecs < Time0 + duration(trcount)/1000
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
    responseForQUEST(trcount) = 1;
    fixColor = [0 255 0];
else
    responseForQUEST(trcount) = 0;
    fixColor = [255 0 0];
end
Screen('DrawDots', window, [xCenter, yCenter], 20, fixColor);
Screen('Flip',window);
WaitSecs(0.2);
q=QuestUpdate(q,tTest,responseForQUEST(trcount));

end

t=QuestMean(q);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
sd=QuestSd(q);
fprintf('Final threshold estimate (mean+-sd) is %.2f +- %.2f\n',2^t,2^sd);

% Clear screen
sca;

Result.SubjectResponse = Response;
Result.DriftDirection = DIR;
Result.QUESTObject = q;
save([FolderName,TestName{1}],'Result');
end