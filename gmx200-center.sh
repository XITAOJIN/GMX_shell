#!/bin/bash

##    ---------------  作业调度系统相关的配置 -------------------
#SBATCH -p gpu			## 运行在GPU节点，无需改动
#SBATCH -J GD-AN1801_JXT		## 任务名称，可自定义
#SBATCH -n 30			## 计算所用CPU核心数，可自定义
#SBATCH --gpus 1		## 指定所需的GPU卡数量，默认是1
#SBATCH -o %J.out.txt		## 标准输出，文件名称可自定义
#SBATCH -e %J.err.txt		## 标准错误输出，文件名称可自定义

##    ---------------  gmx相关的环境变量加载 -------------------
## 加载gmx运行所需要的环境
scl enable gcc-toolset-9 bash
source /share/software/profile.d/cuda_11.8.0.sh
source /opt/gromacs/gromacs-2023.4_cuda11.8.0/bin/GMXRC.bash

##    ---------------  gmx运行相关的命令 -------------------
#protein to energy minim-AMBER14sb+tip3p

echo 2|gmx pdb2gmx -f $1 -o pro_processed.gro -water tip3p -ignh  
gmx editconf -f pro_processed.gro -o pro_newbox.gro -c -bt cubic -d 1.0
gmx solvate -cp pro_newbox.gro -cs spc216.gro -o pro_solv.gro -p topol.top
gmx grompp -f ions.mdp -c pro_solv.gro -p topol.top -o ions.tpr -maxwarn 1
echo 13| gmx genion -s ions.tpr -o pro_solv_ions.gro -p topol.top -pname NA -nname CL -neutral -conc 0.15
gmx grompp -f minim.mdp -c pro_solv_ions.gro -p topol.top -o em.tpr -maxwarn 1
gmx mdrun -v -deffnm em

#NVT+NPT

gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr
gmx mdrun  -deffnm nvt
echo 16 0|gmx energy -f nvt.edr -o temperature.xvg
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr
gmx mdrun  -deffnm npt
echo 18 0|gmx energy -f npt.edr -o pressure.xvg
gmx grompp -f md200-center.mdp -c npt.gro -t npt.cpt -p topol.top -o md200 -maxwarn 2

#mdrun and RMS

gmx mdrun  -deffnm md200 -v
echo 4|gmx rmsdist -f md200.xtc -s md200.tpr -o rmsd200.xvg

