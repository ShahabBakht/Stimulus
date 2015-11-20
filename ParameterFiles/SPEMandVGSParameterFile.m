
S.NumTrials                     =   2;           % Number of trials per block per condition 
S.NumBlocksRepeatition          =   5;           % Number of repeatitions for each block
S.PPD_X                         =   42;          % Pixels per degree
S.PPD_Y                         =   42;              
S.FixationTimeMin               =   1000;
S.FixationTimeMax               =   1500;
S.GapTime                       =   500;
S.TRIAL_TIMER                   =   1000;          
S.SaveFolder                    =   'C:\Users\Shahab\Documents\Shahab\Stimulus Objects';

% S.type = {'0' '0' '0' 'pi' 'pi' 'pi'}; % For 'ramp'
S.type = {'0','180'};
S.NumConditions = length(S.type);


% smooth pursuit (1) , visually guided saccade (2)            
S.blocks = [2,1];

% Angle(rad) velocity(degree/s) amplitude(degree) -- For 'spem'
% Angle(rad) velocity(degree/s) amplitude(degree) -- For 'saccade'
S.conditions = [...
                 [0;10;15] ...
                 [pi;10;15]
               ];

        
           