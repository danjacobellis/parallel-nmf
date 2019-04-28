"""
adapted from https://github.com/zafarrafii/Z (updated for compatibility with julia 1.1)

cqt_kernel = z.cqtkernel(sample_rate, frequency_resolution, minimum_frequency, maximum_frequency);

Compute the constant-Q transform (CQT) kernel
# Arguments:
- `sample_rate::Float` the sample rate in Hz
- `frequency_resolution::Integer` the frequency resolution in number of frequency channels per semitone
- `minimum_frequency::Float`: the minimum frequency in Hz
- `maximum_frequency::Float`: the maximum frequency in Hz
- `cqt_kernel::Complex`: the CQT kernel [number_frequencies, fft_length]
# Example: Compute and display the CQT kernel
```
# CQT kernel parameters
sample_rate = 44100;
frequency_resolution = 2;
minimum_frequency = 55;
maximum_frequency = sample_rate/2;
# CQT kernel
include("z.jl")
cqt_kernel = z.cqtkernel(sample_rate, frequency_resolution, minimum_frequency, maximum_frequency);
# Magnitude CQT kernel displayed
Pkg.add("Plots")
using Plots
plotly()
heatmap(abs.(cqt_kernel))
```
"""
function cqtkernel(sample_rate, frequency_resolution, minimum_frequency, maximum_frequency)

    # Number of frequency channels per octave
    octave_resolution = 12*frequency_resolution;

    # Constant ratio of frequency to resolution (= fk/(fk+1-fk))
    quality_factor = 1/(2^(1/octave_resolution)-1);

    # Number of frequency channels for the CQT
    number_frequencies = round(Int64, octave_resolution*log2(maximum_frequency/minimum_frequency));

    # Window length for the FFT (= window length of the minimum frequency = longest window)
    fft_length = nextpow(2,ceil(Int64, quality_factor*sample_rate/minimum_frequency));

    # Initialize the kernel
    cqt_kernel = zeros(ComplexF64, number_frequencies, fft_length);

    # Loop over the frequency channels
    for frequency_index = 1:number_frequencies

        # Frequency value (in Hz)
        frequency_value = minimum_frequency*2^((frequency_index-1)/octave_resolution);

        # Window length (nearest odd value because the complex exponential will have an odd length, in samples)
        window_length = 2*round(Int64, quality_factor*sample_rate/frequency_value/2)+1;

        # Temporal kernel (without zero-padding, odd and symmetric)
        temporal_kernel = hamming(window_length).*
        exp.(2*pi*im*quality_factor*(-(window_length-1)/2:(window_length-1)/2)/window_length)/window_length;

        # Pre and post zero-padding to center FFTs
        temporal_kernel = [zeros(1, convert(Int64, (fft_length-window_length+1)/2)),
        temporal_kernel', zeros(1, convert(Int64, (fft_length-window_length-1)/2))];
        
        temporal_kernel = hcat(temporal_kernel...);

        # Spectral kernel (mostly real because temporal kernel almost symmetric)
        # (Note that Julia's fft equals the complex conjugate of Matlab's fft!)
        spectral_kernel = fft(temporal_kernel);

        # Save the spectral kernels
        cqt_kernel[frequency_index, :] = spectral_kernel;

    end

    # Energy threshold for making the kernel sparse
    energy_threshold = 0.01;

    # Make the CQT kernel sparser
    cqt_kernel[abs.(cqt_kernel).<energy_threshold] .= 0;

    # Make the CQT kernel sparse
    cqt_kernel = sparse(cqt_kernel);

    # From Parseval's theorem
    cqt_kernel = conj(cqt_kernel)/fft_length;

end
