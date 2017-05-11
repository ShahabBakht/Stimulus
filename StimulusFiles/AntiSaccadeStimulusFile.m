function Result = AntiSaccadeStimulusFile

S.ScreenCov_v = 0.40;%0.4571;
S.ScreenCov_h = 0.42;%0.3556;

trialTime = 1; % in sec
samplingRate = 10; % in Hz (it takes 10 samples per one second)
samplingTimes = 0:(1/samplingRate):trialTime;
FixationSize = 1.5;
Targetsize = 1.5;
numTrials = 5;
trials = repmat(samplingTimes,1,numTrials);
Result.Trials = trials;

targetLocationAmp = 10;
targetLocationAngle = [0,pi];
firstFixationAmp = 15;
firstFixationAngle = pi/2;
secondFixationAmp = 0;
secondFixationAngle = 0;
PPDx = 15;
PPDy = 15;
TargetWindow = 3;

screenNumber=max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% ListenChar(2);




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

firstFixCenterH = winWidth/2 + cos( firstFixationAngle ) * firstFixationAmp *PPDx;
firstFixationCenterV = winHeight/2 + sin( firstFixationAngle ) * firstFixationAmp *PPDy;
firstFixationLocation = [firstFixCenterH  - (Targetsize*PPDx)./2, firstFixationCenterV - (Targetsize*PPDx)./2, ...
    firstFixCenterH + (Targetsize*PPDx)./2, firstFixationCenterV + (Targetsize*PPDx)./2];

secondFixCenterH = winWidth/2 + cos( secondFixationAngle ) * secondFixationAmp *PPDx;
secondFixationCenterV = winHeight/2 + sin( secondFixationAngle ) * secondFixationAmp *PPDy;
secondFixationLocation = [secondFixCenterH  - (Targetsize*PPDx)./2, secondFixationCenterV - (Targetsize*PPDx)./2, ...
    secondFixCenterH + (Targetsize*PPDx)./2, secondFixationCenterV + (Targetsize*PPDx)./2];


dummymode=0;       % set to 1 to initialize in dummymode
el=EyelinkInitDefaults(window);
el.calibrationtargetsize= 1;
el.calibrationtargetwidth=0.5;
el.calibrationtargetcolour=WhiteIndex(el.window);
el.msgfontcolour = WhiteIndex(el.window);
el.backgroundcolour = BlackIndex(el.window);
el.targetbeep = 0;
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
    Eyelink('command', 'calibration_type = HV9');
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
    
    Screen('HideCursorHelper', window);

trialsorder = randperm(size(trials,2));

try
for trcount = 1:length(trialsorder);
    if rand>0.5
        thisTargetAngle = 0;
    else
        thisTargetAngle = pi;
    end
    Result.TargetAngles(trcount) = thisTargetAngle;
    mx = [];
    my = [];
    fixationX = [];
    fixationY = [];
    thisTargetCenterH = winWidth/2 + cos( thisTargetAngle ) * targetLocationAmp *PPDx;
    thisTargetCenterV = winHeight/2 + sin( thisTargetAngle ) * targetLocationAmp *PPDy;
    thisTargetLocation = [thisTargetCenterH  - (Targetsize*PPDx)./2, thisTargetCenterV - (Targetsize*PPDx)./2, ...
        thisTargetCenterH + (Targetsize*PPDx)./2, thisTargetCenterV + (Targetsize*PPDx)./2];
    
    leftFix = true;
    Eyelink('StartRecording');
    eye_used = Eyelink('EyeAvailable');
    WaitSecs(0.05);
    EVE = [];
    while leftFix
        Screen('FillOval',window,[200 0 0],firstFixationLocation);
        Screen('FillOval',window,[200 200 200],secondFixationLocation);
        Screen('Flip', window);
        
        % online eye position tracker - is subject fixating on the first
        % fixation point?
        if Eyelink( 'NewFloatSampleAvailable') > 0
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        
                        mx=[mx,x];
                        my=[my,y];
                        evtype=Eyelink('getnextdatatype');
                        EVE = [EVE,evtype];
                        save('event1.mat','EVE');
                        % are we in a fixation state?
%                         if evtype==el.STARTFIX
                            fixationX = [fixationX,x];
                            fixationY = [fixationY,y];
                            if abs( my(end) - firstFixationCenterV  )<=TargetWindow  * PPDx ...

                            WaitSecs(1);
                              
                                initDetectionTime = GetSecs;
                                Beeper(600,0.4,.15);
                                leftFix = false;
                            end  

                            
%                         end
                        
                    end
                end
        end
    end
    
    
    EVE = [];
    while ~leftFix
        
        Screen('FillOval',window,[0 200 0],firstFixationLocation);
        Screen('FillOval',window,[200 200 200],secondFixationLocation);
        Screen('Flip', window);
        
        % online eye position tracker - did subject saccade to the second
        % fixation point?
        if Eyelink( 'NewFloatSampleAvailable') > 0
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        
                        mx=[mx,x];
                        my=[my,y];
                        evtype=Eyelink('getnextdatatype');
                       
%                         EVE = [EVE,evtype];
%                         save('y.mat','my');save('x.mat','mx');
%                         save('event2.mat','EVE');
                        % a re we in a fixation state?
%                         if ~evtype==el.STARTFIX
                            
                            if abs(my(end) - firstFixationCenterV  )>TargetWindow  * PPDx ...

                            Beeper(450,0.4,.15);
                            leftFix = true;
                            end
                            
                           
                            
%                         end
                        
                    end
                end
        end
        
    
    
    end
    
    fixationTime = GetSecs + trials(trialsorder(trcount));
    while GetSecs <= fixationTime
        Screen('FillOval',window,[200 200 200],secondFixationLocation);
        Screen('Flip', window);
        if Eyelink( 'NewFloatSampleAvailable') > 0
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        
                        mx=[mx,x];
                        my=[my,y];
                    end
                end
        end
        
        
    end
    
    fixationTime = GetSecs + 2;
    while GetSecs <= fixationTime
        Screen('FillOval',window,[200 200 200],thisTargetLocation);
        Screen('Flip', window);
        if Eyelink( 'NewFloatSampleAvailable') > 0
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        
                        mx=[mx,x];
                        my=[my,y];
                    end
                end
        end
    
    end
    
    fixationTime = GetSecs + 2;
    while GetSecs <= fixationTime
        Screen('FillRect',window,black,windowRect);
        Screen('Flip', window);
%         if Eyelink( 'NewFloatSampleAvailable') > 0
%                 evt = Eyelink( 'NewestFloatSample');
%                 if eye_used ~= -1 % do we know which eye to use yet?
%                     % if we do, get current gaze position from sample
%                     x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
%                     y = evt.gy(eye_used+1);
%                     
%                     % do we have valid data and is the pupil visible?
%                     if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
%                        
%                         mx=[mx,x];
%                         my=[my,y];
%                     end
%                 end
%         end
    
    end
    
    
    
    X{trcount} = mx;
    Y{trcount} = my;
    Fixation_x{trcount} = fixationX;
    Fixation_y{trcount} = fixationY;
    
end
catch myerr
    ListenChar(0);
    myerr
    myerr.message
    myerr.stack
    cleanup
end
Result.X = X;
Result.Y = Y;
Result.fixationX = Fixation_x;
Result.fixationY = Fixation_y;
Result.trialLength = trialsorder;

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
    
ListenChar(0);
cleanup;


   

end

 function cleanup
 % Shutdown Eyelink:
 % Eyelink('Shutdown');
 Screen('CloseAll');
 end