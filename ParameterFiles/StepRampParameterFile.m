
S.NumTrials       =   20;             % Number of trials per condition
S.PPD_X           =   20;            % Pixels per degree
S.PPD_Y           =   20;              
S.FixationTimeMin =   1000;
S.FixationTimeMax =   1500;
S.GapTime         =   500;
S.TRIAL_TIMER     =   10000;          % For 'sine' - ms
S.SaveFolder      =   'C:\Shahab\Stimulus Objects';

S.type = {'0' 'pi'}; % For 'ramp'
S.NumConditions = length(S.type);

% Angle(rad) velocity(degree/s) amplitude(degree) -- For 'ramp'
S.conditions = [...
                 [0;10;12] [pi;10;12] ...
               ];

        
           