# Noise Characterization of Digital Mammography Systems

MATLAB toolbox for quantitative noise characterization of digital mammography (DM) systems based on variance decomposition and spatial-spectral analysis.

This repository contains the MATLAB implementation developed for the manuscript:

> **Noise Characterization of Digital Mammography Systems Based on Variance Decomposition and Spatial-Spectral Analysis**

which is currently being prepared for submission to the **XXIX Brazilian Congress on Biomedical Engineering (CBEB 2026)**.

The toolbox implements a complete workflow for detector noise characterization using homogeneous calibration images, following quality control methodologies established in the literature.

---

## Overview

The implemented methodology provides a comprehensive characterization of detector noise by combining analyses in the variance, spatial, and spectral domains.

The toolbox estimates:

- Detector response linearity;
- Detector gain and offset;
- Structural, quantum, and electronic noise parameters;
- Spatial distribution of the quantum noise coefficient;
- Normalized spatial correlation kernel;
- Posterior-anterior (PA) signal-to-noise ratio (SNR);
- Normalized Noise Power Spectrum (NNPS).

These analyses can be used for detector characterization, quality control, image quality assessment, and image processing research in digital mammography.

---

## Repository structure

```text
.
├── Functions/
│   ├── estimate_response_linearity.m
│   ├── estimate_xi_s_xi_q_xi_e.m
│   ├── estimate_xi_qi_map.m
│   ├── estimate_kernel.m
│   ├── estimate_nnps.m
│   ├── plot_snr_profiles.m
│   ├── plot_nnps_profiles.m
│   ├── loadCalibrationImages.m
│   ├── EvalSNR.m
│   └── eval_snr.m
│
├── Uniform Images/
│   ├── Siemens/
│   └── GE/
│
├── Noise Parameters/
│   ├── Siemens/
│   └── GE/
│
├── main_est.m
├── Noise_analysis_GE.m
└── Noise_analysis_Siemens.m
```

---

## Processing workflow

The complete detector characterization is performed by running

```matlab
main_est
```

The workflow consists of the following steps:

1. Load homogeneous calibration images.
2. Estimate detector gain (*g*) and detector offset (*τ*).
3. Estimate the structural (*ξₛ*), quantum (*ξ_q*), and electronic (*ξₑ*) noise parameters.
4. Estimate the spatial map of the quantum noise coefficient (*ξ_q(i,j)*).
5. Estimate the normalized spatial correlation kernel.
6. Compute posterior-anterior (PA) SNR profiles.
7. Compute the normalized noise power spectrum (NNPS).
8. Save the estimated detector parameters.

---

## Supported systems

The current repository contains calibration datasets from two commercial digital mammography systems:

- Siemens Mammomat Fusion (direct-conversion a-Se detector)
- GE Senographe Pristina (indirect-conversion a-Si/CsI detector)

To select the desired system, edit the corresponding section of **main_est.m**.

Example:

```matlab
System = 'GE';
mAsVals = [18 25 36 50 100];
kVpVals = 34;
pixelSize_mm = 0.10;
```

or

```matlab
System = 'Siemens';
mAsVals = [4 11 20 40 80];
kVpVals = 26;
pixelSize_mm = 0.083;
```

---

## Output parameters

The toolbox estimates the following detector parameters:

| Parameter | Description |
|-----------|-------------|
| **g** | Detector gain |
| **τ** | Detector offset |
| **ξₛ** | Structural noise parameter |
| **ξ_q** | Quantum noise parameter |
| **ξₑ** | Electronic noise parameter |
| **ξ_q(i,j)** | Spatial map of the quantum noise coefficient |
| **Kₙ** | Normalized spatial correlation kernel |
| **NNPS** | Normalized Noise Power Spectrum |
| **PA-SNR** | Posterior-anterior SNR profiles |

The estimated detector parameters are automatically saved as MATLAB (`*.mat`) files inside

```text
Noise Parameters/
```

for subsequent image simulation and processing.

---

## Requirements

The toolbox was developed and tested using

- MATLAB **R2025b**
- Image Processing Toolbox
- Curve Fitting Toolbox

Although the code should also run on recent MATLAB releases, MATLAB R2025b is the reference version used during development and validation.

---

## Future developments

Planned improvements include:

- Python implementation of the complete toolbox;
- Support for additional detector technologies;
- Additional image quality metrics;
- Extended examples and tutorials.

A Python version of this toolbox will be made publicly available in a future release.

---

## License

This project is distributed under the MIT License.

---

## Contact

If you have questions, suggestions, or would like to report an issue, please open an Issue in this repository.
