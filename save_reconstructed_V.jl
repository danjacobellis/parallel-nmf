function save_reconstructed_V(W,H,full,components,new_filename,cfs_filename)
    # WARNING: reconstruction does not work when full set to false (still investigating why)
    
    cp(cfs_filename, string(new_filename[1:end-5],"cfs.mat"),force=true) 
    
    if full
        num_freq = size(W,1);
        frame_size = size(H,2)
        num_frames = size(W,3);
    else
        num_freq = size(W[1],1);
        frame_size = size(H[1],2)
        num_frames = size(W,1);
    end
    
    V_hat = Array{Any,2}(undef,num_frames,1)
    
    if full
        W = W[:,components,:];
        H = H[components,:,:];
        for i_frame = 1:num_frames
            V_hat[i_frame,1] = W[:,:,i_frame]*H[:,:,i_frame];
        end
    else
        for i_frame = 1:num_frames
            frame_comp = components[i_frame];
                W_i = W[i_frame][:,frame_comp]
                H_i = H[i_frame][frame_comp,:]
            V_hat[i_frame,1] = W_i * H_i
        end 
    end
        
    file = matopen(new_filename,"w")
    write(file,"V",V_hat)
    close(file)
end