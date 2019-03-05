# Migration of ADABAS DB (for Windows) to RDBMS

## Overview:
This details a technical migration process (implementation/pseudo code) of a popular database (ADABAS, a Software AG product) for windows into RDBMS (both Layout/Data) in four phases/steps (executing batch files in each step). Before executing the batch files, install softwares ADABAS DB (for Windows), Perl, MySQL and set the windows PATH environment variable point to their bin folders. Also, update the ADABAS files (FDT) paths in the batch or PERL scripts reflecting to the local installation folders. With the ADABAS database installation, we get some sample files (Tables) loaded. I have taken EMP_NAT table as example for this migration process and gave emp_nat.fdt path in my scripts. Once all the installations and setup completed, execute the 4 batch script files in below order.

## Implementation:
### Step1: Extraction of ADABAS DB layout and data (Extract.bat)

#### Description:
This batch file runs the ADAULD (ADABAS command) to extract the EMP_NAT table data in compressed format, by default data in ADABAS will be stored in compressed format. It also runs the ADADCU (ADABAS command) to get MU & PE occurrences report (will be used in next steps).

#### Code Snippet:
~~~
cd\
cd c:\software ag\adabas
del DCUFDT,DCUOUT,DCUDTA,ULDDVT,emp_natpemu.txt
ADAULD DBID=161,FILE=11,FDT
RENAME ULDDTA DCUDTA
ADADCU DCUFDT,MUPE_C_L=1,MUPE_OCCURRENCES > emp_natpemu.txt
type emp_natpemu.txt
~~~

### Step2: Creation of target DB layout using source DB layout (Create.bat)

#### Description:
This batch file runs the perl script LAYOUTCONV.pl to generate the CREATE DDL script file for target table, key & indexes creation from the source EMP_NAT FDT layout. This script also creates a batch file Transform.bat which will get executed in next step.

#### Code Snippet:
~~~
cd\
cd c:\myperl
LAYOUTCONV.pl
cd\
cd c:\software ag\adabas
~~~

### Step3: Transformation of extracted data into target DB loadable format (Transform.bat)

#### Description:
This batch file executes ADABAS command ADADCU to decompress the unloaded compressed format data (extracted in step1). A comma separated data file generated from this step as output.

#### Code Snippet:
~~~
ADADCU FIELDS AA,',',AC,',',AE,',',AD,',',AF,',',AG,',',AH,7,U,',',AI1,',',AI2,',',AI3,',',AI4,',',AJ,',',AK,',',AL,',',AN,',',AM,',',AO,',',AP,',',AR1,',',AS1,9,U,',',AT1(1),9,U,',',AT1(2),9,U,',',AT1(3),9,U,',',AR2,',',AS2,9,U,',',AT2(1),9,U,',',AT2(2),9,U,',',AT2(3),9,U,',',AR3,',',AS3,9,U,',',AT3(1),9,U,',',AT3(2),9,U,',',AT3(3),9,U,',',AR4,',',AS4,9,U,',',AT4(1),9,U,',',AT4(2),9,U,',',AT4(3),9,U,',',AR5,',',AS5,9,U,',',AT5(1),9,U,',',AT5(2),9,U,',',AT5(3),9,U,',',AU,',',AV,',',AX1,',',AY1,',',AX2,',',AY2,',',AX3,',',AY3,',',AZ1,',',AZ2,',',AZ3,',',AZ4. RECORD_STRUCTURE=NEWLINE_SEPARATOR
~~~

### Step4: creation of target DB table and load data into it (Update.bat)

#### Description:
This batch file runs the perl script CSVTOSQL.pl to convert the CSV data file into table load/Insert script file. Finally, runs MySQL commands to execute the create DDL script and Insert script files which will create Table, keys & indexes and load data into it. Here in the mysql commands, use your database username and password instead of defaults (root).

#### Code Snippet:
~~~
cd\
cd c:\myperl
CSVTOSQL.pl
cd\
cd c:\mysql
mysql -uroot -proot adabas_db < C:\SoftwareAG\ADA642_AMN823-CO_Edition_1\Adabas\emp_natddl.sql
mysql -uroot -proot adabas_db < C:\SoftwareAG\ADA642_AMN823-CO_Edition_1\Adabas\insert_script.sql
~~~

## Conclusion:
Using these scripts executed in above order, ADABAS table EMP_NAT layout and data is converted into MYSQL table. 
There is an article published on ADABAS Database to RDBMS migration concept & approach in the below link by me. Please go thru it to get conceptual idea.

#### https://dzone.com/articles/migration-of-legacy-dbfile-structure-to-rdbms
