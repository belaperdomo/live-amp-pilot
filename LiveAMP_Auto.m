%clc; clear; close all;
%eeglab

%{
This is a script that will do all of the processing steps for LiveAMP
data (wet or dry) for an auditory oddball trial, it can be modified to do
any trials, however! Just need to set a for loop when you save data,
although it was easier for me in this instance to hardcode it when the
data was saved. The end product is a .mat file with epoched and averaged
(across trials, not runs or participants) ERPs

What you will need:
    1. CACS-64_REF.bvef (channel locations for brain vision gear)
    2. filter_fcn.m fucntion (notch and bandpass filter - makes sure notch is set to 60 Hz)
    3. Run_AF.m function (adaptive filter)

%}

fpath = 'C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\data\sub-P006\'; %This is the folder in which the data folder is located
feloc = 'C:\Users\belab\OneDrive - Florida Institute of Technology\Documents\Florida Tech\0_NeuroLab\LiveAmp_pilot_study\live-amp-pilot\cap_montages\';
datafiles = dir([fpath 'ses-S002\*.xdf']); %This is the data folder
xdf = {datafiles.name}; %This is a cell array with the names of all of the .xdf files in that folder

%For loop that literally does all of the data processing steps
for j = 1:length(xdf)
    EEG = pop_loadxdf(char(string(fpath) + 'ses-S002\'+ string(xdf(1,j))), 'streamtype', 'EEG', 'exclude_markerstreams', {}); %loads .xdf file in the "j" index 
    EEG.setname = char(string(xdf(1,j)) + '_Orig') %Makes set name something that is useful if you ever go back and load the .set file
    EEG.chanlocs(9:11) = []; %Removes the locations of the accelerometor
    EEG.data(9:11,:) = []; %Removes the data from the accelerometor
    EEG.nbchan = [8]; %Changes the total number of channels to 8
    
    %Change Event Times (using jitter)
    for i = 1:length(EEG.event)
        EEG.event(i).latency = EEG.event(i).latency+205.461;
    end
    
    %Assign electrode location to the file path
    electrode_loc =  [feloc 'CACS-64_REF.bvef'];
    %Load the file into a variable called eloc
    eloc = loadbvef(electrode_loc);
    %Load the electrode or channel locations (you may need to change these numbers depending on if you do or do not use the same electrode channels)
    EEG.chanlocs = eloc([4,32,26,21,15,16,5,3]);
    
    %Save as
    EEG = pop_saveset(EEG, 'filename',char(string(EEG.setname(1:9)) + '_orig'),'filepath',char(string(fpath)+'ses-S002'));
    
    %Downsample
    EEG = pop_resample( EEG, 250); %downsample to 250 hz
    EEG.setname = char(string(xdf(1,j)) + '_ds');
    
    %Rereference
    EEG = pop_reref( EEG, [4 7] ,'keepref','on'); %using channels P4 and P3 to re reference data, but keeping them in the data
    
    %Filter out the unwanted frequencies (this will include notch filter)
    tmp = double(EEG.data');
    filter_out = filter_fcn (tmp,EEG.srate,0.1,50); % Change this based on your needs it is 0.1 to 50 hz
    EEG.data = filter_out'; 
    
    %Run adaptive filter
    %Perform EOG corr
    NC.data=EEG.data';                
    NC.EEGchans=[1 2 3 4 5 6 7]; %These are the channels that you want to correct          
    NC.EOGchans=[8]; % These are the channels that you use for EOG or to detect blinks (Fp1)
    kernellen=3;
    ffact=0.999;
    [NC,state]=run_AF(NC,kernellen,ffact);
    
    EEG.data = NC.data';
    
    %Save after adaptive filter
    EEG.setname = char(string(xdf(1,j)) + '_adaptive');
    EEG = pop_saveset( EEG, 'filename',char(string(EEG.setname(1:9)) + '_adaptive'),'filepath',char(string(fpath)+'ses-S002'));
    
    %Filter out them bois again
    tmp = double(EEG.data');
    filter_out = filter_fcn (tmp,EEG.srate,1,10); %This time I am using an agressive 1 to 10 hz filter because I found this to be best
    EEG.data = filter_out';
    EEG.setname = char(string(xdf(1,1)) + '_01_10');
    
    %Epoch it now using EEGLAB
    EEG = pop_epoch( EEG, {  }, [-0.1           1], 'newname', char(string(xdf(1,1)) + '_epoch'), 'epochinfo', 'yes'); % Epoch from -0.1 to 1 seconds
    EEG = pop_rmbase( EEG, [-100 0] ,[]); %Baseline correction for first 100 ms
    EEG.setname = char(string(xdf(1,j)) + '_filter');

    %For saving the data
    tmp = zeros(8,275,2); %This is a 3D Matrix that will be used to store the epoched and averaged data for the first (:,:,1) and second conditions (:,:,2)
    eventlist = {EEG.event.type};
    
    event = string(0); %Looking for the events that are '0' in this case the standard
    eventloc = find(strcmp(eventlist,event));
    tmp(:,:,1) = mean(EEG.data(:,:,eventloc),3);
    event = string(1); %looking for events that are '1' in this case deviant
    eventloc = find(strcmp(eventlist,event));
    tmp(:,:,2) = mean(EEG.data(:,:,eventloc),3);
    
    save(string(fpath)+'ses-S002\'+string(EEG.setname(1:9)) + '_final','tmp')%Saving final .mat file
end
