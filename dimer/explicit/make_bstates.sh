# create multiple rst files from nc prod sim data
# note each prod was 200ns 06-10

parm 4xfx_sep_solv.prmtop
trajin 08_prod.nc
unwrap :1-462
center :1-462 mass origin
image origin center familiar
trajout 08_prod_dry.nc
go
quit
