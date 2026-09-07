## Current analysis goal

For the minimum viable analysis, we are currently focusing on H1: the effect of physical stimulation intensity on the somatosensory ERP (P50 response in particular)
The experiment contains two stimulation intensities: low-intensity and high-intensity stimulation

The analysis currently compares the EEG response to these two conditions.
TODO: If we have time, we can extend the analysis to H2 concerning standards/deviants in the roving paradigm.


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

used version: SPM25

## Preprocessing:
--> see preprocessing plots for CP3 (bad interpolated channel) and C4 (of interest for our P50 Hypothesis) and maybe AFz (due to eye blink detection)

### Bad-channel handling

**ID01:** 
- Bad channel is CP3 -> interpolated
- Parts of O2 and CP5 are also bad (from around 1600s to 2020s)
    -> removed during artefact detection (one long section from trial 1031 to 1274 (total around 244 ) see below 'Artefact detection'

**For all additional participants:**
  - TODO: decide which channels are considered bad

### Montage

- Uses 'avref-eog.mat' file (generated through GUI in SPM)
- average referencing + combining VEOG and HEOG channels into one channel respectively

### High-pass filter

- 0.1 Hz

### Downsampling

- from original 1024 Hz to 200 Hz

### Low-pass filter

- 30 Hz

### Eye blink removal

- creating epoched events around eyeblinks and then averaging
->see plots for eye blink detection

### Epoching

#### H1

- time window: -100 to 400 ms
- conditions:
  - High : 1650 trials
  - Low :  1697 trials
Total:     3347 trials

+ Baseline correction: 1

#### H2

- TODO....

### Artefact detection

**ID01:**

461 rejected trials:

bad trials rejected: 
118   121   159   169   208   209   237   323   351   374   375   376   379   452   453   542   635   643   649   656   709   724   725   726   750   767   780   811   817   818   819   846   873   904   949   981  1031  1033  1034  1035  1036  1037  1038  1039  1040  1041  1042  1043  1044  1045  1046  1047  1048  1049  1050  1051  1052  1053  1054  1055  1056  1057  1058  1059  1060  1061  1062  1063  1064  1065  1066  1067  1068  1069  1070  1071  1072  1073  1074  1075  1076  1077  1078  1079  1080  1081  1082  1083  1084  1085  1086  1087  1088  1089  1090  1091  1092  1093  1094  1095  1096  1097  1098  1099  1100  1101  1102  1103  1104  1105  1106  1107  1108  1109  1110  1111  1112  1113  1114  1115  1116  1117  1118  1119  1120  1121  1122  1123  1124  1125  1126  1127  1128  1129  1130  1131  1132  1133  1134  1135  1136  1137  1138  1139  1140  1141  1142  1143  1144  1145  1146  1147  1148  1149  1150  1151  1152  1153  1154  1155  1156  1157  1158  1159  1160  1161  1162  1163  1164  1165  1166  1167  1168  1169  1170  1171  1172  1173  1174  1175  1176  1177  1178  1179  1180  1181  1182  1183  1184  1185  1186  1187  1188  1189  1190  1191  1192  1193  1194  1195  1196  1197  1198  1199  1200  1201  1202  1203  1204  1205  1206  1207  1208  1209  1210  1211  1212  1213  1214  1215  1216  1217  1218  1219  1220  1221  1222  1223  1224  1225  1226  1227  1228  1229  1230  1231  1232  1233  1234  1235  1236  1237  1238  1239  1240  1241  1242  1243  1244  1245  1246  1247  1248  1249  1250  1251  1252  1253  1254  1255  1256  1257  1258  1259  1260  1261  1262  1263  1264  1265  1266  1267  1268  1269  1270  1271  1272  1273  1274  1307  1410  1548  1601  1604  1614  1618  1619  1636  1640  1644  1645  1647  1650  1654  1660  1661  1662  1667  1668  1669  1670  1674  1676  1680  1682  1685  1687  1688  1692  1694  1696  1697  1704  1710  1711  1713  1716  1718  1735  1738  1749  1758  1764  1773  1774  1775  1776  1785  1786  1815  1823  1828  1832  1834  1838  1848  1849  1853  1861  1877  1884  1886  1894  1904  1935  1960  1961  1962  1963  1964  1966  1982  2005  2017  2031  2041  2047  2049  2064  2073  2219  2220  2226  2233  2235  2247  2276  2278  2279  2307  2341  2360  2365  2372  2373  2379  2380  2381  2437  2438  2463  2494  2495  2496  2497  2499  2502  2503  2639  2666  2693  2694  2695  2696  2697  2698  2699  2700  2702  2703  2704  2705  2706  2707  2708  2709  2710  2730  2731  2798  2799  2802  2805  2806  2811  2827  2829  2833  2834  2835  2843  2856  2868  2965  3002  3003  3004  3005  3006  3007  3008  3009  3010  3012  3013  3017  3018  3019  3020  3021  3023  3027  3030  3031  3039  3040  3044  3046  3047  3048  3049  3050  3051  3099  3129  3131  3208  3217  3222  3234  3253

### Additional steps for descriptive analysis

- Averaging and Reapplied Low pass filtering

## Descriptive analysis

**ID01 H1:**

- Topographic plots around P50 (see plots folder)

- ERP
  - Electrodes that constitute our ROI: {'FC4', 'CP4', 'C4', 'C6'} (based on topography plot, might need to be changed for other participants and for H2)
 

## Final statistical analysis

**ID01 H1:**
  - done as in spm tutorial see https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/MEEG/mmn/:

  - testing hypothesis using a three-dimensional scalp-time map based on a t-contrast testing for high > low, applying SPM’s random field theory-based family-wise error rate correction with a p-value criterion of .05, which takes into account the spatial correlation across pixels
 
    Steps of statistical analysis:
    1. Convert EEG data to scalp x time nifty images -> a 3D image for each trial of the two types with time as third dimension;  
    2. We then take these images into an unpaired t-test across trials (in a 2nd-level model) to compare the two events
    3. We can then use classical SPM to identify locations in space and time in which a reliable difference occurs, correcting across the multiple comparisons entailed
   
   SPM tutorial for detailed implementation of statistical analysis:
  
     - Select ‘Convert to images’ from the ‘Images’ dropdown menu. In the batch tool that will appear select the aefdfMspmeeg_subject1.mat as input. For the ‘Mode’ option select ‘scalp x time’. In the ‘Channel selection’ option delete the default choice (‘All’) and choose ‘Select channels by type’ with ‘EEG’ as the type selection. You can now run the batch.
      
     - SPM will take some time as it writes out a NIfTI image for each condition in a new directory called aefdfMspmeeg_subject1. In our case there will be two files , called condition_rare and condition_standard. These are 4D files, meaning that each file contains multiple 3D scalp x time images, corresponding to non-rejected trials. You can press “Display: images” to view one of these images. Change the number in the ‘Frames’ box to select a particular trial (first trial is the default). The image will have dimensions 3232101.
      
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

## 1. Run `preprocessing.m`

Use this to preprocess EEG Data. 
Bad channels need to be written into the console when asked ({'CP3'} for ID01
If you want to inspect the data to check for bad channels you can remove the following '%' in 'spm_interpolate_bad_channels' 
`    %ft_databrowser(cfg, data_epoched);  % REMOVE COMMENT IF YOU WANT TO
    %INSPECT THE DATA` (it is commented out to facilitate run time)

---

## 2. Run `plot_preprocessing.m` 

Use this to inspect the effects of the different preprocessing stages.

---

## 3. Run `plot_ERP.m`

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


