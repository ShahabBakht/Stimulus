function el = SetupEyeLink(S,window,edfFile)


%%%%%%%%%%
% STEP 3 %
%%%%%%%%%%

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).

el=EyelinkInitDefaults(window);
[winWidth, winHeight] = WindowSize(window);
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

dummymode = 0;

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
% set parser (conservative saccade thresholds)
Eyelink('command', 'saccade_velocity_threshold = 35');
Eyelink('command', 'saccade_acceleration_threshold = 9500');

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

% enter Eyetracker camera setup mode, calibration and validation
EyelinkDoTrackerSetup(el);

end