function GratingContrastDetectionStimulusFile(S)

% Get the parameter values from the stimulus object
numBlocks               = S.numBlocks;
postStimulusWaitTime    = S.postStimulusWaitTime;
postResponseWaitTime    = S.postResponseWaitTime;
maxStimulusFrameIndex   = S.maxStimulusFrameIndex;
fixR                    = S.fixR;
yPPD                    = S.yPPD;
xPPD                    = S.xPPD;
StimulusSize_radius     = S.StimulusSize_radius;
GratingSize_radius      = S.GratingSize_radius;
sigma                   = S.sigma;
wf                      = S.wf;
K                       = S.K;
dK                      = S.dK;
sigmaX                  = S.sigmaX;
sigmaY                  = S.sigmaY;
muY                     = S.muY;

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
    getSecsFunction = 'GetSecs';

    targetLocation = cell(numBlocks,maxStimulusFrameIndex);
    
    % stimulus parameters that doesn't change from trial to trial
    
    StimulusSize_x_pxl = round(StimulusSize_radius * xPPD);
    StimulusSize_y_pxl = round(StimulusSize_radius * yPPD); %#ok
    GratingSize_x_pxl = round(GratingSize_radius * xPPD);
    GratingSize_y_pxl = round(GratingSize_radius * yPPD);
    
    hd = fspecial('disk',StimulusSize_x_pxl);
    hd = (hd - min(min(hd)))./(max(max(hd)) - min(min(hd)));
    hg = fspecial('gaussian', 2 * StimulusSize_x_pxl + 1, sigma * xPPD);
    
    G = conv2(hd,hg);
    [x,y]=meshgrid(-GratingSize_x_pxl:GratingSize_x_pxl,-GratingSize_y_pxl:GratingSize_y_pxl);
    
    
    
    % Open a double buffered fullscreen window and select a gray background
    % color:
    Screen('Preference', 'SkipSyncTests', 1);
    [w, screenRect]=Screen('OpenWindow',screenNumber, gray);
    frameRate=Screen('FrameRate',screenNumber);
    % If MacOSX does not know the frame rate the 'FrameRate' will return 0.
    % That usually means we run on a flat panel with 60 Hz fixed refresh
    % rate:
    if frameRate == 0
        frameRate=60;
    end
    
    KbName('UnifyKeyNames');
    ListenChar(2);
    for blockcount = 1:numBlocks
        stimulusFrameIdx = 1:maxStimulusFrameIndex;
        stimulusFrameIdx = stimulusFrameIdx(randperm(maxStimulusFrameIndex));
        stimulusTimes(blockcount,:) = stimulusFrameIdx.*(1/frameRate);
        trcount = 0;
        
        while trcount < maxStimulusFrameIndex
            trcount = trcount + 1;
            repeatTrial = false;
            phi = (90*rand) * pi/180;
            thisSign = randn;
            if thisSign > 0
                thisSign = -1;
                targetLocation{blockcount,trcount} = 'DOWN';
            else
                thisSign = 1;
                targetLocation{blockcount,trcount} = 'UP';
            end
            
            L1 = sin(x * wf + phi) .* ...
                (K + dK * exp(-((x/sigmaX).^2 + ((y + thisSign*muY)/sigmaY).^2)));
            L1 = padarray(L1,[floor((size(G,1)-size(L1,1))/2),floor((size(G,2)-size(L1,2))/2)]);
            L(:,:,trcount) =  L1.* G; %#ok<AGROW>
            
            
            %%
            
            
            
            % Definition of the drawn rectangle on the screen:
            % Compute it to  be the visible size of the grating, centered on the
            % screen:
            dstRect = [0 0 (size(L,1)-1)/2  (size(L,2)-1)/2];
            dstRect=CenterRect(dstRect, screenRect);
            srcRect = [0 0 size(L,1) size(L,2)];
            
            fixationRect = [0 0 fixR * xPPD fixR * yPPD];
            fixationRect=CenterRect(fixationRect, screenRect);
            
            
            % Compute each frame of the movie and convert the those frames, stored in
            % MATLAB matices, into Psychtoolbox OpenGL textures using 'MakeTexture';
            % length of each trial before the subject response period starts
            numFrames = maxStimulusFrameIndex + postStimulusWaitTime * frameRate;
            
            rightKey = KbName('RightArrow');
            timeZero=eval(getSecsFunction);
            while KbCheck; end % Wait until all keys are released.
            
            % We wait for the subject to start the trial
            while 1
                % Check the state of the keyboard.
                Screen('FillOval', w, [255 0 0], fixationRect);
                Screen('Flip', w);
                
                [ keyIsDown, seconds(blockcount,trcount), keyCode ] = KbCheck; %#ok
                seconds(blockcount,trcount) = seconds(blockcount,trcount) - timeZero; %#ok
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
            
            
            whichFrame = stimulusFrameIdx(trcount);
            
            for i = 1:numFrames
                
                if i == whichFrame
                    tex(i)=Screen('MakeTexture', w,  gray +  inc*L(:,:,trcount)); %#ok<AGROW>
                else
                    
                    tex(i)=Screen('MakeTexture', w, gray); %#ok<AGROW>
                end
            end
            
            % Run the movie animation for a fixed period.
            
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
                if KbCheck
                    repeatTrial = true;
                    
                end
                % Draw image:
                Screen('DrawTexture', w, tex(movieFrameIndices(i)),srcRect,dstRect);
                Screen('FillOval', w, [0 255 0], fixationRect);
                % Show it at next display vertical retrace. Please check DriftDemo2
                % and later, as well as DriftWaitDemo for much better approaches to
                % guarantee a robust and constant animation display timing! This is
                % very basic and not best practice!
                
                Screen('Flip', w);
                
            end
            if repeatTrial
                trcount = trcount - 1;
                repeatTrial = false;
                continue;
            end
            while KbCheck; end % Wait until all keys are released.
            
            downKey = KbName('DownArrow');
            upKey = KbName('UpArrow');
            % We wait for the subject to repond the trial
            while 1
                % Check the state of the keyboard.
                %                 Screen('FillOval', w, [0 0 255], fixationRect);
                Screen('FrameRect', w, [0 0 0], [fixationRect(1) - 10,fixationRect(2) - 10, fixationRect(3) + 10, fixationRect(4) + 10]);
                Screen('Flip', w);
                
                [ keyIsDown, responseSeconds(blockcount,trcount), responseKeyCode ] = KbCheck; %#ok
                responseSeconds(blockcount,trcount) = responseSeconds(blockcount,trcount) - timeZero; %#ok
                % If the use s pressing a key, then display its code number and name.
                if keyIsDown
                    
                    if responseKeyCode(upKey)
                        Response{blockcount,trcount} = 'UP';
                        Screen('FrameRect', w, [0 0 0], [fixationRect(1) - 10,fixationRect(2) - 10, fixationRect(3) + 10, fixationRect(4) + 10]);
                        Screen('FillRect', w, [0 0 0], [fixationRect(1)- 10,fixationRect(2) - 10, fixationRect(3)+10, fixationRect(4)-5]);
                        Screen('Flip', w);
                        WaitSecs(postResponseWaitTime);
                        break;
                    elseif responseKeyCode(downKey)
                        Response{blockcount,trcount} = 'DOWN';
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
            
            
        end
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
    
    S.seconds = seconds;
    S.responseSeconds = responseSeconds;
    S.Response = Response;
    S.targetLocation = targetLocation;
    S.stimulusTimes = stimulusTimes;

    save([S.SaveFolder, '\Temp', '.mat'],'S');
    
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end %try..catch..



end