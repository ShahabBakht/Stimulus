
S.NumTrials       =   10;             % Number of trials per condition
S.PPD_X           =   42;            % Pixels per degree
S.PPD_Y           =   42;              
S.FixationTimeMin =   1000;
S.FixationTimeMax =   1500;
S.GapTime         =   500;
S.TRIAL_TIMER     =   1000;          % For 'sine' - ms
S.SaveFolder      =   'C:\Users\Shahab\Documents\Shahab\Stimulus Objects';

% S.type = {'0' '0' '0' 'pi' 'pi' 'pi'}; % For 'ramp'
S.type = {'0'};
S.NumConditions = length(S.type);

% Angle(rad) velocity(degree/s) amplitude(degree) -- For 'ramp'
% S.conditions = [...
%                  [0;15;14] [0;20;14] [0;25;14]...
%                  [pi;15;12] [pi;20;12] [pi;25;12]...
%                ];
S.conditions = [...
                 [0;10;15]
               ];
        
           