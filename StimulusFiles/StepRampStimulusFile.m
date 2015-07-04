function StepRampStimulusFile(S)


NumTrials       =   S.NumTrials;         % Number of trials per condition
PPD_X           =   S.PPD_X;             % Pixels per degree
PPD_Y           =   S.PPD_Y;              
FixationTimeMin =   S.FixationTimeMin;
FixationTimeMax =   S.FixationTimeMax;
GapTime         =   S.GapTime;
TRIAL_TIMER     =   S.TRIAL_TIMER;       % (ms)
SaveFolder      =   S.SaveFolder;

type = S.type;
NumConditions = S.NumConditions;
conditions = S.conditions;

trials = nan(3,NumConditions*NumTrials);
for condcount = 1:NumConditions
    trials(:,((condcount-1)*NumTrials + 1):condcount*NumTrials) = repmat(conditions(:,condcount),1,NumTrials);
end

S.trials = trials;

%%

if ~IsOctave
    commandwindow;
else
    more off;
end



dummymode = 0;

try
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
    
    %%%%%%%%%%
    % STEP 2 %
    %%%%%%%%%%
    
    % Open a graphics window on the main screen
    % using the PsychToolbox's Screen function.
    screenNumber=max(Screen('Screens'));
    [window, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2); %#ok<*NASGU>
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [winWidth, winHeight] = WindowSize(window);
    
    % define sine function
    sine_plot_x = winWidth/2;
    sine_plot_y = winHeight/2;
    amplitudeX = winWidth/4;
    amplitudeY = winHeight/4;
    
    %%%%%%%%%%
    % STEP 3 %
    %%%%%%%%%%
    
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    
    el=EyelinkInitDefaults(window);
    
    % We are changing calibration to match task background and target
    % this eliminates affects of changes in luminosity between screens
    % no sound and smaller targets
    el.targetbeep = 0;
    el.backgroundcolour = WhiteIndex(el.window);
    backgroundcolour = WhiteIndex(window);
    el.calibrationtargetcolour= [0 0 0];
    % for lower resolutions you might have to play around with these values
    % a little. If you would like to draw larger targets on lower res
    % settings please edit PsychEyelinkDispatchCallback.m and see comments
    % in the EyelinkDrawCalibrationTarget function
    el.calibrationtargetsize= 1;
    el.calibrationtargetwidth=0.5;
    % call this function for changes to the el calibration structure to take
    % affect
    EyelinkUpdateDefaults(el);
    
    %%%%%%%%%%
    % STEP 4 %
    %%%%%%%%%%
    
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
    
    %%%%%%%%%%
    % STEP 5 %
    %%%%%%%%%%
    
    % SET UP TRACKER CONFIGURATION
    
    Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
    % Setting the proper recording resolution, proper calibration type,
    % as well as the data file content;
    
    % This command is crucial to map the gaze positions from the tracker to
    % screen pixel positions to determine fixation
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, winWidth-1, winHeight-1);
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    Eyelink('command', 'generate_default_targets = YES');
    
    % STEP 5.1 retrieve tracker version and tracker software version
    [v,vs] = Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    vsn = regexp(vs,'\d','match');
    
    if v == 3 && str2double(vsn{1}) == 4 % if EL 1000 and tracker version 4.xx
        
       % remote mode possible add HTARGET ( head target)
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
        % set link data (used for gaze cursor)
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
    else
        Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
        % set link data (used for gaze cursor)
        Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end
%     
    % allow to use the big button on the eyelink gamepad to accept the
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
    
       
    %%%%%%%%%%
    % STEP 6 %
    %%%%%%%%%%
    
    % Hide the mouse cursor
    Screen('HideCursorHelper', window);
    % enter Eyetracker camera setup mode, calibration and validation
    EyelinkDoTrackerSetup(el);
    
    %%%%%%%%%%
    % STEP 7 %
    %%%%%%%%%%
    
    % Now starts running individual trials
    % You can keep the rest of the code except for the implementation
    % of graphics and event monitoring
    % Each trial should have a pair of "StartRecording" and "StopRecording"
    % calls as well integration messages to the data file (message to mark
    % the time of critical events and the image/interest area/condition
    % information for the trial)
    
    
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
        
        
        perm = trials(:,order(i));
            
        perm(1)
        % Add Eye-link messages here (see DoubleStepSaccades)
        %
        %%%%
        
        
        % STEP 7.1
        % Sending a 'TRIALID' message to mark the start of a trial in Data
        % Viewer.  This is different than the start of recording message
        % START that is logged when the trial recording begins. The viewer
        % will not parse any messages, events, or samples, that exist in
        % the data file prior to this message.
