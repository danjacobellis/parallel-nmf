"""
adapted from https://github.com/zafarrafii/Z (updated for compatibility with julia 1.1)

audio_spectrogram = z.cqtspectrogram(audio_signal,sample_rate,time_resolution,cqt_kernel);

Compute constant-Q transform (CQT) spectrogram using a kernel
# Arguments:
- `audio_signal::Float`: the audio signal [number_samples, 1]
- `sample_rate::Float`: the sample rate in Hz
- `time_resolution::Float`: the time resolution in number of time frames per second
- `cqt_kernel::Complex`: the CQT kernel [number_frequencies, fft_length]
- `audio_spectrogram::Float`: the audio spectrogram in magnitude [number_frequencies, number_times]
# Example: Compute and display the CQT spectrogram
```
# Audio file averaged over the channels and sample rate in Hz
Pkg.add("WAV")
using WAV
audio_signal, sample_rate = wavread("audio_file.wav");
audio_signal = mean(audio_signal, 2);
# CQT kernel
frequency_resolution = 2;
minimum_frequency = 55;
maximum_frequency = 3520;
include("z.jl")
cqt_kernel = z.cqtkernel(sample_rate, frequency_resolution, minimum_frequency, maximum_frequency);
# CQT spectrogram
time_resolution = 25;
audio_spectrogram = z.cqtspectrogram(audio_signal, sample_rate, time_resolution, cqt_kernel);
# CQT spectrogram displayed in dB, s, and Hz
Pkg.add("Plots")
using Plots
plotly()
x_labels = [string(round(i/time_resolution, 2)) for i = 1:size(audio_spectrogram, 2)];
y_labels = [string(round(55*2^((i-1)/(12*frequency_resolution)), 2)) for i = 1:size(audio_spectrogram, 1)];
heatmap(x_labels, y_labels, 20*log10.(audio_spectrogram))
```
"""
function cqtspectrogram(audio_signal, sample_rate, time_resolution, cqt_kernel)

    # Number of time samples per time frame
    step_length = round(Int64, sample_rate/time_resolution);

    # Number of time frames
    number_times = floor(Int64, length(audio_signal)/step_length);

    # Number of frequency channels and FFT length
    number_frequencies, fft_length = size(cqt_kernel);

    # Zero-padding to center the CQT
    audio_signal = [zeros(ceil(Int64, (fft_length-step_length)/2),1); audio_signal;
    zeros(floor(Int64, (fft_length-step_length)/2),1)];

    # Initialize the spectrogram
    audio_spectrogram = zeros(number_frequencies, number_times);

    # Loop over the time frames
    for time_index = 1:number_times

        # Magnitude CQT using the kernel
        sample_index = step_length*(time_index-1);
        audio_spectrogram[:, time_index] = abs.(cqt_kernel * fft(audio_signal[sample_index+1:sample_index+fft_length]));

    end

    return audio_spectrogram

end