
%% select the type of stimulus here

S.Type = {...
    'StepRamp' ...
%     'DoubleStepRamp' ...
%     'SinusoidalPursuit' ...
%     'ForcedChoicePursuit' ...
};


%% run the parameter file
ParameterFileLocation = './ParameterFiles/';
ParameterFileName = [S.Type{1},'ParameterFile.m'];

run([ParameterFileLocation,ParameterFileName]);


%% run the stimulus file
StimulusFileLocation = './StimulusFiles/';
StimulusFileName = [S.Type{1},'StimulusFile'];
RunStimulusCommand = [StimulusFileName,'(S)'];
cd(StimulusFileLocation);
eval(RunStimulusCommand);
cd('..');

clear all;

    