%         Eyelink('Message', 'TRIALID %d', i);
        
        % This supplies the title at the bottom of the eyetracker display
%         Eyelink('command', 'record_status_message "TRIAL %d/%d %s"', i,6, char(type(i)));
        % Before recording, we place reference graphics on the host display
        % Must be in offline mode to transfer image to Host PC
        Eyelink('Command', 'set_idle_mode');
        % clear tracker display and draw box at center
        Eyelink('Command', 'clear_screen %d', 0);
        
        % calculate locations of target peripheries so that we can draw
        % matching lines and boxes on host pc
%         Eyelink('command', 'draw_filled_box %d %d %d %d 2' ,floor(winWidth/2-amplitudeX)-20, floor(winHeight/2-20), floor(winWidth/2-amplitudeX)+20, floor(winHeight/2+20));
%         Eyelink('command', 'draw_line %d %d %d %d 2' ,floor(winWidth/2-amplitudeX), floor(winHeight/2), floor(winWidth/2+amplitudeX), floor(winHeight/2));
%         Eyelink('command', 'draw_filled_box %d %d %d %d 2' ,floor(winWidth/2+amplitudeX)-20, floor(winHeight/2-20), floor(winWidth/2+amplitudeX)+20, floor(winHeight/2+20));
%         Eyelink('command', 'draw_filled_box %d %d %d %d 2' ,floor(winWidth/2-20), floor((winHeight/2-amplitudeY)-20), floor(winWidth/2+20), floor(winHeight/2-amplitudeY)+20);
%         Eyelink('command', 'draw_line %d %d %d %d 2' ,floor(winWidth/2), floor(winHeight/2-amplitudeY), floor(winWidth/2), floor(winHeight/2+amplitudeY));
%         Eyelink('command', 'draw_filled_box %d %d %d %d 2' ,floor(winWidth/2-20), floor(winHeight/2+amplitudeY)-20, floor(winWidth/2+20), floor(winHeight/2+amplitudeY)+20);

        dots(2,1) = winHeight/2;
        dots(1,1) = winWidth/2;
        %% Generating the Path
        
        t = 0;
        Angle = perm(1);
        velocity = perm(2);
        amplitude = perm(3);
        velocityX = velocity * cos(Angle);
        velocityY = velocity * sin(Angle);
        StepAmplitude = 0.2*velocity* (PPD_X^2 + PPD_Y^2)^0.5;
        sine_plot_x = sine_plot_x - StepAmplitude*cos(Angle);
        sine_plot_y = sine_plot_y - StepAmplitude*sin(Angle);

        x = sine_plot_x + (velocityX * t) * PPD_X;
        y = sine_plot_y + (velocityY * t) * PPD_Y;
        
        if ((velocityX * t)^2 + (velocityY * t)^2) > amplitude^2
            StopFlag = true;
        else
            StopFlag = false;
        end   

        
        %%
        ball([1 3]) = [x-10 x+10];
        ball([2 4]) =  [y-10 y+10];
        
        
        WaitSecs(0.1);
        % STEP 7.2
        % Do a drift correction at the beginning of each trial
        % Performing drift correction (checking) is optional for
        % EyeLink 1000 eye trackers. Drift correcting at different
        % locations x and y depending on where the ball will start
        % we change the location of the drift correction to match that of
        % the target start position
        % Note drift correction does not accept fractionals in PTB!
        EyelinkDoDriftCorrection(el);%,round(x),round(y));
        
        % STEP 7.3
        % start recording eye position (preceded by a short pause so that
        % the tracker can finish the mode transition)
        % The paramerters for the 'StartRecording' call controls the
        % file_samples, file_events, link_samples, link_events availability
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.05);
        Eyelink('StartRecording');
        % record a few samples before we actually start displaying
        % otherwise you may lose a few msec of data
        WaitSecs(0.1);
        
        % get eye that's tracked
        eye_used = Eyelink('EyeAvailable');
        
        fixationTime = GetSecs + ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);
        while GetSecs < fixationTime
        
            Screen('FillRect', window, backgroundcolour);

%             Screen('FillRect', window, el.backgroundcolour);
            Screen('FillOval', window,[255 0 0], [(dots(1,1) - 10), (dots(2,1) - 10), (dots(1,1) + 10), (dots(2,1) + 10)]);
