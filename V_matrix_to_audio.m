function V_matrix_to_audio(input_file)
aux_input_file = [input_file(1:end-6) '_cfs.mat'];
output_file = [input_file(1:end-6) '_rec.wav'];
load(input_file)
load(aux_input_file);

V = cell2mat(V');
V = V(:,1:size(cfs.c.phase,2));
cfs.c = (10.^(V-cfs.c.offset)) .* exp(1j*cfs.c.phase);
cfs.c = [cfs.c; flipud(cfs.c)];
xrec = icqt(cfs,cfs.g,cfs.fshifts);

audiowrite(output_file,xrec,cfs.Fs);
