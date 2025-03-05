%==========================================================================
%
%                 Live Amp Pilot Study Preprocesing
%
% Author: Bela
% Date Modified: 03/02/2025
%==========================================================================

a = 1; % For debug mode

% Electrode Montages (actiCAP snap vs. twist)
fpath_elec = 'C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\cap_montages\8chan_config.mat';
eloc = loadbvef(fpath_elec);

EEG.chanlocs = eloc(3:end);

% Filtering
tmp = double(EEG.data'); %making row vector to colum vector
filter_out = filter_fcn (tmp,EEG.srate,0.1,10); % filter_fcn (fa,Fs,hp_cutoff,lp_cutoff)
EEG.data = filter_out';
