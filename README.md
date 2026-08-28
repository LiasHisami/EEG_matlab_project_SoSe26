## Current analysis goal

For the minimum viable analysis, we are currently focusing on H1: the effect of physical stimulation intensity on the somatosensory ERP (P50 response in particular)
The experiment contains two stimulation intensities: low-intensity and high-intensity stimulation

The analysis currently compares the EEG response to these two conditions.
If we have time, we can extend the analysis to H2 concerning standards/deviants in the roving paradigm.


## Data
**Important**: When downloading the raw data from the link Gian sent us, we are **GROUP 2**.
It's a bit confusing because the EEG/behavioural data are labelled ID01 although we are Group 2.
https://box.fu-berlin.de/s/wcqaegfkdkMZo3E?dir=/Group2

So in summary:
- for 00Behavioral and 01EEG, our participant is labelled ID01
- for 05Anat, our participant is labelled Group2_defaced.nii


## Requirements
MATLAB, SPM for EEG/MEG analysis, FieldTrip functions accessible from MATLAB/SPM
Brewermap?

The custom bad-channel interpolation and data-display functions use FieldTrip functions such as ft_databrowser, ft_redefinetrial, and ft_channelrepair.

Perhaps we should ideally use the same SPM version, and agree on one version?
All group members should ideally use the same SPM version. Add the exact agreed version here once confirmed



## Notes

First ideas for things we could still check/do:

- **Path handling**
  - scripts currently contain absolute paths that are specific to one laptop
  - For now, these can be adapted manually by each group member so that we can first check whether the pipeline runs correctly on different computers
  - Once the pipeline has been verified, we should replace the laptop-specific absolute paths with relative/project-based paths so that the scripts can be used without manually changing every file path

- **Bad-channel handling**
  - so far, the script asks the user to visually determine and enter the bad channels themselves
  - means different people could identify different channels
  - we should decide which channels are considered bad and why and ideally code this consistently into the script? -> already done, bad channel is CP3 and parts of O2 and CP5 (todo: check if those channels are removed in artefact detection part)

- **ERP region of interest (ROI)**
  - we should determine which electrodes constitute our ROI and justify this choice based on current literature

- **P50 time window**
  - we need to define exactly which time period counts as the P50, for example `50–70 ms` after stimulation
  - instead of comparing the EEG amplitude at exactly 50 ms, we can calculate the average amplitude within this time window, which gives us a more stable measure of the P50? -> maybe not necessary because we do the statistical analysis anyways, for descriptive comparison we can look at example report how they did it)

- **Final statistical analysis**
  - we still need to decide how we will statistically compare the High- and Low-intensity conditions for H1 -> like in tutorial part 'Sensor space analysis' see https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/MEEG/mmn/:
 
    "A useful feature of SPM is the ability to use Random Field Theory to correct for multiple statistical comparisons across N-dimensional spaces [...] This would allow one to identify locations where, for example, the ERP amplitude in two conditions at a given timepoint differed reliably across subjects, having corrected for the multiple t-tests performed across pixels. That correction uses Random Field Theory, which takes into account the spatial correlation across pixels (i.e, that the tests are not independent)"
 
    Steps of statistical analysis:
    1. Convert EEG data to scalp x time nifty images -> a 3D image for each trial of the two types with time as third dimension;  
    2. We then take these images into an unpaired t-test across trials (in a 2nd-level model) to compare the two events
    3. We can then use classical SPM to identify locations in space and time in which a reliable difference occurs, correcting across the multiple comparisons entailed
   
   Tutorial for detailed implementation:
      Select ‘Convert to images’ from the ‘Images’ dropdown menu. In the batch tool that will appear select the aefdfMspmeeg_subject1.mat as input. For the ‘Mode’ option select ‘scalp x time’. In the ‘Channel selection’ option delete the default choice (‘All’) and choose ‘Select channels by type’ with ‘EEG’ as the type selection. You can now run the batch.
    
    SPM will take some time as it writes out a NIfTI image for each condition in a new directory called aefdfMspmeeg_subject1. In our case there will be two files , called condition_rare and condition_standard. These are 4D files, meaning that each file contains multiple 3D scalp x time images, corresponding to non-rejected trials. You can press “Display: images” to view one of these images. Change the number in the ‘Frames’ box to select a particular trial (first trial is the default). The image will have dimensions 3232101.
    
    To perform statistical inference on these images:
    
    - Create a new directory, eg. mkdir XYTstats.
    
    - Press the “Specify 2nd level” button.
    
    - Select “two-sample t-test” (unpaired t-test)
    
    - Define the images for “Group 1” as all those in the file condition_standard. To do that write ‘standard’ in the ‘Filter’ box and ‘Inf’ in the ‘Frames’ box of the file selector. All the frames will be shown. Right click on any of the frames in the list and choose ‘Select all’. Similarly for “Group 2” select the images from condition_rare file.
    
    - Finally, specify the new XYTstats directory as the output directory.
    
    - Press the “save” icon, top left, and save this design specification as mmn_design.mat and press “save”.
    
    - Press the green “Run” button to execute the job4 This will produce the design matrix for a two-sample t-test.
    
    - Now press “Estimate” in SPMs main window, and select the SPM.mat file from the XYTstats directory. 

    - Now press “Results” and define a new F-contrast as [1 -1] (for help with these basic SPM functions, see eg. chapter [Chap:data:auditory]). Keep the default contrast options, but threshold at  FWE p < 0.05 corrected for the whole search volume and select “Scalp-Time” for the “Data Type”. Then press “whole brain”, and the Graphics window should now look like that in Figure 1.3. This reveals a large fronto-central region within the 2D sensor space and within the time epoch in which standard and rare trials differ reliably, having corrected for multiple F-tests across pixels/time. An F-test is used because the sign of the difference reflects the polarity of the ERP difference, which is not of primary interest.
 
      
