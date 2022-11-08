# Registration Overview

## Summary of registrations (Figure 1)

**You will need to segment the Allen Brain Atlas so it is suitable for brain slice registration. [reslice_dorsal_HPC.ijm](python/25um_ABA/reslice_dorsal_HPC.ijm) is an example macro used to segment both the annotation.nrrd and average_template.nrrd files so they are suitable for registration to coronal dorsal hippocampal brain slices.**

**An [environment .yml file](python/environment.yml) is provided to create an Anaconda environment to run brain slice registration.**

![image](https://user-images.githubusercontent.com/67151814/200411809-766299aa-8e28-4ed0-a41f-3771c9c3f4ae.png)

**Figure 1. Overview of brain slice registration. (A) Affine and b-spline transformations are applied to the Allen Common Coordinate Framework version 3 (CCFv3) reference image to match brain slice autofluorescence image. Transformation parameters are produced after a successful transform (green arrow). (B) Transformation parameters generated in (A) are then applied to the CCFv3 annotations image, producing a transformed image spatially aligned to the brain slice autofluorescence image. (C) Transformed annotations from (B) aligns spatially with brain slice autofluorescence image (overlay) – allowing the experimenter to quantitatively assess anatomical regions within the brain slice.**

