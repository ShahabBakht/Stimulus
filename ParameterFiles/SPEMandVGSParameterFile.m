S.NumTrials                     =   10;           % Number of trials per block per condition 
S.NumBlocksRepeatition          =   1;           % Number of repeatitions for each block
S.PPD_X                         =   15;          % Pixels per degree
S.PPD_Y                         =   15;              
S.FixationTimeMin               =   1000;
S.FixationTimeMax               =   1500;
S.GapTime                       =   500;
S.TRIAL_TIMER                   =   1000;   
S.SPEMstep                      =   2;         % amplitude of step in step-ramp (degrees) 
S.TargetSize                    =   1;         % size of the target (degrees)  
S.SaveFolder                    =   'C:\Users\Shahab\Documents\Shahab\Stimulus Objects';

% S.type = {'0' '0' '0' 'pi' 'pi' 'pi'}; % For 'ramp'
S.type = {'0','180'};
S.NumConditions = length(S.type);


% smooth pursuit (1) , visually guided saccade (2)            
S.blocks = [2];

% Angle(rad) velocity(degree/s) amplitude(degree) -- For 'spem'
% Angle(rad) velocity(degree/s) amplitude(degree) -- For 'saccade'
S.conditions = [...
                 [0;10;10] ...
                 [pi;10;10]
               ];

        
           