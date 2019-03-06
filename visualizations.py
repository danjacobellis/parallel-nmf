import matplotlib.pyplot as plt

def time_freq_image(V,title = 'Time-Frequency Decomposition'):
    extent=[0, 98.5, 20, 108];
    _ = plt.imshow(V, origin='lower', extent=extent, \
               interpolation='none', aspect='auto', cmap='gray');
    _ = plt.xlabel('Time - s');
    _ = plt.ylabel('Midi Note Number');
    _ = plt.title(title);
    
def transcription(W,H,num_comp,trunc):
    grid = plt.GridSpec(3,7)
    for i_spectrum in range(num_comp):
        ax = plt.subplot(grid[0:3,i_spectrum])
        plt.plot(W[:,1+i_spectrum],range(W.shape[0]),c='k')
        plt.setp(ax.get_xticklabels(), visible=False)
        plt.setp(ax.get_yticklabels(), visible=False)
        if i_spectrum==num_comp//2:
            plt.title('$W$')
    for i_note in range(num_comp):
        ax = plt.subplot(grid[i_note,4:7])
        plt.plot(H[1+i_note,0:trunc],c='k')
        plt.setp(ax.get_xticklabels(), visible=False)
        plt.setp(ax.get_yticklabels(), visible=False)
        if i_note==0:
            plt.title('$H$')