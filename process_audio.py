import librosa as lr
import numpy as np

def prep_for_nmf(audio_file, sr=44100):
    y, sr = lr.load(audio_file, sr=sr)
    y_harmonic,y_percussive = lr.effects.hpss(y)
    t = np.arange(len(y)) / sr
    BANDS_PER_NOTE = 3;
    n_bins = BANDS_PER_NOTE*88
    bins_per_octave=12*BANDS_PER_NOTE
    fmin= lr.midi_to_hz( 21 - (np.floor(BANDS_PER_NOTE/2)/BANDS_PER_NOTE) )
    CQT = lr.cqt(y=y_harmonic,bins_per_octave=bins_per_octave, fmin=fmin, n_bins=n_bins)
    f = lr.cqt_frequencies(bins_per_octave=bins_per_octave, fmin=fmin, n_bins=n_bins)
    midi_nn = np.arange(21-1/BANDS_PER_NOTE,108+2/BANDS_PER_NOTE, step=1/BANDS_PER_NOTE)
    SPL = 10* np.log10( np.real(CQT * np.conj(CQT)) )
    A_weight = np.tile(lr.A_weighting(f), [np.shape(SPL)[1],1]).T
    V = SPL+A_weight - np.min(SPL+A_weight)
    return V,t,midi_nn
