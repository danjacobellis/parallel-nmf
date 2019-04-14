# Parallel Non-negative Matrix Factorization

## Contents

---
``nnmf.jl`` - Performs factorization on GPU using multiplicitive update rule.

usage:
~~~
include("nnmf.jl")
W,H =nnmf(V,num_components, num_iterations)
~~~

---
``benchmark.ipynb`` - Summary of basic timing benchmarks

---
``docs``
- Project proposal
- Report (TODO)
- Slides for presentation (TODO)

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
 

