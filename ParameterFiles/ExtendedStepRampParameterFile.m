
S.NumTrials       =   10;             % Number of trials per condition          
S.FixationTimeMin =   1000;
S.FixationTimeMax =   1500;
S.GapTime         =   500;
S.TRIAL_TIMER     =   1000;         
S.SaveFolder      =   'C:\Users\Shahab\Documents\Shahab\Stimulus Objects';
S.TargetSize      =   9;
% S.type = {'0' '0' '0' 'pi' 'pi' 'pi'}; % For 'ramp'
S.type = {'0','0','0','0','0','pi','pi','pi','pi','pi'};
S.NumConditions = length(S.type);
S.PPD_X           = 15;             % Pixels per degree
S.PPD_Y           = 15;

% Angle(rad);velocity(degree/s);amplitude(degree);initial position X
% (degree); initial position y (degree);target contrast (percent)
% S.conditions = [...
%                  [0;15;14] [0;20;14] [0;25;14]...
%                  [pi;15;12] [pi;20;12] [pi;25;12]...
%                ];
S.conditions = [...
                 [0;15;20;10;0;4] [pi;15;20;-10;0;4] ...
                 [0;15;20;10;0;5.6569] [pi;15;20;-10;0;5.6569] ...
                 [0;15;20;10;0;8] [pi;15;20;-10;0;8]...
                 [0;15;20;10;0;11.3137] [pi;15;20;-10;0;11.3137]...
                 [0;15;20;10;0;16] [pi;15;20;-10;0;16]
                 
               ];
        
           