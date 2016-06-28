function EstimateContrastThresholdStimulusFile(S)


numTrials = S.numTrials;
postResponseWaitTime = S.postResponseWaitTime;
fixR = S.fixR;
yPPD = S.yPPD;
xPPD = S.xPPD;
StimulusSize_radius = S.StimulusSize_radius;
GratingSize_radius = S.GratingSize_radius;
sigma = S.sigma;
pThreshold = S.pThreshold;
beta = S.beta;
delta = S.delta;
gamma = S.gamma;
range = S.range;
plotIt = S.plotIt;
numFrames = S.numFrames;
wf = S.wf;
K = S.K;
sigmaX = S.sigmaX;
sigmaY = S.sigmaY;
muY = S.muY;
minFrameIdx = S.minFrameIdx; % determines the frame index in which the grating will appear.
maxFrameIdx = S.maxFrameIdx;



try
	% This script calls Psychtoolbox commands available only in OpenGL-based 
	% versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
	% only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
	% an error message if someone tries to execute this script on a computer without
	% an OpenGL Psychtoolbox
	AssertOpenGL;
	
	% Get the list of screens and choose the one with the highest screen number.
	% Screen 0 is, by definition, the display with the menu bar. Often when 
	% two monitors are connected the one without the menu bar is used as 
	% the stimulus display.  Chosing the display with the highest dislay number is 
	% a best guess about where you want the stimulus displayed.  
	screens=Screen('Screens');
	screenNumber=max(screens);
	
    % Find the color values which correspond to white and black: Usually
	% black is always 0 and white 255, but this rule is not true if one of
	% the high precision framebuffer modes is enabled via the
	% PsychImaging() commmand, so we query the true values via the
	% functions WhiteIndex and BlackIndex:
	white=WhiteIndex(screenNumber);
	black=BlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
	gray=round((white+black)/2);

    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
		gray=white / 2;
    end
    
    % Contrast 'inc'rement range for given white and gray values:
	inc=white-gray;
    getSecsFunction='GetSecs';
    
    StimulusSize_x_pxl = round(StimulusSize_radius * xPPD);
    StimulusSize_y_pxl = round(StimulusSize_radius * yPPD); %#ok
    GratingSize_x_pxl = round(GratingSize_radius * xPPD);
    GratingSize_y_pxl = round(GratingSize_radius * yPPD);
    
    hd = fspecial('disk',StimulusSize_x_pxl);
    hd = (hd - min(min(hd)))./(max(max(hd)) - min(min(hd)));
    hg = fspecial('gaussian', 2 * StimulusSize_x_pxl + 1, sigma * xPPD);
    
    G = conv2(hd,hg);
    [x,y]=meshgrid(-GratingSize_x_pxl:GratingSize_x_pxl,-GratingSize_y_pxl:GratingSize_y_pxl);

    tGuess=[];
    while isempty(tGuess)
        tGuess=input('Estimate threshold (e.g. -1): ');
    end
    tGuessSd=[];
    while isempty(tGuessSd)
        tGuessSd=input('Estimate the standard deviation of your guess, above, (e.g. 2): ');
    end

    q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,[],range,plotIt);
    q.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
    fprintf('Your initial guess was %g +- %g\n',tGuess,tGuessSd);
    
    % Open a double buffered fullscreen window and select a gray background 
	% color:
    [w, screenRect]=Screen('OpenWindow',screenNumber, gray);
    
    % Definition of the rectangle for the fixation point
    fixationRect = [0 0 fixR * xPPD fixR * yPPD];
    fixationRect=CenterRect(fixationRect, screenRect);
    
    Screen('Preference', 'SkipSyncTests', 1);
	% Compute each frame of the movie and convert the those frames, stored in
	% MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
    KbName('UnifyKeyNames');

    for trcount = 1:numTrials
    ListenChar(2);
       % create the grating for each trial based on the contrast modulation
       % level in that trail determined by QUEST
    timeZero=eval(getSecsFunction);
    % Get recommended level.  Choose your favorite algorithm.
% 	tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
	tTest=QuestMean(q);		% Recommended by King-Smith et al. (1994)
% 	tTest=QuestMode(q);		% Recommended by Watson & Pelli (1983)
	
	% We are free to test any intensity we like, not necessarily what Quest suggested.
