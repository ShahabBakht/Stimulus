

S.FixationTimeMin     =   500;              % ms
S.FixationTimeMax     =   1500;             % ms
S.amplitudeT1         =   10;               % degree
S.amplitudeT2         =   5;               % degree
S.PPD_X                =   15;               % no. pixels per horizontal degree  
S.PPD_Y                =   15;               % no. pixels per vertical degree
S.targetSize          =   1;                % degree
S.waitTimeEnd         =   2000;
S.numTrials           =   [10;10;10;10;5;5;5;5]; % no. trials for each condition
S.SaveFolder          =   'C:\Users\Shahab\Documents\Shahab\Stimulus Objects';

% [directionT1;directionT2;waitTimeT1;waitTimeT2];                                              
S.conditions = [[0;0;100;80],[0;180;100;80],[180;0;100;80],[180;180;100;80],...
                [0;0;300;300],[0;180;300;300],[180;0;300;300],[180;180;300;300] ...
                ]; 
                                                    
S.numConditions = size(S.conditions,2);                                                 
                                                    
                                                    


