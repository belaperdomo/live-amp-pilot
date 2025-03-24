%clc; clear; close all;
%eeglab

EEG = pop_loadxdf('C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\data\sub-P003\ses-S001\eeg\P003-S001-R001.xdf' , 'streamtype', 'EEG', 'exclude_markerstreams', {});
EEG.setname='03_dry_orig';
EEG.chanlocs(9:11) = [];
EEG.data(9:11,:) = [];
EEG.nbchan = [8];
folderpath = 'C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\data\sub-P003\P003-data';
files = dir(folderpath);

%Change Event Times
for i = 1:length(EEG.event)
    EEG.event(i).latency = EEG.event(i).latency+205.461;
end

%Assign electrode location to the file path
electrode_loc =  'C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\cap_montages\CACS-64_REF.bvef';
%Load the file into a variable called eloc
eloc = loadbvef(electrode_loc);
%Load the electrode or channel locations
EEG.chanlocs = eloc([4,32,26,21,15,16,5,3]);

%Save as
EEG = pop_saveset( EEG, 'filename',EEG.setname,'filepath',char(folderpath));

%Downsample
EEG = pop_resample( EEG, 250);
EEG.setname = '03_dry_ds';
EEG = pop_saveset( EEG, 'filename',EEG.setname,'filepath',char(folderpath));

%Rereference
EEG = pop_reref( EEG, []);

%Filter out them bois
tmp = double(EEG.data');
filter_out = filter_fcn(tmp,EEG.srate,0.1,50);
EEG.data = filter_out';

%Save final before Adaptive
EEG.setname = '03_dry_filt';
EEG = pop_saveset( EEG, 'filename',EEG.setname,'filepath',char(folderpath));

%Run adaptive filter
%Perform EOG corr
NC.data=EEG.data';                
NC.EEGchans=[1 2 3 4 5 6 7];          
NC.EOGchans=[8];
kernellen=3;
ffact=0.999;
[NC,state]=run_AF(NC,kernellen,ffact);

EEG.data = NC.data';

%Save after adaptive filter
EEG.setname = '03_dry_adaptive';
EEG = pop_saveset( EEG, 'filename',EEG.setname,'filepath',char(folderpath));

%Filter again
tmp = double(EEG.data');
filter_out = filter_fcn(tmp,EEG.srate,1,10);
EEG.data = filter_out';

%Epoch it now manualy using EEGLAB

%For saving the data
tmp = zeros(8,275,2);
eventlist = {EEG.event.type};

event = string(0);
eventloc = find(strcmp(eventlist,event));
tmp(:,:,1) = mean(EEG.data(:,:,eventloc),3);
event = string(1);
eventloc = find(strcmp(eventlist,event));
tmp(:,:,2) = mean(EEG.data(:,:,eventloc),3);

save('C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\data\sub-P003\P003-data\dry_ERP5.mat','tmp')

%{
rows for easy cap (wet) = 4,32,26,21,15,16,5,3
1 = Fz
2 = F4
3 = Cz
4 = P4
5 = Pz
6 = P3
7 = F3
8 = Fp1
%}


