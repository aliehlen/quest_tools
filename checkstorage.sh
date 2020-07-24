#!/bin/bash
# useage: $ checkstorage.sh b1030 [--blame]
# without blame: show storage on partition
# with blame: show how much space each folder is taking
# note that, for now, you can use something like:
# ./checkstorage b1030/modules --blame
# to check disk usage in a particular subfolder

##### parse arguments #####

# get first arg, which should be partition name, exit if not present
if [[ -z "$1" || "$1" =~ "--" ]] 
then 
    echo "please supply the partition name as first arg" 
    exit 1
fi

# record partition name and shift arguments so can parse long options
pname=$1
shift 

# parse long options
if [[ -z "$1" ]] 
then
    # if no options given, no blaming
    blame=false
else
    # otherwise, set whatever is present to true
    blame=false
    while getopts b-: OPT             # colon: expects arg, parses second -
    do                                       
        if [ "$OPT" = "-" ]           # long: set OPT to all after second -
        then                         
            OPT="${OPTARG%%=*}"       # extract long option name
        fi
        case "$OPT" in
            b | blame )  blame=true ;;
            *) echo "unrecognized option --$OPT. available options are: --blame (or none)"; exit 1
        esac
    done
fi

##### actually pull and print information #####

if [ $blame = false ]
then
    # show storage on the allocation
    checkproject $pname
else
    # print out disk usage for all first-level subdirs of the partition
    echo "checking disk usage in $pname. this might take a while...."
    du --max-depth=1 -h /projects/$pname

fi

