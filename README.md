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
   - CQT function - to generate time-frequency decomosition
   - nnmf function - for benchmark comparisons
 - Scikit-learn
   - decomposition.nmf -for benchmark comparisons
 
 [1]:https://github.com/JuliaGPU/CuArrays.jl
 

