function rearrange_components(W_full, H_full, full)
    
    num_freq = size(W_full,1);
    frame_size = size(H_full,2);
    num_frames = size(W_full,3);
    
    if !full
        W_rearrange = Array{Any,1}(undef,num_frames);
        H_rearrange = Array{Any,1}(undef,num_frames);
    end
    
    # harmonic template
    bins_per_note = 3;
    harmonics = bins_per_note * [0,12,19,24,28];
    penalty = bins_per_note * (1 .+ [0,4,9,16]);
    offset = harmonics[end];
    template = zeros(2*offset+1);\
    template[penalty] .= -1.0;
    template[1 .+ offset .+ harmonics] .= 1;
    
    #repeat independently for each frame
    for i_frame = 1:num_frames
        W = W_full[:,:,i_frame];
        H = H_full[:,:,i_frame];
        
        # find f0 and sort
        f0 = zeros(size(W,2))
        for i_col = 1:size(W,2)
            f0[i_col] = findmax(xcorr(W[:,i_col],template))[2] - length(template)
        end
        f0_ind = sortperm(Int.(f0));
        sort!(f0);

        if full
            W_full[:,:,i_frame] = W[:,f0_ind];
            H_full[:,:,i_frame] = H[f0_ind,:];
        else
            W = W[:,f0_ind];
            H = H[f0_ind,:];
            # combine components with the same f0
            num_unique_notes = length(unique(f0));
            W2 = zeros(size(W,1),num_unique_notes);
            H2 = zeros(num_unique_notes,size(H,2));
            i_f0 = 1;
            for i_note = 1:num_unique_notes
                W2[:,i_note] = W[:,i_f0];
                H2[i_note,:] = H[i_f0,:];
                if i_f0 < size(W,2)
                    while (f0[i_f0] == f0[i_f0+1])
                        i_f0 += 1;
                        W2[:,i_note] .+= W[:,i_f0];
                        H2[i_note,:] .+= H[i_f0,:]
                    end
                end
                i_f0 +=1
            end
            W_rearrange[i_frame] = W2;
            H_rearrange[i_frame] = H2;
        end
        
    end
    
    if full
        return W_full,H_full
    else
        return W_rearrange,H_rearrange
    end
end