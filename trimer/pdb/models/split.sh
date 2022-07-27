#!/bin/bash
# split a multi-model pdb file into individual files
#
# https://strucbio.biologie.uni-konstanz.de/ccp4wiki/index.php/Split_NMR-style_multiple_model_pdb_files_into_individual_models

# this dosen't get the new pdb formatting right
#i=1
#while read -a line; do
#  echo "${line[@]}" >> model_${i}.pdb
#  [[ ${line[0]} == ENDMDL ]] && ((i++))
#done < ../2m8l.pdb

# write awk script
cat << EOF > split.awk
BEGIN {file = 1; filename = "model_"  file ".pdb"}
/ENDMDL/ {getline; file ++; filename = "model_" file ".pdb"}
{print \$0 > filename}
EOF

# run awk script
awk -f split.awk < ../2m8l.pdb
