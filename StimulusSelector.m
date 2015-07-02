
%% select the type of stimulus here

S.Type = ...
    'StepRamp';
%     'DoubleStepRamp';
%     'Sinusoidal';
%     'TargetSelection';


%% run the parameter file
ParameterFileLocation = './ParameterFiles/';
ParameterFileName = [S.Type,'ParameterFile.m'];

run([ParameterFileLocation,ParameterFileName]);


%% run the stimulus file
StimulusFileLocation = './StimulusFiles/';
StimulusFileName = [S.Type,'StimulusFile'];
RunStimulusCommand = [StimulusFileName,'(S)'];
cd(StimulusFileLocation);
eval(RunStimulusCommand);
cd('..');

clear all;

    