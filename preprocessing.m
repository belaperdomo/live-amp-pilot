%==========================================================================
%
%                 Live Amp Pilot Study Preprocesing
%
% Date Modified: 03/02/2025
%==========================================================================

a = 1; % For debug mode

% Electrode Montages (actiCAP snap vs. twist)
fpath_elec = 'C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\cap_montages\CACS-64_REF.bvef';
eloc = loadbvef(fpath_elec);
%Load the electrode or channel locations
EEG.chanlocs = eloc([4,32,26,21,15,16,5,3]); % Specific to study

%EEG.chanlocs = eloc(3:end); <- from class

a=1;
% Filtering
tmp = double(EEG.data'); %making row vector to colum vector
filter_out = filter_fcn (tmp,EEG.srate,0.1,10); % filter_fcn (fa,Fs,hp_cutoff,lp_cutoff)
EEG.data = filter_out';
