# Simulation-of-phonon-properties-via-PhonoPy-and-Phono3py-for-quaternary-chalcogenides-TE-materials
This repository shows the code used to calculate phonon band structure, Gruneissen, scattering rate, and kappa by using Circe and VASP

Before initiating the code, put all files and the folder ###_VASP_init together. The file can only process in Circe ./work folder

Edit the init file for your structure. The first line is the name and phase of the structure, the second line is the location of the pseudopotentials. the third line is the atomic composition in sequence (they have to be in the same order as it is in the POSCAR file. The 4th and 5th lines are the supercell sizes for the second-order and third-order force constants calculation. The 6th line is the phonon band‑structure path of 6 q‑points. The 7th line is a tag copied into VASP’s INCAR, describing its magnetic properties (i.e. 648 atoms, all with zero starting magnetic moment and non‑magnetic in this case) The last line is for how many nearest bodies can be seen in phonon calculation. A convergence test needs to do for the selection. 


To run the code. 
