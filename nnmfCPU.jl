function nnmfCPU(fileName,num_components,max_iter)
    file = matopen(fileName);
    Vbig = read(file, "V");
    num_freq_bins = size(Vbig[1],1);
    frame_size = size(Vbig[1],2);
    num_frames = length(Vbig);
    W = rand(num_freq_bins,num_components,num_frames);
    H = rand(num_components,frame_size,num_frames);
    for i_frame=1:length(Vbig)
            for i_iter = 1:max_iter
            H[:,:,i_frame] = H[:,:,i_frame] .* (W[:,:,i_frame]'*Vbig[i_frame]) ./ (W[:,:,i_frame]'*W[:,:,i_frame]*H[:,:,i_frame] .+ 1e-9)
            W[:,:,i_frame] = W[:,:,i_frame] .* (Vbig[i_frame]*H[:,:,i_frame]') ./ (W[:,:,i_frame]*H[:,:,i_frame]*H[:,:,i_frame]' .+ 1e-9)
        end
    end
    return W,H
end