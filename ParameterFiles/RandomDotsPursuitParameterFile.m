S.NumTrials                 =   20;             % Number of trials per condition
S.PPD_X                     =   20;            % Pixels per degree
S.PPD_Y                     =   20;              
S.FixationTimeMin_noDots    =   1000;
S.FixationTimeMax_noDots    =   1500;
S.FixationTimeMin_withDots  =   1000;
S.FixationTimeMax_withDots  =   1500;
S.InitialTime               =   125;
S.GapTime                   =   500;
S.TRIAL_TIMER               =   1000;          % For 'sine' - ms
S.SaveFolder                =   'C:\Shahab\Stimulus Objects';

S.type = {'0'}; % For 'ramp'
S.NumConditions = length(S.type);

% Angle(rad) Velocity(degree/s) Coherence (%) Contrast (%) Patch diameter (degree)-- For 'ramp'
S.conditions = [...
                 [0;10;75;100;5] ...
               ];
