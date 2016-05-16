
S.NumTrials                 =   30;            % Number of trials per condition
S.PPD_X                     =   15;            % Pixels per degree
S.PPD_Y                     =   15;              
S.FixationTimeMin_noDots    =   1000;
S.FixationTimeMax_noDots    =   2000;
S.FixationTimeMin_withDots  =   0;
S.FixationTimeMax_withDots  =   0;
S.InitialTime               =   0;
S.GapTime                   =   200;
S.TRIAL_TIMER               =   500;   
S.SaveFolder                =   'C:\Users\Shahab\Documents\Shahab\Stimulus Objects';
S.fixWinSize                =   60;


S.type = {'0','0','0','180','180','180'};
% S.type = {'180','0'};
S.NumConditions = length(S.type);

% [Target Angle(rad); Target Velocity(degree/s); Dots Angle(rad); Dots
% Velocity(degree/s); Dots Coherence (%); Dots Contrast (%); Patch diameter
% (degree); Dots motion duration (ms) ; Number of Dots ; Target Position (degree)]



% The one that I run on the other subjects

% S.conditions = [...
%                  [0;20;0;10;100;100;6;250;300;10] ...
%                  [0;20;0;0;100;100;6;250;300;10] ...
%                  [180;20;180;10;100;50;6;250;300;-10] ...
%                  [180;20;180;0;100;100;6;250;300;-10] ...
%                  [0;20;0;10;100;100;12;250;300;10] ...
%                  [180;20;180;10;100;100;12;250;300;-10] ...
%                  [0;20;0;10;100;100;20;250;300;10] ...
%                  [180;20;180;10;100;100;20;250;300;-10] 
%                  
%                ];
S.conditions = [...
                 [0;20;0;10;100;100;2;150;2;10] ...
                 [180;20;180;10;100;50;2;150;2;-10] ...
                 [0;20;0;10;100;100;6;150;4;10] ...
                 [180;20;180;10;100;100;6;150;4;-10] ...
                 [0;20;0;10;100;100;20;150;50;10] ...
                 [180;20;180;10;100;100;20;150;50;-10] 
                 
               ];




% The test
% S.conditions = [...
%                  [90;15;90;0;100;100;70;250;150] ...
%                  [270;15;90;0;100;100;70;250;150]                                
%                ];
