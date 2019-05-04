module AudioNMF

using WAV;
using DSP;
using MATLAB
using CuArrays;
using CuArrays.CURAND;

export audio_to_V, V_to_audio, nmf, rearrange_components

function audio_to_V(filename, subrange=:);
    y, Fs = wavread(filename, subrange=subrange);
    if (size(y,2) == 2);
        y = 0.5*(y[:,1] + y[:,2]);
    end
    f_min = 55.0/(2^(1/36));
    f_max = 7040.0*(2^(1/36))+1e-9;
    S = Dict();
    S["Fs"] = Fs;
    S["cfs"],S["f"],S["g"],S["fshifts"] = mxcall(:cqt,4,y,"SamplingFrequency",Fs,
        "TransformType","full", "FrequencyLimits", [f_min, f_max],"BinsPerOctave", 36.0);
    
    mid_ind = floor(Int64,length(S["f"])/2) - 1;
    V = S["cfs"]["c"][1:mid_ind,:];
    S["phase"] = angle.(V);
    V = convert.(Float32,abs.(V));    
    return V,S;
end;

function V_to_audio(V,S,filename)
    V = convert.(Float64,V) .* exp.(1im*S["phase"]);
    S["cfs"]["c"] = [V; reverse(V,dims=1)];
    y_rec = mxcall(:icqt, 1, S["cfs"], S["g"], S["fshifts"]);
    wavwrite(y_rec, filename, Fs=S["Fs"]);
end;

function nmf(V, num_components, max_iter, gpu=true)
    num_freq_bins = size(V,1);
    if (gpu)
        V = cu(V);
        W = curand(Float32,num_freq_bins,num_components);
        H = curand(Float32,num_components,size(V,2));
        epsilon1 = cu(Float32(1e-9)*ones(Float32,num_components,size(V,2)));
        epsilon2 = cu(Float32(1e-9)*ones(Float32,num_freq_bins,num_components));
    else
        W = rand(Float32,num_freq_bins,num_components);
        H = rand(Float32,num_components,size(V,2));
        epsilon1 = Float32(1e-9)*ones(Float32,num_components,size(V,2));
        epsilon2 = Float32(1e-9)*ones(Float32,num_freq_bins,num_components);
    end
    for i_iter = 1:max_iter
        H = H .* (W'*V) ./ (W'*W*H .+ epsilon1)
        W = W .* (V*H') ./ (W*H*H' .+ epsilon2)
    end
    if (gpu)
        W_h = collect(W);
        H_h = collect(H);
        return W_h,H_h
    else
        return W,H
    end
    
end;

function rearrange_components(W,H)
    
    num_freq = size(W,1);
    num_seq = size(H,2)
    
    # harmonic template
    bins_per_note = 3;
    harmonics = bins_per_note * [0,12,19,24,28];
    penalty = bins_per_note * (1 .+ [0,4,9,16]);
    offset = harmonics[end];
    template = zeros(Float32,2*offset+1);\
    template[penalty] .= -1.0;
    template[1 .+ offset .+ harmonics] .= 1;
    
    # find f0 and sort
    pad_len = size(W,1) - length(template);
    skip_len = floor(Int64,length(template)/2);
    f0 = zeros(size(W,2))
    for i_col = 1:size(W,2)
        xc = xcorr(W[:,i_col],template)[pad_len+skip_len+1:end-skip_len];     
        f0[i_col] = findmax(xc)[2]
    end
    f0_ind = sortperm(Int.(f0));
    sort!(f0);

    W = W[:,f0_ind];
    H = H[f0_ind,:];
    
    # combine components with the same f0
    num_unique_notes = length(unique(f0));
    W2 = zeros(Float32,size(W,1),num_unique_notes);
    H2 = zeros(Float32,num_unique_notes,size(H,2));
    f02 = zeros(Int64,num_unique_notes);
    i_f0 = 1;
    for i_note = 1:num_unique_notes
        W2[:,i_note] = W[:,i_f0];
        H2[i_note,:] = H[i_f0,:];
        f02[i_note] = f0[i_f0];
        while ( (i_f0 < size(W,2)) && (f0[i_f0] == f0[i_f0+1]) )
            i_f0 += 1;
            W2[:,i_note] .+= W[:,i_f0];
            H2[i_note,:] .+= H[i_f0,:];
        end
        i_f0 +=1
    end
    
    # round each frequency to nearest midi note
    midi_nn = round.(Int64, f02./3) .+ 32;
    num_unique_notes = length(unique(midi_nn));
    W3 = zeros(Float32,size(W,1),num_unique_notes);
    H3 = zeros(Float32,num_unique_notes,size(H,2));
    f03 = zeros(Int64,num_unique_notes);
    i_f0 = 1;
    for i_note = 1:num_unique_notes
        W3[:,i_note] = W2[:,i_f0];
        H3[i_note,:] = H2[i_f0,:];
        f03[i_note] = midi_nn[i_f0];
        while ( (i_f0 < size(W2,2)) && (midi_nn[i_f0] == midi_nn[i_f0+1]) )
            i_f0 += 1;
            W3[:,i_note] .+= W2[:,i_f0];
            H3[i_note,:] .+= H2[i_f0,:];
        end
        i_f0 +=1
    end
    midi_nn = copy(f03);
            
    return W,H,f0,W2,H2,f02,W3,H3,midi_nn;
end;

end;