%             Screen('DrawDots',window, dots(:,1),10, [255 0 0]);
            Screen('Flip', window);
        
        end
        
        trialTime = GetSecs + TRIAL_TIMER/1000;
        sttime = GetSecs;
        resetInit = true;
        while GetSecs < trialTime
            
            % STEP 7.4
            % Prepare and show the screen.
            % Enable alpha blending with proper blend-function. We need it
            % for drawing of smoothed points:
            Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%             Screen('FillRect', window, el.backgroundcolour);
            Screen('FillRect', window, backgroundcolour);
            Screen('FillOval', window,[255 0 0], ball);
            Screen('Flip', window);
            Eyelink('Message', 'SYNCTIME');
            % STEP 7.5
            % send the location of the target at each iteration so that
            % target can be displayed in Dataviewer
%             Eyelink('message', '!V TARGET_POS TARG1 (%d, %d) 1 0',floor(x),floor(y));

            t = GetSecs - sttime;
            x = sine_plot_x + (velocityX * t) * PPD_X;
            y = sine_plot_y + (velocityY * t) * PPD_Y;
        
            if ((velocityX * t)^2 + (velocityY * t)^2) > amplitude^2
                StopFlag = true;
            else
                StopFlag = false;
            end

            if StopFlag
                break
            end
 
            
            ball([1 3]) = [x-10 x+10];
            ball([2 4]) = [y-10 y+10];
        end
        
        fixationTime = GetSecs + ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);
        while GetSecs < fixationTime
        
            Screen('FillRect', window, backgroundcolour);

%             Screen('FillRect', window, el.backgroundcolour);
            Screen('FillOval', window,[255 0 0], [(x - 10), (y - 10), (x + 10), (y + 10)]);
%             Screen('DrawDots',window, dots(:,1),10, [255 0 0]);
            Screen('Flip', window);
        
        end
        
        % STEP 7.6
        % add 100 msec of data to catch final events and blank display
        WaitSecs(0.1);
        Eyelink('StopRecording');
        
%         Screen('FillRect', window, el.backgroundcolour);
        Screen('FillRect', window, backgroundcolour);

        Screen('Flip', window);
        
        % STEP 7.7
        % Send out necessary integration messages for data analysis
        % See "Protocol for EyeLink Data to Viewer Integration-> Interest
        % Area Commands" section of the EyeLink Data Viewer User Manual
        % IMPORTANT! Don't send too many messages in a very short period of
        % time or the EyeLink tracker may not be able to write them all
        % to the EDF file.
        % Consider adding a short delay every few messages.
        WaitSecs(0.001);
        % Send messages to report trial condition information
        % Each message may be a pair of trial condition variable and its
        % corresponding value follwing the '!V TRIAL_VAR' token message
        % See "Protocol for EyeLink Data to Viewer Integration-> Trial
        % Message Commands" section of the EyeLink Data Viewer User Manual
        WaitSecs(0.001);
        
        
%         Eyelink('Message', '!V TRIAL_VAR index %d', i);
        
        % a limitation of the currect ETB only accepts ints as input to
        % messages and commands a possible work around is given below
        
        
%         msg1 = sprintf('!V TRIAL_VAR freq_x %2.3f ', trials(1,i));
%         msg2 = sprintf('!V TRIAL_VAR freq_y %2.3f ', trials(2,i));
%         Eyelink('Message', msg1);
%         Eyelink('Message', msg2);     
        
        % STEP 7.8
        % Sending a 'TRIAL_RESULT' message to mark the end of a trial in
        % Data Viewer. This is different than the end of recording message
        % END that is logged when the trial recording ends. The viewer will
        % not parse any messages, events, or samples that exist in the data
        % file after this message.
%         Eyelink('Message', 'TRIAL_RESULT 0');
      
    gapTime = GetSecs + GapTime/1000;
        while GetSecs < gapTime
        
            Screen('FillRect', window, backgroundcolour);

%             Screen('FillRect', window, el.backgroundcolour);
%             Screen('DrawDots',window, dots(:,1),10, [255 0 0]);
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
    
    %%%%%%%%%%
    % STEP 9 %
    %%%%%%%%%%
    
    % run cleanup function (close the eye tracker and window).
    cleanup;
    
catch
    cleanup;
    fprintf('%s: some error occured\n', mfilename);
    psychrethrow(lasterror); %#ok<*LERR>
    
end

    function cleanup
        % Shutdown Eyelink:
        Eyelink('Shutdown');
        Screen('CloseAll');
    end

%% Save the Stimulus Object

save([SaveFolder, '\', edfFile, '.mat'],'S');


end

