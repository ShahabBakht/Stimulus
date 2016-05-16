% To fix:
% 1- The direction of motion currently is only 0 and 180 degrees. The other
% angles should be added which needs minor modifications in the codes.

function RandomDotsPursuit2StimulusFile(S)


NumTrials                   =   S.NumTrials;         % Number of trials per condition         
FixationTimeMin_noDots      =   S.FixationTimeMin_noDots;
FixationTimeMax_noDots      =   S.FixationTimeMax_noDots;
FixationTimeMin_withDots    =   S.FixationTimeMin_withDots;
FixationTimeMax_withDots    =   S.FixationTimeMax_withDots;
InitialTime                 =   S.InitialTime;
GapTime                     =   S.GapTime;
TRIAL_TIMER                 =   S.TRIAL_TIMER;       % (ms)
SaveFolder                  =   S.SaveFolder;
fixWinSize                  =   S.fixWinSize;
type = S.type;
NumConditions = S.NumConditions;
conditions = S.conditions;

trials = nan(10,NumConditions*NumTrials);
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


KbName('UnifyKeyNames')
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
    screenInfo = openExperiment(90,57,0);
    window = screenInfo.curWindow;
    wRect = screenInfo.screenRect;
%     screenNumber=max(Screen('Screens'));
%     [window, wRect]=Screen('OpenWindow', screenNumber, 0,[],32,2); %#ok<*NASGU>
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [winWidth, winHeight] = WindowSize(window);
    fixationWindow = [-fixWinSize -fixWinSize fixWinSize fixWinSize];
    fixationWindow = CenterRect(fixationWindow, wRect);
    % define sine function
%     sine_plot_x = winWidth/2;
%     sine_plot_y = winHeight/2;
%     amplitudeX = winWidth/4;
%     amplitudeY = winHeight/4;
    
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
        
        el.backgroundcolour = BlackIndex(el.window);
        
        el.calibrationtargetcolour= [255 0 0];
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
%     Eyelink('command','screen_phys_coords = %ld %ld %ld %ld', -160, 160, 160, -160);
%     Eyelink('command','screen_distance = %ld %ld %ld %ld', -160, 160, 160, -160);
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
    
    % allow to use the big button on the eyelink gamepad to accept the
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
    Eyelink('command', ['calibration_area_proportion ' num2str(S.ScreenCov_h) ' ' num2str(S.ScreenCov_v)]); % Eyelink('command', 'calibration_area_proportion horizontal vertical');
    Eyelink('command', ['validation_area_proportion ' num2str(S.ScreenCov_h) ' ' num2str(S.ScreenCov_v)]);
 
       
    %%%%%%%%%%
    % STEP 6 %
    %%%%%%%%%%
    
    % Hide the mouse cursor
%     Screen('HideCursorHelper', window);
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
        
%         sine_plot_x = winWidth/2;
%         sine_plot_y = winHeight/2;
%         amplitudeX = winWidth/4;
%         amplitudeY = winHeight/4;
        perm = trials(:,order(i));
            
%         perm(1)

        % Before recording, we place reference graphics on the host display
        % Must be in offline mode to transfer image to Host PC
        Eyelink('Command', 'set_idle_mode');
        % clear tracker display and draw box at center
        Eyelink('Command', 'clear_screen %d', 0);
        
        % calculate locations of target peripheries so that we can draw
        % matching lines and boxes on host pc
%         dots(2,1) = winHeight/2;
%         dots(1,1) = winWidth/2;
        
        %% Generating the Path
        
%         t = 0;
%         Angle = perm(1);
%         velocity = perm(2);
%         amplitude = perm(3);
%         velocityX = velocity * cos(Angle);
%         velocityY = velocity * sin(Angle);
%         StepAmplitude = 0.2*velocity* (PPD_X^2 + PPD_Y^2)^0.5;
%         sine_plot_x = sine_plot_x - StepAmplitude*cos(Angle);
%         sine_plot_y = sine_plot_y - StepAmplitude*sin(Angle);

%         x = sine_plot_x + (velocityX * t) * PPD_X;
%         y = sine_plot_y + (velocityY * t) * PPD_Y;
        
%         if ((velocityX * t)^2 + (velocityY * t)^2) > amplitude^2
%             StopFlag = true;
%         else
%             StopFlag = false;
%         end   

        
        %%
%         ball([1 3]) = [x-10 x+10];
%         ball([2 4]) =  [y-10 y+10];
        
        
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
        
