
%
% drawDotsTest
%
% Example of showing how dots look without mask, using DrawDots (not using
% CLUT). This code is completely independent of other dots code and only need 
% psychtoolbox to run it.
%

% MKMK July 2006

% Beware (not converted for REX, in decimal format if should be)

function RDKBrownianStimulusFile()
sca;
% close all;
clearvars;

FolderName = '/Users/shahab/MNI/Data/Psychophysics/Motion Discrimination/';
TestName = inputdlg('Test Name');

try
    AssertOpenGL;
    
    %--------- random dots parameters
    
    numFrames       = 10;                   % how long to show the dots in seconds
    COHerences      = [0.3];%[0.7,0.8,0.9];       % test coherences %[0.1 0.3 0.5 .7 .9];
    view_dist_cm 	= 57;                  % distance to the screen in cm
    apDInDegree     = 5;                   % size of aperture in degrees
    speed           = 5;                   % dots speed in degree/sec
    dotSizeInDegree = .1;
    dotdensity      = 1;                % dots / degree^2 in each frame
    numTrials       = 10;                  % number of trials per coherence level
    numGroupsOfDots = 1;
    stimulusCenter  = [5,-5];              % [x,y] in degrees
    CRTmonitor      = false;
    dummymode       = 1;                   % set to 1 to initialize EyeLink in dummymode
    gamepadUse      = false;
    
    %--------------------------------------------------------------------- 
    
    parameters.numFrames = numFrames;
    parameters.COHerences = COHerences;
    parameters.view_dist_cm = view_dist_cm;
    parameters.apDInDegree = apDInDegree;
    parameters.speed = speed;
    parameters.dotSizeInDegree = dotSizeInDegree;
    parameters.dotdensity = dotdensity;
    parameters.numTrials = numTrials;
    parameters.numGroupsOfDots = numGroupsOfDots;
    parameters.stimulusCenter = stimulusCenter;
    parameters.CRTmonitor = CRTmonitor;
    parameters.gamepadUse = gamepadUse;
    
    
    allConditions = repmat(COHerences,1,numTrials);
    trialsOrder = randperm(length(allConditions)); 

    curScreen = max(Screen('Screens'));
    screenNumber2 = [];
    if length(Screen('Screens')) > 1
        screenNumber2 = min(Screen('Screens'));
    end
    
    % Define black, white and grey
    white = WhiteIndex(curScreen);
    grey = white / 2;
    black = BlackIndex(curScreen);
    
    dontclear = 0;
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
%     [curWindow, screenRect] = Screen('OpenWindow', curScreen, grey,[],32, 2);
    [curWindow, screenRect] = PsychImaging('OpenWindow', curScreen, grey, [], 32, 2,...
        [], [],  kPsychNeed32BPCFloat);
    if ~isempty(screenNumber2)
        [window2, windowRect2] = PsychImaging('OpenWindow', screenNumber2, black, [], 32, 2,...
        [], [],  kPsychNeed32BPCFloat);
    end
    
    [mon_horizontal_mm, mon_vertical_mm]=Screen('DisplaySize', curScreen);
    if CRTmonitor
        mon_horizontal_mm = 360;
        mon_vertical_mm = 300;
    end
    
    if gamepadUse
        numGamepads = Gamepad('GetNumGamepads');
        if numGamepads == 0
            error('No Gamepad connected');
        end
    end
    
    el=EyelinkInitDefaults(curWindow);
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    edfFile = 'demo.edf';
    Eyelink('Openfile', edfFile);
    EyelinkDoTrackerSetup(el);
    EyelinkDoDriftCorrection(el);
    
    % Enable alpha blending with proper blend-function. We need it for drawing 
    % of smoothed points.
    Screen('BlendFunction', curWindow, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    spf =Screen('GetFlipInterval', curWindow); % seconds per frame
    monRefresh = 1/spf; % frames per second

%     mon_horizontal_cm  	= 38;
    mon_horizontal_cm = mon_horizontal_mm / 10;
    
    ListenChar(2);
    
    % Everything is initially in coordinates of visual degrees, convert to pixels
    % (pix/screen) * (screen/rad) * rad/deg
    
    PPcm = screenRect(3)/(mon_horizontal_mm/10);
    widthDegree = 2 * atan((mon_horizontal_mm/20)/view_dist_cm) * 180/pi;
    heightDegree = 2 * atan((mon_vertical_mm/20)/view_dist_cm) * 180/pi;
    cmPD_w = (mon_horizontal_mm/10) / widthDegree;
    cmPD_h = (mon_vertical_mm/10) / heightDegree;
    PPD_w = PPcm * cmPD_w;
    PPD_h = PPcm * cmPD_h;

    ppd = min(PPD_w,PPD_h);%pi * screenRect(3) / atan(mon_horizontal_cm/view_dist_cm/2)  / 360;

    % center of the stimulus
    
    center = [screenRect(3), screenRect(4)]/2 + [stimulusCenter(1) * ppd, stimulusCenter(2) * ppd]; 

    % MAKE SURE APD IS USED CORRECTLY EVERYWHERE!!!!
    % aperture size from degree to pixels
    apD = ceil(apDInDegree * ppd);
    
    d_ppd = floor(apD/10 * ppd);
    
    % Dot stuff    
      
    dotSize = ceil(dotSizeInDegree * ppd);

    maxDotsPerFrame = 150; % By trial and error and depends on graphics card

    % ndots is the number of dots shown per video frame. Dots are placed in a 
    % square of the size of the aperture.    
    %   Size of aperture = Apd*Apd/100  sq deg
    %   Number of dots per video frame = 16.7 dots per sq.deg/sec,
    % When rounding up, do not exceed the number of dots that can be plotted in 
    % a video frame.
    
    ndots = ceil(dotdensity * apDInDegree^2);
%     ndots = ceil(min(maxDotsPerFrame, ceil(16.7 * apD .* apD * 0.01 / monRefresh))/2);
    
    % dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
    %   deg/sec * Ap-unit/deg * sec/jump = unit/jump
    

    
    
    priorityLevel = MaxPriority(curWindow,'KbCheck');
    Priority(priorityLevel);
    
    % THE MAIN LOOP
    frames = 0;
    waitframes = 1;
    
    allCondTrialCount = zeros(length(COHerences),1);
    
    for trcount = 1:(numTrials*length(COHerences))
        
        % ARRAYS, INDICES for loop
        ss_1 = rand(ndots*numGroupsOfDots, 2); % array of dot positions raw [xposition, yposition]
        ss_2 = rand(ndots*numGroupsOfDots, 2);
        
        % Divide dots into three sets
        Ls = cumsum(ones(ndots,numGroupsOfDots));% + repmat([0 ndots ndots*2], ndots, 1);
        loopi = 1; % Loops through the three sets of dots
        
        % Show for how many frames
        continue_show = numFrames;
        
        coh = allConditions(trialsOrder(trcount));
        [~,whichCond] = find(COHerences == coh);
        allCondTrialCount(whichCond) = allCondTrialCount(whichCond) + 1;
        DIR = sign(rand - 0.5);
        if DIR >= 0
            direction = 0;
        else
            direction = 180;
        end
        dxdy = repmat(speed * ppd/apD * (numGroupsOfDots/monRefresh) ...
        * [cos(pi*direction/180.0) -sin(pi*direction/180.0)], ndots,1);
        
        whichRandDIR = randi(8,ndots,1);
        allDIR = [0,45,90,135,180,225,270,315];
        directionRAND = allDIR(whichRandDIR);
        dxdyRAND = speed * ppd/apD * (numGroupsOfDots/monRefresh) ...
        * [cos(pi*directionRAND/180.0); -sin(pi*directionRAND/180.0)]';
        
        Eyelink('StartRecording');
        WaitSecs(0.5);
        [xCenter, yCenter] = RectCenter(screenRect);
        Screen('DrawDots', curWindow, [xCenter, yCenter], 20, [255 255 255]);
        vbl = Screen('Flip',curWindow);
        
        if ~gamepadUse
            KbWait;
        else
            gamepadnotpressed = true;
            while gamepadnotpressed
                buttonState = Gamepad('GetButton', 1, 1);
                if buttonState
                    gamepadnotpressed = false;
                end
            end
        end
        
        Eyelink('Message', 'SYNCTIME');
        Screen('FillRect',curWindow,[128 128 128]);
        Screen('DrawDots', curWindow, [xCenter, yCenter], 20, [1 1 1]);
        Screen('DrawDots', curWindow, [xCenter, yCenter], 10, [0.5 0.5 0.5]);
        vbl = Screen('Flip',curWindow);
        WaitSecs(.5);%0.5
        
    while continue_show
        % Get ss & xs from the big matrices. xs and ss are matrices that have 
        % stuff for dots from the last 2 positions + current.
        % Ls picks out the previous set (1:5, 6:10, or 11:15)
        Lthis  = Ls(:,loopi); % Lthis picks out the loop from 3 times ago, which 
                              % is what is then moved in the current loop
        
        this_s_1 = ss_1(Lthis,:);  % this is a matrix of random #s - starting positions
        this_s_2 = ss_2(Lthis,:);
        
        % 1 group of dots are shown in the first frame, a second group are shown 
        % in the second frame, a third group shown in the third frame. Then in 
        % the next frame, some percentage of the dots from the first frame are 
        % replotted according to the speed/direction and coherence, the next 
        % frame the same is done for the second group, etc.
        
        % Update the loop pointer
        loopi = loopi+1;
        
        if loopi == (numGroupsOfDots + 1)
            loopi = 1;
        end
        
        % Compute new locations
        % L are the dots that will be moved
        L_1 = rand(ndots,1) < coh;
        L_2 = rand(ndots,1) < coh;
        this_s_1(L_1,:) = this_s_1(L_1,:) + dxdy(L_1,:);	% Offset the selected dots
        this_s_2(L_2,:) = this_s_2(L_2,:) + dxdy(L_2,:);	% Offset the selected dots
                
        if sum(~L_1) > 0  % if not 100% coherence
%             this_s_1(~L_1,:) = rand(sum(~L_1),2);	% get new random locations for the rest  
                size(dxdyRAND)
                ndots
                ~L_1
              this_s_1(~L_1,:) = this_s_1(~L_1,:) + dxdyRAND(~L_1,:);
        end
        if sum(~L_2) > 0  % if not 100% coherence
%             this_s_2(~L_2,:) = rand(sum(~L_2),2);	% get new random locations for the rest  
            this_s_2(~L_2,:) = this_s_2(~L_2,:) + dxdyRAND(~L_2,:);
        end

        % Wrap around - check to see if any positions are greater than one or 
        % less than zero which is out of the aperture, and then replace with a 
        % dot along one of the edges opposite from direction of motion.
        
        N_1 = sum((this_s_1 > 1 | this_s_1 < 0)')' ~= 0;
        if sum(N_1) > 0
            xdir = sin(pi*direction/180.0);
            ydir = cos(pi*direction/180.0);
            % Flip a weighted coin to see which edge to put the replaced dots
            if rand < abs(xdir)/(abs(xdir) + abs(ydir))              
                this_s_1(find(N_1==1),:) = [rand(sum(N_1),1) (xdir > 0)*ones(sum(N_1),1)];
            else
                this_s_1(find(N_1==1),:) = [(ydir < 0)*ones(sum(N_1),1) rand(sum(N_1),1)];
            end
        end
        
        N_2 = sum((this_s_2 > 1 | this_s_2 < 0)')' ~= 0;
        if sum(N_2) > 0
            xdir = sin(pi*direction/180.0);
            ydir = cos(pi*direction/180.0);
            % Flip a weighted coin to see which edge to put the replaced dots
            if rand < abs(xdir)/(abs(xdir) + abs(ydir))              
                this_s_2(find(N_2==1),:) = [rand(sum(N_2),1) (xdir > 0)*ones(sum(N_2),1)];
            else
                this_s_2(find(N_2==1),:) = [(ydir < 0)*ones(sum(N_2),1) rand(sum(N_2),1)];
            end
        end
        
        
            % Convert to stuff we can actually plot
%         this_x_1(:,1:2) = floor(d_ppd(1) * this_s_1); % pix/ApUnit
%         this_x_2(:,1:2) = floor(d_ppd(1) * this_s_2); % pix/ApUnit
        
        this_x_1(:,1:2) = floor(apD(1) * this_s_1); % pix/ApUnit
        this_x_2(:,1:2) = floor(apD(1) * this_s_2); % pix/ApUnit
        % This assumes that zero is at the top left, but we want it to be in the 
        % center, so shift the dots up and left, which just means adding half of 
        % the aperture size to both the x and y direction.
%         dot_show_1 = (this_x_1(:,1:2) - d_ppd/2)';
%         dot_show_2 = (this_x_2(:,1:2) - d_ppd/2)';
        dot_show_1 = (this_x_1(:,1:2) - apD/2)';
        dot_show_2 = (this_x_2(:,1:2) - apD/2)';

        % After all computations, flip
        vbl = Screen('Flip', curWindow, vbl + (waitframes - 0.5) * spf);
%         Screen('Flip', curWindow,0,dontclear);
        % Now do next drawing commands
        
        Screen('DrawDots', curWindow, dot_show_1, dotSize, [255 255 255], center,2);
        Screen('DrawDots', curWindow, dot_show_2, dotSize, [0 0 0], center,2);
%         Screen('DrawDots', curWindow, [0; 0], 10, [255 0 0], center, 2);

        % Presentation
%         Screen('DrawingFinished',curWindow);
        
        frames = frames + 1;

        if frames == 1
            start_time = GetSecs;       
        end

        % Update the arrays so xor works next time
        xs_1(Lthis, :) = this_x_1;
        ss_1(Lthis, :) = this_s_1;
        xs_2(Lthis, :) = this_x_2;
        ss_2(Lthis, :) = this_s_2;

        % Check for end of loop
        continue_show = continue_show - 1;

    end
    
    Eyelink('Message', 'ENDTIME');
    % Present last dots
    Screen('Flip', curWindow,0,dontclear);

    % Erase last dots
    Screen('DrawingFinished',curWindow,dontclear);
    Screen('Flip', curWindow,0,dontclear);
    
    if ~gamepadUse
        [secs,KeyCode,deltaSecs] = KbWait;
        if KeyCode(leftKey)
            Response(trcount) = 1;
        elseif KeyCode(rightKey)
            Response(trcount) = -1;
            
        end
        
    else
        gamepadnotpressed = true;
        while gamepadnotpressed
            buttonStateLeft = Gamepad('GetButton', 1, 5);
            buttonStateRight = Gamepad('GetButton', 1, 6);
            responseSate = buttonStateLeft || buttonStateRight;
            if responseSate
                gamepadnotpressed = false;
                if buttonStateLeft
                    Response(trcount) = -1;
                else
                    Response(trcount) = 1;
                end
            end
        end
    end
    
    
    if (Response(trcount) == DIR)
        responseTrueFalse(whichCond,allCondTrialCount(whichCond)) = 1;
        fixColor = [0 255 0];
    else
        responseTrueFalse(whichCond,allCondTrialCount(whichCond)) = 0;
        fixColor = [255 0 0];
    end
    
     % Erase last dots
    Screen('FillRect',curWindow,[128 128 128]);
    Screen('DrawDots', curWindow, [xCenter, yCenter], 20, fixColor);
%     Screen('DrawingFinished',curWindow,dontclear);
    Screen('Flip', curWindow);
    Eyelink('StopRecording');   
    WaitSecs(0.2);
    
    end
    
    

   
    
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
    
    Screen('CloseAll'); % Close display windows
    Priority(0); % Shutdown realtime mode.    
    ShowCursor; % Show cursor again, if it has been disabled.
    Eyelink('Shutdown');
    
catch ME
    ListenChar(0);
    Screen('CloseAll'); % Close display windows
    rethrow(ME);
    disp('caught')
    Priority(0); % Shutdown realtime mode.
    StartUpdateProcess;
    ShowCursor; % Show cursor again, if it has been disabled.
end


Result.responseTrueFalse = responseTrueFalse;
Result.parameters = parameters;

% movefile('demo.edf',[TestName{1},'.edf']);

save([FolderName,TestName{1}],'Result');
ListenChar(0);



end