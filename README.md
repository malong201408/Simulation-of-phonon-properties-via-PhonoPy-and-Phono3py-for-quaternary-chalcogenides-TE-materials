# Simulation-of-phonon-properties-via-PhonoPy-and-Phono3py-for-quaternary-chalcogenides-TE-materials
This repository shows the code used to calculate phonon band structure, Gruneissen, scattering rate, and kappa by using Circe and VASP

Before initiating the code, put all files and the folder ###_VASP_init together. The file can only process in Circe ./work folder

Edit the init file for your structure. The first line is the name and phase of the structure, the second line is the location of the pseudopotentials. the third line is the atomic composition in sequence (they have to be in the same order as it is in the POSCAR file. The 4th and 5th lines are the supercell sizes for the second-order and third-order force constants calculation. The 6th line is the phonon band‑structure path of 6 q‑points. The 7th line is a tag copied into VASP’s INCAR, describing its magnetic properties (i.e. 648 atoms, all with zero starting magnetic moment and non‑magnetic in this case) The last line is for how many nearest bodies can be seen in phonon calculation. A convergence test needs to do for the selection. 


To run the code. First go to the POSCAR folder in ###_VASP_init folder and Add your structure POSCAR there. The name has to be consistent with the name in the init file

Then run files with numbers. 2-5 are doing the lattice relaxation. 6 and 7 calculate the electronic DOS and band structure. If the lattice is not thermally stable after 5_Full_Relax2 (No local parabolic minimum in the expanded (compressed) volume). It's mandatory to run 8 and 9 for finest mesh. 

After that, Run Phonon1_Gen and Phonon2_Band to obtain lattice phonon band structure and DOS. 

Run Phonon4_Gruneissen and Phonon5_Gruneissen_Cal to obtain the Gruneissen parameter. 

Run Sub_Phono3py1 to generate the folders for kappa calculation. Run Sub_Phono3py2_FC2_Cut and Sub_Phono3py2_FC3_Cut separately to calculate the harmonic and anharmonic force constants (FC2 FC3)

Ultimately, a file named after Cut6_kappa-m666.hdf5 is obtained, which can be used to plot the kappa and the scattering rate


