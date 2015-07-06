S.NumTrials       =   20;             % Number of trials per condition
S.PPD_X           =   20;             % Pixels per degree
S.PPD_Y           =   20;              
S.FixationTimeMin =   1000;
S.FixationTimeMax =   1500;
S.CueTime         =   300;
S.GapTime         =   500;
S.SaveFolder      =   'C:\Shahab\Stimulus Objects';

S.TRIAL_TIMER     =   10000; 
S.type = {'0_pi'}; 

S.NumConditions = length(S.type);
% Angle1(rad)  Angle2 velocity(degree/s) amplitude(degree) -- For 'ramp'
S.conditions = [...
    [0;pi;16;10] ...
    ];
