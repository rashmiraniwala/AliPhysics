# Script for testing of the CPass0.jdl  on the grid for user purposes
# To be used for validation of modified user code before asking for porting

# 
# Parameters for macro:
# 1  -   alien user dir name                 - e.g  /m/miranov/
# 2  -   input directory with raw data       - e.g /alice/data/2011/LHC11a/
# 3  -   run number                          - e.g run number 146807
# Example:
# RunNumber=146807
# AlienName=/m/miranov/
# RawPath=/alice/data/2011/LHC11a/
# $ALICE_PHYSICS/PWGPP/CalibMacros/CPass0/test/runCPass0User.sh  $AlienName $RawPath  $RunNumber 
#
# authors:   marian.ivanov#cern.ch, mikolaj.krzewicki@cern.ch 

AlienName=$1
RawPath=$2
RunNumber=$3
InputMacros=$ALICE_PHYSICS/PWGPP/CalibMacros/CPass0/

echo xxxxxxxxxxxxxxxxxxxxxxxxxx
echo SETUP
echo AlienName=$1
echo RawPath=$2
echo RunNumber=$3
echo InputMacros=$ALICE_PHYSICS/PWGPP/CalibMacros/CPass0/
echo xxxxxxxxxxxxxxxxxxxxxxxxxx

#
# 1. copy macroses and sh to the predefiend alien directory
#
OutputMacros=`echo /alice/cern.ch/user/j/jotwinow/CPass0/CalibMacros/ | sed s_\/j\/jotwinow\/_$AlienName\_ `
alien_mkdir -p $OutputMacros

for lfile in `ls $InputMacros/{*C,*sh} `; do
    bname=`basename $lfile`  
    echo  Copping alien_cp -n $lfile alien://$OutputMacros/$bname 
    alien_cp -n $lfile alien://$OutputMacros/$bname
done


#
# 2. Copy shell script and jdl
#
OutputBin=`echo  /alice/cern.ch/user/j/jotwinow/bin/ | sed s_\/j\/jotwinow\/_$AlienName\_ `
echo alien_cp -n $InputMacros/runCPass0.sh  alien://$OutputBin/runCPass0.sh
alien_cp -n  $InputMacros/runCPass0.sh   alien://$OutputBin/runCPass0.sh
cat $InputMacros/CPass0.jdl | sed "s_/j/jotwinow/_${AlienName}_g" | sed "s_/alice/data/2010/LHC10d/_${RawPath}_g" > CPass0.jdl
echo alien_cp -n CPass0.jdl alien://$OutputMacros/CPass0.jdl
alien_cp -n CPass0.jdl alien://$OutputMacros/CPass0.jdl

#
# 3. Copy validation switch off return value - job will alway finish
#
cat $InputMacros/validation.sh |  sed "s_exit \$error_exit 0_" > validation.sh
echo alien_cp  -n validation.sh  alien:///$OutputMacros/validation.sh
alien_cp  -n validation.sh  alien:///$OutputMacros/validation.sh
#
# 4. Submit job
#
echo nohup alien_submit alien:///$OutputMacros/CPass0.jdl $RunNumber 
nohup alien_submit alien:///$OutputMacros/CPass0.jdl "000"$RunNumber  >submitJob$RunNumber.txt
#echo Alien job submitted $!