---


## Suggested local folder structure

After cloning the repository, the suggested structure is:

```text
EEG_project_SoSe26/
│
├── original_data/
│   ├── 00Behavioral/
│   ├── 01EEG/
│   └── 05Anat/
│
├── preprocessed/
│
├── preprocessing.m
├── generate_avref.m
├── spm_interpolate_bad_channels.m
├── display_SPM_data.m
├── plot_preprocessing.m
├── plot_ERP.m
├── README.md
└── .gitignore
```

The folders original_data/ and preprocessed/ are local folders and should be excluded from GitHub through .gitignore


## Before running the analysis
- Clone or download this repository.
- Download the Group 2 raw data separately.
- Place the downloaded data inside the original_data/ folder as shown above.
- Make sure SPM is installed.
- In the MATLAB scripts, set spm_path to the location of SPM on your own computer.
- Make sure the expected .bdf and .sfp files can be found.
- Do not change preprocessing parameters without informing the rest of the group

---

# Scripts

## `preprocessing.m`

This is the **main EEG preprocessing pipeline**.
It is based on the official SPM MMN tutorial https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/MEEG/mmn/ and on the course EEG Data analysis of the program Cognitive Neuroscience at FU Berlin given be Gianluigi Giannini and Prof. Felix Blankenburg

Currently does:
1. BDF → SPM conversion
2. Assignment of the external channels as EOG channels
3. Loading of EEG sensor positions
4. Inspection and interpolation of bad channels
5. Average-reference montage
6. 0.1 Hz high-pass filtering
7. Downsampling to 200 Hz
8. 30 Hz low-pass filtering
9. Eye-blink detection/correction
10. Epoching from -100 to 400 ms
11. Artefact rejection
12. Averaging by condition
13. Final low-pass filtering

---

## `spm_interpolate_bad_channels.m`

Helper function called by `preprocessing.m`.

- displays the EEG data,
- asks the user to enter bad-channel labels,
- interpolates selected channels using spline interpolation,
- saves the interpolated SPM dataset.

**This file does not normally need to be run separately.**

---

## `generate_avref.m`

Generates: `avref.mat`

Contains the **average-reference montage** required by the montage stage of `preprocessing.m`.

With the current pipeline, this script must be run **after conversion/bad-channel interpolation and before the Montage section of `preprocessing.m`**.

---

## `display_SPM_data.m`

Helper function for visual inspection of continuous or epoched SPM EEG data.

Mainly intended for:
- quality control
- checking artefacts
- debugging

It does not normally need to be run as part of the main pipeline.

---

## `plot_preprocessing.m`

Quality-control and visualisation script showing the effect of successive preprocessing stages on an example EEG channel.
Run this **after the preprocessing pipeline has produced the required intermediate files**.
This script is optional for the main analysis but useful for checking the preprocessing.

---

## `plot_ERP.m`

Loads the final averaged EEG data and plots the **High- and Low-intensity ERPs** over the current right-hemisphere ROI.
Run this **after preprocessing has been completed**.

---

# Current execution order

> [!IMPORTANT]
> The current version of the pipeline cannot yet be run completely from top to bottom without interruption because `generate_avref.m` requires an interpolated SPM file, while the Montage section of `preprocessing.m` already expects `avref.mat` to exist.

For now, use the following order.

## 1. Start `preprocessing.m`

Run the following sections:

- `Setting Paths`
- `Loading and Converting Data`
- `Interpolating Bad Channels`

Then **stop before the `Montage` section**.

---

## 2. Run `generate_avref.m`

This creates:

`avref.mat`

---

## 3. Return to `preprocessing.m`

Continue running the script starting from:

`Montage`

and proceed through the end of the preprocessing pipeline.

---

## 4. Run `plot_preprocessing.m` — optional

Use this to inspect the effects of the different preprocessing stages.

---

## 5. Run `plot_ERP.m`

Use this to visualise the final **High vs Low** ERP comparison for H1.

---

## Helper functions

The following files are helper functions and are **not separate preprocessing stages**:

- `spm_interpolate_bad_channels.m`
- `display_SPM_data.m`

---

# Current H1 analysis

The current minimum viable analysis focuses on the effect of **physical stimulation intensity**.

The two conditions are:

- `High`
- `Low`

The current ERP plotting script averages activity across the selected right-hemisphere ROI and compares the ERP time courses between these two conditions.

The main component of interest is the **P50**.

---

# Possible future extension: H2

If we have time, nalysis may later be extended to distinguish stimuli according to both:

1. **Physical intensity**
   - High
   - Low

2. **Roving-paradigm status**
   - Standard
   - Deviant

This would result in four conditions:

| Intensity | Status |
|---|---|
| High | Standard |
| High | Deviant |
| Low | Standard |
| Low | Deviant |

---


