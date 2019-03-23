#%%
import numpy as np
import scipy as sp
import sklearn.decomposition
import time;

import process_audio
from harmonic_template import harmonic_template

#%% parameters of the transcription
NUM_SOURCES = 1

#%% Load the data
t1 = time.time();
V,t,midi_nn = process_audio.prep_for_nmf('tetrisA_mono.wav');
t2 = time.time();
print(t2-t1);

#%% iteratively compute the nmf with fewer components each time
template, offset = harmonic_template()
num_components = 264
condition = True
while (condition):
    
    print(num_components)
    
    model = sklearn.decomposition.NMF(n_components=num_components, max_iter=4, init='random', solver='mu')
    W = model.fit_transform(V)
    H = model.components_
    W_filtered = sp.ndimage.filters.correlate(W, template)
    W_decimated = np.copy(W_filtered)
    W_decimated[0:-1:3,:] = 0
    W_decimated[2:-1:3,:] = 0
    
    v_max = np.zeros(shape = (W_decimated.shape[1],1))
    i_max = np.zeros(shape = (W_decimated.shape[1],1))
    for i_basis, basis in enumerate(W_decimated.T):
        
        i_max[i_basis] = np.argmax(basis)
        v_max[i_basis] = basis[i_max[i_basis].astype('int')]
        
    i_rank_k = []
    for i_unq, unq in enumerate(np.unique(i_max)):
        match_list = np.where(i_max == unq)[0]
        ranks = sp.stats.rankdata(v_max[match_list], method='ordinal')
        top_k = np.where(ranks > ranks.shape[0]-NUM_SOURCES)[0]
        i_rank_k.append(match_list[top_k])
    
    updated_num_components = sum(x.shape[0] for x in i_rank_k)
    condition = updated_num_components != num_components
    num_components = updated_num_components

#%% permute the matrix so that the notes are in ascending order
new_ordering = np.hstack(i_rank_k)
W = W[:,new_ordering]
W_filtered = W_filtered[:,new_ordering]
H = H[new_ordering,:]
note_dictionary = midi_nn[i_max[new_ordering].astype('int')];