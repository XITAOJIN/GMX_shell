# GMX_shell
Locally run gromacs in a shell script and also supply the .mdp file which is added 2 lines :

comm-grps    = protein     ;

comm-mode   = angular    ;

These two parameter settings can fix your protein-ligand complex in the center of PBC box all the time when running gromacs.
