S.numTrials               = 60; % usually 40
S.postResponseWaitTime    = 0.2; %seconds
S.Ydim                    = 23;
S.Xdim                    = 35;
S.Ypxl                    = 1800;
S.Xpxl                    = 2880;
S.distance                = 57;
S.SaveFolder              = '/Users/shahab/MNI/Data/Psychophysics/';

S.fixR                    = 0.1; %degrees
S.xFoV                    = atan((S.Xdim/2)/S.distance) * 180/pi * 2;
S.yFoV                    = atan((S.Ydim/2)/S.distance) * 180/pi * 2;
S.yPPD                    = S.Ypxl/S.yFoV;
S.xPPD                    = S.Xpxl/S.xFoV;

S.StimulusSize_radius     = 2.5; % degrees
S.GratingSize_radius      = 2.5;

S.sigma = 0.5;
S.f = 1/S.xPPD;

% QUEST parameters
S.pThreshold              = 0.82;
S.beta                    = 3.5;
S.delta                   = 0.01;
S.gamma                   = 0.5;
S.range                   = 5;
S.plotIt                  = 1;

S.numFrames               = 30; % temporal period, in frames, of the drifting grating

S.wf                      = 2 * pi * S.f;
S.K                       = .1;
S.sigmaX                  = 1.5 * S.xPPD;
S.sigmaY                  = 0.75 * S.yPPD;
S.muY                     = 1.25 * S.yPPD;

S.minFrameIdx             = 25; % determines the frame index in which the grating will appear.
S.maxFrameIdx             = 30;