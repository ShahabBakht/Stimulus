
S.NumTrials       =   5;             % Number of trials per condition
S.PPD_X           =   41;            % Pixels per degree
S.PPD_Y           =   40;              
S.FixationTimeMin =   1000;
S.FixationTimeMax =   1500;
S.GapTime         =   500;
S.TRIAL_TIMER     =   10000;          % For 'sine' - ms
S.SaveFolder      =   'D:\Data\Eye Tracking\Stimulus Objects';

S.type = {'0' 'pi/4' 'pi/2' '3pi/4' 'pi' '3pi/2'}; % For 'ramp'
S.NumConditions = length(S.type);

% Angle(rad) velocity(degree/s) amplitude(degree) -- For 'ramp'
S.conditions = [...
                 [0;10;10] [pi/4;10;10] [pi/2;10;10] [3*pi/4;10;10] [pi;10;10] [3*pi/2;10;10] ...
               ];

        
           