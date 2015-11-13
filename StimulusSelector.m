
%% Parameters to set

% select the type of stimulus here
S.Type = {...
%     'StepRamp' ...
%     'DoubleStepRamp' ...
%     'SinusoidalPursuit' ...
%     'ForcedChoicePursuit' ...
%     'RandomDotsPursuit' ...
%     'VisualGuidedSaccade' ...
%     'ExtendedStepRamp' ...
    'RandomDotsPursuit2' ...
};

% Select the percentage of screen horizontal and vertical coverage here
S.ScreenCov_v = 0.4571;
S.ScreenCov_h = 0.3556;


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

    