function nnmf(fileName,num_components,max_iter)
    file = matopen(fileName);
    Vbig = read(file, "V");
    num_freq_bins = size(Vbig[1],1);
    frame_size = size(Vbig[1],2);
    num_frames = length(Vbig);
    W_h = rand(num_freq_bins,num_components,num_frames);
    H_h = rand(num_components,frame_size,num_frames);
    epsilon1 = cu(1e-9*ones(num_components,frame_size));
    epsilon2 = cu(1e-9*ones(num_freq_bins,num_components));
    for i_frame=1:length(Vbig)
        V = cu(Vbig[i_frame]);
        W = cu(W_h[:,:,i_frame]);
        H = cu(H_h[:,:,i_frame]);
        for i_iter = 1:max_iter
            H = H .* (W'*V) ./ (W'*W*H .+ epsilon1)
            W = W .* (V*H') ./ (W*H*H' .+ epsilon2)
        end
        W_h[:,:,i_frame] = collect(W);
        H_h[:,:,i_frame] = collect(H);
    end
    return W_h,H_h
end