# SiSt_recogniser
Probabilistic framework for recognition of sit-to-stand activities and transition phases.

This work is part of the project 'Wearable soft robotics for independent living' funded by EPSRC and maintained by the School of Mechanical Engineering, the University of Leeds, UK.

The data used in this repository was collected from a wearable sensor (IMU Shimmer Inc.) attached to the thigh of multiple participants. The data collected are composed of acceleration measurements while sitting, standing and transitioning from sit to stand. Testing and training datasets were prepared for validation of the SiSt_recogniser. 


## File structure
- Bayesian_classifier\\
  - Bayesian_classifier.m
  - controller.m
  - run_classifier.m
  - test_program.m

- sample_data\\
  - 3state1transitionPhases\\
  - 3state2transitionPhases\\
  - 3state3transitionPhases\


## Running the scripts for recognition of SiSt activity and transition phases
The first step is to generate the recognition results for SiSt activity. For this process, you need to run the script 'test_program.m', which internally calls the rest of script located in Bayesian_classifier folder. Before running the test script, you need to specified the path to read the data collected from the wearable sensor. This details can be set in lines 30 and 31 in 'test_program.m' file as follows:

**In test_program.m**

**_path = '..\sample_data';_**

**_folder_name = '3state2transitionPhases';_**


This example shows that the data in 'sample_data' folder will be used, which is prepared with 3 states (sit, stand and transition) and 2 transition phases. Once this information is defined in the MATLAB script, then you can run the test script in the console as follows:

**In MATLAB console**

**_test_program.m_**

This program will generate multiple output files containing the recognition results. The script generates 6 output files, however, the number of files can be configured using the variables _minHistBin_, _maxHistBin_ and _stepHistAnalysis_. By default, this variables are set as follows: _minHistBin = 50_, _maxHistBin = 100_ and _stepHistAnalysis = 10_ which generated 6 output files ([50:10:100] -> 6 file).

The output files can be used to analyse the accuracy of the recognition results and generate confusion matrices. These processes are shown in the following section.



## Visualisation of results with confusion matrices
To visualise the recognition results from SiSt activity and transition phases, first ensure that you have run the 'test_program.m' script and that the output recognition files were generated. Then, you just need to run the 'plot_confusion_matrices.m' script to observe the accuracy achieved by the SiSt_recogniser through the generation of confusion matrices as follows:

**In MATLAB console**

**_plot_confusion_matrices.m_**

In order to successfully run the plot script, you need to move in to the folder where the recognition results were generated.


## Contributors
This work is maintained by the following researchers:

- Uriel Martinez-Hernandez
- Abbas A. Dehghani-Sanij

## Version
SiSt_recogniser v1.0

This repository was updated the 19/02/2018