%         fixationTime = GetSecs + ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);
%         while GetSecs < fixationTime
            setdir_target = perm(1);
            setspeed_target = 15*rand + 5;%perm(2);
            setdir_dots = perm(3);
            if perm(4) ~= 0
                setspeed_dots = setspeed_target;%perm(4);
            else
                setspeed_dots = perm(4);
            end
            setcoh = perm(5);
            contrast = perm(6)/100;
            setpachdiam = perm(7);%70;%perm(7);
            
            targets = setNumTargets(1);
            targets.show = 2;
            if cos(setdir_target) > 0
                FixationPositionX = -200;
            else
                FixationPositionX = 200;
            end
            Tloc = perm(10);
            targets = newTargets(screenInfo,targets,[1,2],[0,+Tloc * 10],[0,0],...
                [3,9],[255,0,0;150,150,150]);
            showTargets(screenInfo, targets, [1,2]);
            FixationTime_noDots = (FixationTimeMin_noDots + (FixationTimeMax_noDots-FixationTimeMin_noDots) * rand);
            pause(FixationTime_noDots/1000);
            dotInfo = createDotInfo(1);
            dotInfo.setstepsize = 0;
            dotInfo.maxDotsPerFrame = perm(9);
            dotInfo.numDotField = 1;
            dotInfo.apXYD = [0 0 setpachdiam*10];
            dotInfo.speed = [0];
            %dotInfo.targetspeed = [0];
            dotInfo.cohSet = [0/100];
            dotInfo.coh = [0*10;0*10];
            dotInfo.dir = [setdir_dots];
            FixationTime_withDots = (FixationTimeMin_withDots + (FixationTimeMax_withDots-FixationTimeMin_withDots) * rand);
            dotInfo.maxDotTime = [FixationTime_withDots/1000];
            dotInfo.eye_used = eye_used;
            dotInfo.trialtype = [2 1];
            dotInfo.dotColor = floor([255 255 255] * contrast); % default white dots
            dotInfo.dotSize = 2;
            dotInfo.isMovingTarget = false;
            dotInfo.changetime = [];
            dotInfo.fixationWindow = fixationWindow;
            
%             [frames, rseed, start_time, end_time, response, response_time] = ...
%                 dotsX(screenInfo, dotInfo,targets);
            
            dotInfo.initTime = FixationTime_withDots/1000;
            dotInfo.speed = [setspeed_dots];
            dotInfo.targetspeed = [setspeed_target];
            TargetVelocity(i) = dotInfo.targetspeed;
            dotInfo.cohSet = [setcoh/100];
            dotInfo.coh = [setcoh*10;setcoh*10];
            dotInfo.dir = [setdir_dots];
            dotInfo.targetdir = [setdir_target]*pi/180;
            dotInfo.maxDotTime = [(TRIAL_TIMER+FixationTime_withDots)/1000];
            dotInfo.apXYD = [perm(10)*10 0 setpachdiam*10];%[0 0 setpachdiam*10];
            dotInfo.trialtype = [2, 1];
            dotInfo.isMovingCenter = false;
            dotInfo.isMovingTarget = true;
            dotInfo.changetime = [FixationTime_withDots/1000,FixationTime_withDots/1000 + perm(8)/1000];
            dotInfo.CenterOfMoving = [perm(10),0]; % [x,y]degree
            dotInfo.DiameterOfMoving = perm(7);
            %              Eyelink('Message', 'SYNCTIME');
            targets = newTargets(screenInfo,targets,[1,2],[0,+Tloc* 10],[0,0],...
                [3,9],[255,0,0;21,0,0]);
            screenInfo.rseed = [];
            targets.show = [1,2];
            [frames, rseed, start_time, end_time, response, response_time] = ...
                dotsX(screenInfo, dotInfo,targets);
            
            
            
            pause(GapTime/1000);
%             Screen('FillRect', window, backgroundcolour);
%             Screen('FillOval', window,[255 0 0], [(dots(1,1) - 10), (dots(2,1) - 10), (dots(1,1) + 10), (dots(2,1) + 10)]);
%             Screen('Flip', window);
        
%         end
        
%         trialTime = GetSecs + TRIAL_TIMER/1000;
%         sttime = GetSecs;
%         resetInit = true;
%         while GetSecs < trialTime
            
            % STEP 7.4
            % Prepare and show the screen.
            % Enable alpha blending with proper blend-function. We need it
            % for drawing of smoothed points:
%             Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%             Screen('FillRect', window, backgroundcolour);
%             Screen('FillOval', window,[255 0 0], ball);
%             Screen('Flip', window);
            

%             t = GetSecs - sttime;
%             x = sine_plot_x + (velocityX * t) * PPD_X;
%             y = sine_plot_y + (velocityY * t) * PPD_Y;
%         
%             if ((velocityX * t)^2 + (velocityY * t)^2) > amplitude^2
%                 StopFlag = true;
%             else
%                 StopFlag = false;
%             end
% 
%             if StopFlag
%                 break
%             end
%  
%             
%             ball([1 3]) = [x-10 x+10];
%             ball([2 4]) = [y-10 y+10];
%         end
%         
%         fixationTime = GetSecs + ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);
%         while GetSecs < fixationTime
%         
%             Screen('FillRect', window, backgroundcolour);
%             Screen('FillOval', window,[255 0 0], [(x - 10), (y - 10), (x + 10), (y + 10)]);
%             Screen('Flip', window);
%         
%         end
        
        % STEP 7.6
        % add 100 msec of data to catch final events and blank display
        
%         Screen('FillRect', window, backgroundcolour);
%         Screen('Flip', window);

      
%         gapTime = GetSecs + GapTime/1000;
%         while GetSecs < gapTime
%         
%             Screen('FillRect', window, backgroundcolour);
%             Screen('Flip', window);
%         
%         end
        WaitSecs(0.1);
        Eyelink('StopRecording');
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
S.TargetVelocity = TargetVelocity;
%% Save the Stimulus Object

save([SaveFolder, '\', edfFile, '.mat'],'S');


end

