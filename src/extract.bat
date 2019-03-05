cd\
cd c:\software ag\adabas
del DCUFDT,DCUOUT,DCUDTA,ULDDVT,emp_natpemu.txt
ADAULD DBID=161,FILE=11,FDT
RENAME ULDDTA DCUDTA
ADADCU DCUFDT,MUPE_C_L=1,MUPE_OCCURRENCES > emp_natpemu.txt
type emp_natpemu.txt