# Cell Segmentation

## Summary of Cell Segmentation (Figure 1)

**You will you need to install [bone-J](https://bonej.org/) and [high-pass-gaussian-filter](https://github.com/stevenjwest/High_Pass_Gaussian_Filter) Fiji plug-ins before running cell segmentation.**

![cell_segmentation](https://user-images.githubusercontent.com/67151814/200412946-b8665840-9a80-4e73-a0c7-21f8a1c4e504.png)
**Figure 1. Overview of semi-automated brain slice cell segmentation. Calretinin+ staining in mouse cortex is used as an example. Raw images of cell signal are pre-processed in ImageJ/Fiji to remove imaging artefacts. Background removal steps are performed on the processed raw image using a combination of background removal filters and down-sampling. The filtered image is then thresholded based on pixel intensities using automated thresholding methods. A 3D object counter is used to count objects (or cells) in 3D spaces – this is performed using connected component analysis. Quality control of objects counted is done by comparing the resulting output from the 3D object counter with scaled image. A table is produced by the 3D object counter describing the coordinates of counted objects.**
