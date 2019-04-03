%%
level = @(x) 10*log10(x.*conj(x));
inv_level = @(level,phase) (10.^(level./20)).*exp(1j*phase);

%% load audio
[y,Fs] = audioread('tetrisA_mono.wav');
y = mean(y,2);
y = y(1:1e6);
t = (0:length(y)-1)/Fs;

%% CQT
f_min = 45.1584;
f_max = Fs/2;
[cfs,f,g,fshifts] = cqt(y,'SamplingFrequency',Fs,'TransformType','full',...
    'BinsPerOctave', 36, 'FrequencyLimits', [f_min, f_max]);

%%
i_max = length(f)/2 - 1;
TFD = cfs.c(1:i_max,:);
phase = angle(TFD);
TFD = level(TFD);
%% 

% remove percussive component
if 0
    TFD = medfilt1(TFD,251,[],2);
end

% factor matrix and reconstruct
if 1
    offset = min(TFD(:));
    TFD = TFD - offset;
    [W,H] = nnmf(TFD,30);
    TFD = W*H + offset;
end

%% reconstruct
cfs.c = inv_level(TFD,phase);
cfs.c = [cfs.c;flipud(cfs.c)];
xrec = icqt(cfs,g,fshifts);

