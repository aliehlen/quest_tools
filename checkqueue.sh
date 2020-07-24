#!/bin/bash
# useage: $ checkqueue.sh b1030 [--total] [--now] [--blame]
# long options are optional. if none given, defaults to now. 
# will print results for more than one, just without much signage
# memory prints in GB

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
    # if no options given, show avail
    total=false now=true blame=false
else
    # otherwise, set whatever is present to true
    total=false now=false blame=false
    while getopts bant-: OPT          # colon: expects arg, parses second -
    do                                       
        if [ "$OPT" = "-" ]           # long: set OPT to all after second -
        then                         
            OPT="${OPTARG%%=*}"       # extract long option name
        fi
        case "$OPT" in
            t | total )  total=true ;;
            n | now )    now=true ;;
            b | blame )  blame=true ;;
            *) echo "unrecognized option --$OPT. available options are: "`
                    `"--total --now --blame (or none)"; exit 1
        esac
    done
fi


##### actually pull and print information #####


# print queue resources (total)
if [ $total = true ]
then

    # get nicely formatted sinfo
    format_total="NodeList:.9,Nodes:.6,CPUs:.5,Gres:.11,Memory:.7,"`
                  `"StateLong:.10,Features:.15"

    # query, divide memory by 100 so is in GB
    queue_total=$(sinfo -p $pname -N -O "$format_total" |
                    awk -F " " 'NR==1; NR>1{$5=$5/1000;print}' ) 

    # print
    echo "${queue_total}" | column -t

fi


# print what's being used now (now)
if [ $now = true ]
then

    # print full CPU usage 
    # (states prints: allocated/idle/other/total) 
    # (add GresUsed:.11 after Gres after they upgrade slurm)
    format_now="NodeList:.9,StateLong:.11,Nodes:.7,CPUsState:.15,Gres:.15,"`
                `"FreeMem:.11,Memory:.7,Features:.15"
    
    # divide memory columns by 1000 to show in GB (keeping header)
    queue_now=$(sinfo -p $pname -N -O "$format_now" |
                awk -F " " 'NR==1; NR>1{$6=$6/1000;$7=$7/1000;print}' ) 

    # check if there are gpus in this partition
    queue_gres=$(sinfo -p $pname -N -O "Gres" | grep -c "gpu" ) 
    
    # if there are gpus, add that info manaully
    if [ $queue_gres != 0 ] 
    then

        # get info about what jobs are running (no pending jobs)
        format_gpu="%.9N %.5t %.14C %.14b"

        # keep only running jobs (R)
        queue_gpu=$(squeue -p $pname -o "$format_gpu" -h |
                     grep -E  "[ ]+R[ ]+" ) 
        
        # add an extra 2nd column of dots so is easier to read
        queue_gpu=$(printf "$queue_gpu" | awk -F " " '$1=$1 FS "..."')

        # append this new info to be printed
        queue_now+="\n${queue_gpu}\n"

    fi

    # sort by node (first col) and print
    printf "${queue_now}" | sort | column -t 

fi


# print jobs that have a time limit longer than 2 days (blame)
if [ $blame = true ]
then

    # print squeue w TIME_LIMIT first, show any time limit greater than 2 days
    format_blame="TimeLimit:.12,JobID:.14,Partition:.11,Name:.16,UserName:.9,"`
                  `"StateCompact:.4,TimeUsed:.12,NumNodes:.6,ReasonList:.18" 
    
    
            
# a little processing to remove the non-problem time limits
    queue_blame=$(squeue -p $pname -O "$format_blame" | 
                    grep -E "TIME|^[ \t]*[0-9]+-[0-9]+" |   # match number-number (has days)  
                    grep -v "^[^0-9]*1-"  |                 # remove day value 1
                    grep -v "^[ \t]*2-00:00:00" )           # remove exactly 2 days

    # print nicely
    echo "${queue_blame}" | column -t

fi

