S.numTrials               = 100; % usually 40
S.postResponseWaitTime    = 0.2; % seconds
S.numFrames               = 30;  % temporal period, in frames, of the drifting grating
S.minFrameIdx             = 25;  % determines the frame index in which the grating will appear.
S.maxFrameIdx             = 30;


S.Ydim                    = 30;
S.Xdim                    = 36;
S.Ypxl                    = 1024;
S.Xpxl                    = 1280;
S.distance                = 40;
S.xFoV                    = atan((S.Xdim/2)/S.distance) * 180/pi * 2;
S.yFoV                    = atan((S.Ydim/2)/S.distance) * 180/pi * 2;
S.yPPD                    = S.Ypxl/S.yFoV;
S.xPPD                    = S.Xpxl/S.xFoV;

S.SaveFolder              = 'C:\Users\Shahab\Documents\Shahab\Psychophysics Data\';

S.fixR                    = 0.1; %degrees
S.StimulusSize_radius     = 2.5; % degrees
S.GratingSize_radius      = 2.5;
S.sigma = 0.5;
S.f = 1/S.xPPD;
S.wf                      = 2 * pi * S.f;
S.K                       = .1;
S.sigmaX                  = 1.5 * S.xPPD;
S.sigmaY                  = 0.75 * S.yPPD;
S.muY                     = 1.25 * S.yPPD;


% QUEST parameters
S.pThreshold              = 0.75;%0.82;
S.beta                    = 3.5;
S.delta                   = 0.01;
S.gamma                   = 0.5;
S.range                   = 5;
S.plotIt                  = 1;
