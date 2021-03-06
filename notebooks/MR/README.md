# Contents

Jupyter notebooks for the MR exercises. Recommended order:

## Week 1

1. [a_fully_sampled](a_fully_sampled.ipynb) Here an introduction in the SIRF MR reconstrution is made. You will read fully sampled raw data, and reconstruct them by sending them to Gadgetron and retrieving the reconstructed images.

2. [b_kspace_filter](b_kspace_filter.ipynb) demonstrates how to access and process k-space data prior to reconstruction.

3. [c_coil_combination](c_coil_combination.ipynb) shows different approaches for the computation of receiver coil sensitivities from acquired k-space data, as well as how to combine image data from different receiver coils.


## Week 2

1. [d_undersampled_reconstructions](d_undersampled_reconstructions.ipynb) demonstrates different possibilities to reconstruct undersampled data. You will do a GRAPPA reconstruction using Gadgetron and implement your own conjugate-gradient SENSE parallel image reconstruction using the SIRF MR acquisition model. 

2. [e_advanced_recon](e_advanced_recon.ipynb) shows how to do iterative SENSE image reconstruction by combining the SIRF MR acuqisition model with with the scipy package for optimisation.

3. [f_create_undersampled_kspace](f_create_undersampled_kspace.ipynb) demonstrates a retrospective data under-sampling.


## Feel free to ignore

[Old_notebooks](Old_notebooks), [notebook_setup](notebook_setup.py) and [tools](tools) contain examples scripts of SIRF MR reconstruction used in previous training events. Feel free to ignore.