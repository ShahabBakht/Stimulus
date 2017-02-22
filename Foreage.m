function result=Foreage




commandwindow;
S.ScreenCov_v = 0.4571;
S.ScreenCov_h = 0.3556;
S.PPD_X = 15;
S.PPD_Y = 15;
S.numTrials = 2;

try
    
    fprintf('EyelinkToolbox Image View Example\n\n\t');
    
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
    
    dummymode=0;       % set to 1 to initialize in dummymode

    
    % Open a graphics window on the main screen
    screenNumber=max(Screen('Screens'));
    [window, wRect]=Screen('OpenWindow', screenNumber);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [winWidth, winHeight] = WindowSize(window);
    result.wRect = wRect;
    result.winWidth = winWidth;
    result.winHeight = winHeight;
    
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(window);
    el.calibrationtargetsize= 1;
    el.calibrationtargetwidth=0.5;
    el.calibrationtargetcolour=WhiteIndex(el.window);
    el.msgfontcolour = WhiteIndex(el.window);
    el.backgroundcolour = BlackIndex(el.window);
    
    EyelinkUpdateDefaults(el);
    
    % Initialization of the connection with the Eyelink tracker
    % exit program if this fails.
    
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    % open file to record data to
    res = Eyelink('Openfile', edfFile);
    
    if res~=0
        fprintf('Cannot create EDF file ''%s'' ', edffilename);
        cleanup;
        return;
    end
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && ~dummymode
        cleanup;
        return;
    end
    
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
    Eyelink('command', 'calibration_type = HV13');
    Eyelink('command', 'generate_default_targets = YES');
    
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
    Eyelink('command', ['calibration_area_proportion ' num2str(S.ScreenCov_h) ' ' num2str(S.ScreenCov_v)]); % Eyelink('command', 'calibration_area_proportion horizontal vertical');
    Eyelink('command', ['validation_area_proportion ' num2str(S.ScreenCov_h) ' ' num2str(S.ScreenCov_v)]);
    
    
    
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    
    % open file for recording data
    Eyelink('Openfile', edfFile);
 
    
    % Do setup and calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

    % do a final check of calibration using driftcorrection
    % You have to hit esc before return.
    
    % Location of the image on the screen
    windowSubPart = [winWidth/2 - wRect(3) * S.ScreenCov_h/2, winHeight/2 - wRect(4) * S.ScreenCov_v/2, ...
        winWidth/2 + wRect(3) * S.ScreenCov_h/2,  winHeight/2 + wRect(4) * S.ScreenCov_v/2];
    % Location of the target
    rangeX = windowSubPart(3) - windowSubPart(1);
    rangeY = windowSubPart(4) - windowSubPart(2);
    smallestX = windowSubPart(1);
    smallestY = windowSubPart(2);
    meanTargetLocation_x = rangeX * rand + smallestX;
    meanTargetLocation_y = rangeY * rand + smallestY;
    stdTargetLocation_x = 0;
    stdTargetLocation_y = 0;
    
    
    for trcount = 1:S.numTrials
    EyelinkDoDriftCorrection(el);
    
        
    
    % Start recording eye position
    Eyelink('StartRecording');
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    % record a few samples before we actually start displaying
    WaitSecs(0.5);

    % STEP 6
    % Show image on display
    myimg='konijntjes1024x768.jpg';
    imdata=imread(myimg);
    imtex=Screen('MakeTexture', el.window, imdata);
    
    
    % Show the image
    result.windowSubPart = windowSubPart;
    Screen('FillRect', el.window, [0 0 0]);
    Screen('DrawTexture', el.window, imtex, [], windowSubPart);  % fill screen with image
    
    
    
    thisTargetLocation = normrnd([meanTargetLocation_x,meanTargetLocation_y],...
        [stdTargetLocation_x,stdTargetLocation_y]);
    result.thisTargetLocation = thisTargetLocation;
    % if target should be visible uncomment below lines
    % Screen('FillOval',el.window, [0, 0 , 0], ...
    %   [thisTargetLocation(1)-5,thisTargetLocation(2)-5,thisTargetLocation(1)+5,thisTargetLocation(2)+5]);
    % Screen('FillOval',el.window, [255, 255 , 255], ...
    %    [thisTargetLocation(1)-2,thisTargetLocation(2)-2,thisTargetLocation(1)+2,thisTargetLocation(2)+2]);
    
    
%     % Some useful info for user about what's happening.
%     [width, height]=Screen('WindowSize', el.window);
% 
%     Screen('TextFont', el.window, el.msgfont);
%     Screen('TextSize', el.window, el.msgfontsize);
%     Screen('DrawText', el.window, 'Just look around for a while.', 200, height-el.msgfontsize-20, el.msgfontcolour);

    % Show result on screen:
    Screen('Flip', el.window)
      
    % mark zero-plot time in data file
    Eyelink('Message', 'SYNCTIME');
    % wait a while to record a bunch of samples  
    mx = [];
    my = [];
    startTime = GetSecs;
    initDetectionTime = GetSecs;
    while GetSecs < startTime + 20

    % Query  eyetracker") -
    % (mx,my) is our gaze position.
    
    
    if Eyelink( 'NewFloatSampleAvailable') > 0
        % get the sample in the form of an event structure
        evt = Eyelink( 'NewestFloatSample');
        if eye_used ~= -1 % do we know which eye to use yet?
            % if we do, get current gaze position from sample
            x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
            y = evt.gy(eye_used+1);
            % do we have valid data and is the pupil visible?
            if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                
                mx=[mx,x];
                my=[my,y];
                
                
                    
                    if abs(mx(end) - thisTargetLocation(1))<=10 && abs(my(end) - thisTargetLocation(2))<=10
                        timer = GetSecs - initDetectionTime;
                        if timer >= 0.05
                            initDetectionTime = GetSecs;
                            break
                            
                        end
                    
                    end
                
            end
        end
    end
    
    end
    
    
    % STEP 7 remove image
    Screen('FillRect', el.window, [0 0 0]);
    Screen('DrawText', el.window, 'Well done!', winWidth/2, winHeight/2, el.msgfontcolour);
    Screen('Flip', el.window);
    % mark image removal time in data file
    Eyelink('Message', 'ENDTIME');
    WaitSecs(0.5);
    Eyelink('Message', 'TRIAL_END');
    
    % STEP 8
    % finish up: stop recording eye-movements, 
    % close graphics window, close data file and shut down tracker
    Eyelink('StopRecording');
    
    X{trcount} = mx;
    Y{trcount} = my;
    
    end
    result.eyeX = X;
    result.eyeY = Y;
    
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
    
    
    cleanup;
    
catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if it's open.
    cleanup;
    myerr
    myerr.message
    myerr.stack
end %try..catch.


% Cleanup routine:
function cleanup
% Shutdown Eyelink:
Eyelink('Shutdown');

% Close window:
sca;
commandwindow;
% Restore keyboard output to Matlab:
ListenChar(0);