% 		tTest=min(-0.05,max(-3,tTest)); % Restrict to range of log contrasts that our equipment can produce.
    %   tTest=min(-0.05,max(-3,tTest));
    dK(trcount) = 10^tTest;
    phi = (90*rand) * pi/180;
    
    thisSign = randn;
    
    
    if thisSign > 0
        thisSign = -1;
        targetLocation{trcount} = 'DOWN';
    else
        thisSign = 1;
        targetLocation{trcount} = 'UP';
    end
    
    L1 = sin(x * wf + phi) .* ...
        (K + dK(trcount) * exp(-((x/sigmaX).^2 + ((y + thisSign*muY)/sigmaY).^2)));
    L1 = padarray(L1,[floor((size(G,1)-size(L1,1))/2),floor((size(G,2)-size(L1,2))/2)]);
    L(:,:,trcount) =  L1.* G; %#ok<AGROW>
    
    dstRect = [0 0 (size(L,1)-1)/2  (size(L,2)-1)/2];
    dstRect=CenterRect(dstRect, screenRect);
    srcRect = [0 0 size(L,1) size(L,2)];
    
        % wait for the subject to initiate the trial
        rightKey = KbName('RightArrow');
        
        while KbCheck; end % Wait until all keys are released.
        
        
        while 1
            % Check the state of the keyboard.
            Screen('FillOval', w, [255 0 0], fixationRect);
            Screen('Flip', w);
            
            [ keyIsDown, seconds(trcount), keyCode ] = KbCheck; %#ok
            seconds(trcount) = seconds(trcount) - timeZero; %#ok
            % If the user is pressing a key, then display its code number and name.
            if keyIsDown
                
                if keyCode(rightKey)
                    break;
                end
                
                % If the user holds down a key, KbCheck will report multiple events.
                % To condense multiple 'keyDown' events into a single event, we wait until all
                % keys have been released.
                KbReleaseWait;
            end
        end

        whichFrame = randi([minFrameIdx,maxFrameIdx]);
        
        
        
         for i = 1:numFrames
           
            if i == whichFrame
                tex(i)=Screen('MakeTexture', w,  gray +  inc*L(:,:,trcount)); %#ok<AGROW>
            else
                
                    
               tex(i)=Screen('MakeTexture', w, gray); %#ok<AGROW>
            end
        end
        
        % Run the movie animation for a fixed period.
        frameRate=Screen('FrameRate',screenNumber);
        
        % If MacOSX does not know the frame rate the 'FrameRate' will return 0.
        % That usually means we run on a flat panel with 60 Hz fixed refresh
        % rate:
        if frameRate == 0
            frameRate=60;
        end
        movieDurationSecs=numFrames*(1/frameRate);
        
        % Convert movieDuration in seconds to duration in frames to draw:
    movieDurationFrames=round(movieDurationSecs * frameRate);
    movieFrameIndices=mod(0:(movieDurationFrames-1), numFrames) + 1;
    
    % Use realtime priority for better timing precision:
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    % Animation loop:
    i = 0;
    while KbCheck; end
    while i < movieDurationFrames
        i = i + 1;
        
        % Draw image:
        Screen('DrawTexture', w, tex(movieFrameIndices(i)),srcRect,dstRect);
        Screen('FillOval', w, [0 255 0], fixationRect);
        % Show it at next display vertical retrace. Please check DriftDemo2
        % and later, as well as DriftWaitDemo for much better approaches to
        % guarantee a robust and constant animation display timing! This is
        % very basic and not best practice!
        
        Screen('Flip', w);
        
    end
    
    while KbCheck; end % Wait until all keys are released.
    
    downKey = KbName('DownArrow');
    upKey = KbName('UpArrow');
    % We wait for the subject to respond the trial
    while 1
        % Check the state of the keyboard.
        Screen('FrameRect', w, [0 0 0], [fixationRect(1) - 10,fixationRect(2) - 10, fixationRect(3) + 10, fixationRect(4) + 10]);
        Screen('Flip', w);
        
        [ keyIsDown, responseSeconds(trcount), responseKeyCode ] = KbCheck; %#ok
        responseSeconds(trcount) = responseSeconds(trcount) - timeZero;   %#ok
        % If the use s pressing a key, then display its code number and name.
        if keyIsDown
            
            if responseKeyCode(upKey)
                Response= 'UP';
                Screen('FrameRect', w, [0 0 0], [fixationRect(1) - 10,fixationRect(2) - 10, fixationRect(3) + 10, fixationRect(4) + 10]);
                Screen('FillRect', w, [0 0 0], [fixationRect(1)- 10,fixationRect(2) - 10, fixationRect(3)+10, fixationRect(4)-5]);
                Screen('Flip', w);
                WaitSecs(postResponseWaitTime);
                break;
            elseif responseKeyCode(downKey)
                Response = 'DOWN';
                Screen('FrameRect', w, [0 0 0], [fixationRect(1) - 10,fixationRect(2) - 10, fixationRect(3) + 10, fixationRect(4) + 10]);
                Screen('FillRect', w, [0 0 0], [fixationRect(1) - 10,fixationRect(2)+5, fixationRect(3)+10, fixationRect(4) + 10]);
                Screen('Flip', w);
                WaitSecs(postResponseWaitTime);
                break;
            end
            
            
            % If the user holds down a key, KbCheck will report multiple events.
            % To condense multiple 'keyDown' events into a single event, we wait until all
            % keys have been released.
            KbReleaseWait;
        end
    end
    % create 'response' for QUEST
            if strcmp(Response,targetLocation{trcount})
                response(trcount) = 1;
            else
                response(trcount) = 0;
            end
    q=QuestUpdate(q,tTest,response(trcount));
    
    end

    Priority(0);
	ListenChar(1);
    % Close all textures. This is not strictly needed, as
    % Screen('CloseAll') would do it anyway. However, it avoids warnings by
    % Psychtoolbox about unclose d textures. The warnings trigger if more
    % than 10 textures are open at invocation of Screen('CloseAll') and we
    % have 12 textues here:
    Screen('Close');
    
    % Close window:
    Screen('CloseAll');
    
    t=QuestMean(q);		% Recommended by Pelli (1989) and King-Smith et al. (1994). Still our favorite.
    sd=QuestSd(q);
    fprintf('Final threshold estimate (mean+-sd) is %.2f +- %.2f\n',10^t,sd);
    
    

    S.QUEST = q;
    S.dK = dK;
    
    save([S.SaveFolder, '\Temp', '.mat'],'S');
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end %try..catch..



end