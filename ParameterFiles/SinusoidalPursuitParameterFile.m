
S.NumTrials       =   5;             % Number of trials per condition
S.PPD_X           =   20;             % Pixels per degree
S.PPD_Y           =   20;              
S.FixationTimeMin =   1000;
S.FixationTimeMax =   1500;
S.GapTime         =   500;
S.SaveFolder      =   'C:\Shahab\Stimulus Objects';
S.TRIAL_TIMER     =   10000;          % For 'sine' - ms

S.type = {...
    'Horizontal_01' ...
    };
S.NumConditions = length(S.type);

% freq_x freq_y phase_x phase_y dc_x dc_y -- For 'sine'
S.conditions = [...
    [0.1;0;0;0] ...
    ];
