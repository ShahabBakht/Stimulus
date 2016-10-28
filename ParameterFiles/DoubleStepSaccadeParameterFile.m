

S.FixationTimeMin     =   500;              % ms
S.FixationTimeMax     =   1500;             % ms
S.amplitudeT1         =   10;               % degree
S.amplitudeT2         =   10;               % degree
S.PPDx                =   15;               % no. pixels per horizontal degree  
S.PPDy                =   15;               % no. pixels per vertical degree
S.targetSize          =   1;                % degree
S.waitTimeEnd         =   2000;
S.numTrials           =   [1;1;2;2]; % no. trials for each condition
S.SaveFolder          =   'C:\Users\Shahab\Documents\Shahab\Stimulus Objects';

% [directionT1;directionT2;waitTimeT1;waitTimeT2;numTrialsThisCondition];                                              
S.conditions = [[0;90;100;80],[0;270;100;80],[180;90;100;80],[180;270;100;80]]; 
                                                    
S.numConditions = size(S.conditions,2);                                                 
                                                    
                                                    


