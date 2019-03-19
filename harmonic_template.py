import numpy as np

def harmonic_template(BANDS_PER_NOTE = 3):
    harmonics = np.array([0.0, 12.0, 19.0, 24.0, 28.0])
    harmonics = harmonics * BANDS_PER_NOTE
    center = np.max(harmonics)
    vert = np.zeros(int(2*center + 1))
    idx = (center + harmonics).astype('int')
    vert[idx] = 1
    penalty = np.array([0.0, 4.0, 9.0, 16.0]) * BANDS_PER_NOTE
    idx = penalty.astype('int')
    vert[idx] = -1
    offset = np.arange(-center, center+1, 1)
    [X,Y] = np.meshgrid(1, vert)
    midpt = int(np.shape(X)[0]/2);
    X[0:midpt,:] = 1
    H = X*Y
    return H, offset