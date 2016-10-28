function DoubleStepSaccadeStimulusFile(S)

FixationTimeMin     =   S.FixationTimeMin;
FixationTimeMax     =   S.FixationTimeMax;
amplitudeT1         =   S.amplitudeT1;
amplitudeT2         =   S.amplitudeT2;
PPDx                =   S.PPDx;
PPDy                =   S.PPDy;
targetSize          =   S.targetSize;
waitTimeEnd         =   S.waitTimeEnd;
numConditions       =   S.numConditions;
conditions          =   S.conditions;
numTrials           =   S.numTrials;

trials = [];
for condcount = 1:numConditions
    %     trials(:,((condcount-1)*numTrials + 1):numTrials(condcount)) = repmat(conditions(:,condcount),1,numTrials(condcount));
    trials = [trials,repmat(conditions(:,condcount),1,numTrials(condcount))];
end
S.trials = trials;

ListenChar(2);

screenNumber=max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

try
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
    
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
    Screen(window,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [winWidth, winHeight] = WindowSize(window);
    
    el=EyelinkInitDefaults(window);
    el.targetbeep = 1;
    el.backgroundcolour = BlackIndex(el.window);
    el.calibrationtargetcolour= [255 255 255];
    el.calibrationtargetsize= 1;
    el.calibrationtargetwidth=0.5;
    EyelinkUpdateDefaults(el);
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
    
    % allow to use the big button on the eyelink gamepad to accept the
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
    Eyelink('command', ['calibration_area_proportion ' num2str(S.ScreenCov_h) ' ' num2str(S.ScreenCov_v)]); % Eyelink('command', 'calibration_area_proportion horizontal vertical');
    Eyelink('command', ['validation_area_proportion ' num2str(S.ScreenCov_h) ' ' num2str(S.ScreenCov_v)]);
    
    Screen('HideCursorHelper', window);
    EyelinkDoTrackerSetup(el);

    % ifi = Screen('GetFlipInterval', window);
    % topPriorityLevel = MaxPriority(window);
    
    trialsorder = randperm(sum(numTrials));
    S.trialsorder = trialsorder;
    
    for trialcount = 1:(sum(numTrials))
        
        [~, ~, keyID] = KbCheck(-1);
        if keyID(KbName('q'))
            break;
        end
        
        directionT1 = trials(1,trialsorder(trialcount));
        directionT2 = trials(2,trialsorder(trialcount));
        waitTimeT1 = trials(3,trialsorder(trialcount));
        waitTimeT2 = trials(4,trialsorder(trialcount));
        
        x1T1 = cos(directionT1 * pi/180) * amplitudeT1 * PPDx;
        y1T1 = sin(directionT1 * pi/180) * amplitudeT1 * PPDy;
        
        x1T2 = cos(directionT2 * pi/180) * amplitudeT2 * PPDx;
        y1T2 = sin(directionT2 * pi/180) * amplitudeT2 * PPDy;
        
        Position0 = [winWidth/2 - (targetSize*PPDx)./2, winHeight/2 - (targetSize*PPDx)./2, winWidth/2 + (targetSize*PPDx)./2, winHeight/2 + (targetSize*PPDx)./2];
        Position1 = Position0 + [x1T1,y1T1,x1T1,y1T1];
        Position2 = Position1 + [x1T2,y1T2,x1T2,y1T2];
        
        Eyelink('Command', 'set_idle_mode');
        % clear tracker display and draw box at center
        Eyelink('Command', 'clear_screen %d', 0);
        Eyelink('Command', 'set_idle_mode');
        WaitSecs(0.05);
        Eyelink('StartRecording');
        WaitSecs(0.1);
        eye_used = Eyelink('EyeAvailable');
        
        thisFixationTime = ((FixationTimeMin + (FixationTimeMax-FixationTimeMin) * rand)/1000);
        Screen('FillOval',window,[255 255 255],Position0);
        Screen('Flip', window);
        Eyelink('Message', 'SYNCTIME');
        WaitSecs(thisFixationTime);
        
        Screen('FillOval',window,[255 0 0],Position1);
        Screen('Flip', window);
        WaitSecs(waitTimeT1/1000);
        
        Screen('FillOval',window,[0 255 0],Position2);
        Screen('Flip', window);
        
        WaitSecs(waitTimeT2/1000);
        
        Screen('FillRect',window,black,windowRect);
        Screen('Flip', window);
        WaitSecs(waitTimeEnd/1000);
        Eyelink('StopRecording');
        
    end

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
    
catch
    cleanup;
end
ListenChar(0);
cleanup;

end


function cleanup
% Shutdown Eyelink:
Eyelink('Shutdown');
Screen('CloseAll');
end