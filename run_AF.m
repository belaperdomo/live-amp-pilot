function [NC, state] = run_AF(NC,kernellen,ffact)
%Remove artifacts from EEG using artifact reference channels
%NC.data = [numSample x numChannel] 
%NC.EEGchans = index of EEG channels
%NC.EOGchans = index of EOG channels
%kernellen = Kernel Length (order of temporal FIR filter kernel)
%ffact = ForgetFactor

% References:
%  [1] P. He, G.F. Wilson, C. Russel, "Removal of ocular artifacts from electro-encephalogram by adaptive filtering"
%      Med. Biol. Eng. Comput. 42 pp. 407-412, 2004
%
%                                Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%                                2010-04-17
%
%


%initialize RLS filter state
state.eog = NC.EOGchans;
state.eeg = NC.EEGchans;
numEOGchan = length(state.eog);
numEEGchan = length(state.eeg);
state.hist = zeros(numEOGchan,kernellen);
state.R_n = eye(numEOGchan * kernellen) /0.01;
state.H_n = zeros(numEOGchan * kernellen,numEEGchan);

%apply filter
X=NC.data';
[signal,state.hist,state.H_n,state.R_n] = compute(X,state.hist,state.H_n,state.R_n,state.eeg,state.eog,ffact);
NC.data=signal';
NC.adaptive_filt.kernellen = kernellen;
NC.adaptive_filt.ffact = ffact;
end


function [X,hist,H_n,R_n] = compute(X,hist,H_n,R_n,eeg,eog,ffact)
    % for each sample...
    for n=1:size(X,2)
        % update the EOG history by feeding in a new sample
        hist = [hist(:,2:end) X(eog,n)];
        % vectorize the EOG history into r(n)        % Eq. 23
        tmp = hist';
        r_n = tmp(:); %r_n = [rv(n+1-M) ... rv(n) rh(n+1-M) ... rh(n)]'

        % calculate K(n)                             % Eq. 25
        K_n = R_n * r_n / (ffact + r_n' * R_n * r_n);
        % update R(n)                                % Eq. 24
        R_n = ffact^-1 * R_n - ffact^-1 * K_n * r_n' * R_n;

        % get the current EEG samples s(n)
        s_n = X(eeg,n);
        % calculate e(n/n-1)                         % Eq. 27
        e_nn = s_n - (r_n' * H_n)';
        % update H(n)                                % Eq. 26
        H_n = H_n + K_n * e_nn';
        % calculate e(n), new cleaned EEG signal     % Eq. 29
        e_n = s_n - (r_n' * H_n)';
        % write back into the signal
        X(eeg,n) = e_n;
    end
end
