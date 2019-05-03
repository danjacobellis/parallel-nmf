# Parallel Non-negative Matrix Factorization

## Contents

---
``AudioNMF.jl`` - Main module


usage:
~~~
include("AudioNMF.jl");
using .AudioNMF
~~~

---
``source_separation.ipynb`` - Exmple demonstrating:

 - Conversion of an audiofile into the $V$ matrix
 - Performing the factorization
 - Permuting $W$ and $H$ in ascending note order
 - Writing audio files containing a subset(s) of the components

---
``docs``
- Project proposal
- Progress report
- Final Report
- Slides for presentation

---
``data``
- ``*.mid`` - midi files used to generate audio
- ``*.wav`` - example audio recordings with different instruments and with both monophonic an polyphonic melodies

---
``experiments`` - Contains code used to prototype and test algorithms

## Requirements
 - Julia 1.11
 - [CuArrays.jl][1]
 - MATLAB
   - [CQT function][2] - to generate time-frequency decomosition
   - [nnmf function][3] - for benchmark comparisons
 - Scikit-learn
   - [decomposition.nmf][4] -for benchmark comparisons
 - [MATLAB.jl][5]
 - [MAT.jl][6]
 
 [1]:https://github.com/JuliaGPU/CuArrays.jl
 [2]:https://www.mathworks.com/help/wavelet/ref/cqt.html
 [3]:https://www.mathworks.com/help/stats/nnmf.html
 [4]:https://scikit-learn.org/stable/modules/generated/sklearn.decomposition.NMF.html
 [5]:https://github.com/JuliaInterop/MATLAB.jl
 [6]:https://github.com/JuliaIO/MAT.jl
 

