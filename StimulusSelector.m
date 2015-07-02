
%% select the type of stimulus here

S.Type = ...
    'StepRamp';
%     'DoubleStepRamp';
%     'Sinusoidal';
%     'TargetSelection';


%% 

ParameterFileLocation = './ParameterFiles/';
ParameterFileName = [S.Type,'ParameterFile.m'];

run([ParameterFileLocation,ParameterFileName]);

%%


    