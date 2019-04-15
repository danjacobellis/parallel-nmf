function audio_to_V_matrix(input_file, frame_size)
if nargin < 2
    frame_size = [];
end
if isempty(frame_size)
    frame_size = 40000;
end

[pathstr,name,~] = fileparts(input_file);
if isempty(pathstr)
    output_file = name;
else
    output_file = [pathstr filesep name];
end

[y,Fs] = audioread(input_file);
y = mean(y,2);

f_min = 55;
f_max = 21120;
[cfs,f,g,fshifts] = cqt(y,'SamplingFrequency',Fs,'TransformType','full',...
    'BinsPerOctave', 36, 'FrequencyLimits', [f_min, f_max]);

i_max = length(f)/2 - 1;
cfs.c = cfs.c(1:i_max,:);
V = log10(abs(cfs.c));
cfs.c = struct('phase', angle(cfs.c));
cfs.g = g; clear g;
cfs.fshifts = fshifts; clear fshifts;
cfs.Fs = Fs;
V = medfilt1(V,251,[],2);
cfs.c.offset = -min(V);
V = V + cfs.c.offset;

pad_size = frame_size - mod(size(V,2),frame_size);
zero_padding = zeros(size(V,1),pad_size);
V = [V,zero_padding];
num_frames = size(V,2)/frame_size;
V = squeeze(num2cell(reshape(V,[size(V,1),frame_size,num_frames]),[1,2]));

save([output_file '_V.mat'], 'V', '-v7.3');
save([output_file '_cfs.mat'], 'cfs', '-v7.3');
