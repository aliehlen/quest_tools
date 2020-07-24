# readme

Here are a couple of scripts to facilitate monitoring on quest (which currently uses slurm 18). All memory units are in GB.

### `checkqueue.sh`

formats sinfo/squeue commands to check what resources are available on a partition, both in total and right now. includes a blame option that prints jobs on the queue that have a time limit longer than 2 days.

**usage**

- `checkqueue.sh XXXX --total` : shows all resources (CPU, GPU, memory by node) for partition XXXX, plus their current state (allocated, mixed, idle)
- `checkqueue.sh XXXX --now` : shows all resources available AND in use by node in partition XXXX. State is given as A/I/O/T, which is allocated/idle/other/total. This can help us **a)** figure out if there is a good reason that slurm isn't scheduling our jobs and **b)** know exactly what resources are available at any given time so we can optimize resource requests
    - the CPU-only queues will show simpler output
    - queues with GPU resources will be more complicated. This should improve when we update slurm (in this version of slurm, there is no simple way to show how many GPUs are being used per node). For now, the workaround format is: there are multiple lines per node. The first line is a summary of what the node has and the A/I/O/T state of the CPUs. The next lines correspond to jobs using that node's resources, showing both the number of CPUs and the number of GPUs used by that job. 
- `checkqueue.sh XXXX --blame` : shows all jobs in partition XXXX with a time limit of more than 2 days
- `checkqueue.sh XXXX` : same as `checkqueue.sh --now`
- it is possible to use multiple options; results will just print one after the other in the order: total, now, blame

### `checkstorage.sh`

queries storage available for a particular allocation. includes a blame function that prints disk usage one level down in a given allocation. 

**usage**

- `checkstorage.sh XXXX` : prints storage usage for allocation XXXX
- `checkstorage.sh XXXX --blame` : print the disk usage for all first-level subdirs of the /projects/XXXX directory (often takes a while, but then we know how much storage everyone is using)

