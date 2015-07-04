% Genral
S.WhichType         =   'RepeatedDirection';         % 'RandomOrder' or 'RepeatedDirection'
S.PPD_X             =   20;             % Pixels per degree
S.PPD_Y             =   20;              
S.FixationTimeMin   =   1000;
S.FixationTimeMax   =   1000;
S.GapTime           =   500;
S.SaveFolder          =   'C:\Shahab\Stimulus Objects';


% 'sine' and 'LisbergerParadigm'
S.TRIAL_TIMER     =   10000;          % For 'sine' - ms

% 'LisbergerParadigm'
S.TRIAL_TIMER_1st =   300;           % The time before the target change direction - ms
S.TRIAL_TIMER_2nd =   400;           % The time after the target change direction - ms

S.type = {'preLearn' 'Learn' 'testLearn'};
% Angles(rad) Velocity(degree/s)
S.preLearn_conditions = [...
    [pi/2;10] ...
    ];
S.preLearnNumConditions = size(S.preLearn_conditions,2);
S.preLearnNumTrials = 1;
% Angle(rad) VelocityX_1(degree/s) VelocityY_1(degree/s) VelocityX_2(degree/s) VelocityY_2(degree/s)
S.Learn_conditions = [...
    [0;0;10;10;10] ...
    ];
S.LearnNumConditions = size(S.Learn_conditions,2);
S.LearnNumTrials = 5;
% Angle(rad) VelocityX_1(degree/s) VelocityY_1(degree/s) VelocityX_2(degree/s) VelocityY_2(degree/s)
S.testLearn_conditions = [...
    [0;0;10;0;10] ...
    ];
S.testLearnNumConditions = size(S.testLearn_conditions,2);
S.testLearnNumTrials = 1;


S.NumConditions = S.preLearnNumConditions + S.LearnNumConditions + S.testLearnNumConditions;
S.NumTrials = S.preLearnNumTrials + S.LearnNumTrials + S.testLearnNumTrials;

