#!/usr/bin/bash
export PATH=$PATH:/data/local/tmp

DIR=$(pwd)/stat
mkdir -p ${DIR}
rm -rf ${DIR}/*

MAX_EVTS_PER_CALL=4 #Total 6 events with instrs/cycles common per collection
DURATION=10 #Total duration to run per collection (secs)
IVAL=1000 #Periodic collection (msec)

###List of hw-cache events (14):
hwCacheEvts=(L1-dcache-loads
  L1-dcache-load-misses
  L1-dcache-stores
  L1-dcache-store-misses
  L1-icache-loads
  L1-icache-load-misses
  dTLB-loads
  dTLB-load-misses
  iTLB-loads
  iTLB-load-misses
  branch-loads
  branch-load-misses
  branch-stores
  branch-store-misses)
hwCacheEvtsSz=${#hwCacheEvts[@]}

###List of hardware events (7):
hwEvts=(cache-references
  cache-misses
  branch-instructions
  branch-misses
  bus-cycles
  stalled-cycles-frontend
  stalled-cycles-backend)
hwEvtsSz=${#hwEvts[@]}

###List of raw events provided by cpu pmu (44):
  # Please refer to PMU event numbers listed in ARMv8 manual for details.
  # A possible link is https://developer.arm.com/docs/ddi0487/latest/arm-architecture-reference-manual-armv8-for-armv8-a-architecture-profile.
rawPMUEvts=(raw-l1-icache-refill		# level 1 instruction cache refill
  raw-l1-itlb-refill		# level 1 instruction TLB refill
  raw-l1-dcache-refill		# level 1 data cache refill
  raw-l1-dcache		# level 1 data cache access
  raw-l1-dtlb-refill		# level 1 data TLB refill
  raw-load-retired		# load (instruction architecturally executed)
  raw-store-retired		# store (instruction architecturally executed)
  raw-instruction-retired		# instructions (instruction architecturally executed)
  raw-exception-taken		# exception taken
  raw-exception-return		# exception return (instruction architecturally executed)
  raw-pc-write-retired		# software change of the PC (instruction architecturally executed)
  raw-br-immed-retired		# immediate branch (instruction architecturally executed)
  raw-br-return-retired		# procedure return (instruction architecturally executed)
  raw-unaligned-ldst-retired		# unaligned load or store (instruction architecturally executed)
  raw-br-mis-pred		# mispredicted or not predicted branch speculatively executed
  raw-cpu-cycles		# cpu cycles
  raw-br-pred		# predictable branch speculatively executed
  raw-mem-access		# data memory access
  raw-l1-icache		# level 1 instruction cache access
  raw-l1-dcache-wb		# level 1 data cache write-back
  raw-l2-dcache		# level 2 data cache access
  raw-l2-dcache-refill		# level 2 data cache refill
  raw-l2-dcache-wb		# level 2 data cache write-back
  raw-bus-access		# bus access
  raw-inst-spec		# operation speculatively executed
  raw-ttbr-write-retired		# write to TTBR (instruction architecturally executed)
  raw-bus-cycles		# bus cycle
  raw-l2-dcache-allocate		# level 2 data cache allocation without refill
  raw-br-retired		# branch (instruction architecturally executed)
  raw-br-mis-pred-retired		# mispredicted branch (instruction architecturally executed)
  raw-stall-frontend		# no operation issued due to the frontend
  raw-stall-backend		# no operation issued due to the backend
  raw-l1-dtlb		# level 1 data or unified TLB access
  raw-l1-itlb		# level 1 instruction TLB access
  raw-l2-icache		# level 2 instruction cache access
  raw-l2-icache-refill		# level 2 instruction cache refill
  raw-l3-dcache-allocate		# level 3 data or unified cache allocation without refill
  raw-l3-dcache-refill		# level 3 data or unified cache refill
  raw-l3-dcache		# level 3 data or unified cache access
  raw-l3-dcache-wb		# level 3 data or unified cache write-back
  raw-l2-dtlb-refill		# level 2 data or unified TLB refill
  raw-l2-itlb-refill		# level 2 instruction TLB refill
  raw-l2-dtlb		# level 2 data or unified TLB access
  raw-l2-itlb		# level 2 instruction TLB access
)
rawPMUEvtsSz=${#rawPMUEvts[@]}

###List of software events (9):
swEvts=(cpu-clock
  task-clock
  page-faults
  context-switches
  cpu-migrations
  minor-faults
  major-faults
  alignment-faults
  emulation-faults)
swEvtsSz=${#swEvts[@]}

for i in $(seq 0 4 $((hwCacheEvtsSz-1)))
do
  if [[ $((i + 3)) -lt ${hwCacheEvtsSz} ]]; then
    busybox-spa taskset 0x01 simpleperf stat -a --cpu 4 -e instructions,cpu-cycles,${hwCacheEvts[$i]},${hwCacheEvts[$((i+1))]},${hwCacheEvts[$((i+2))]},${hwCacheEvts[$((i+3))]} \
        --duration ${DURATION} --interval ${IVAL} -o ${DIR}/hwCacheEvts${i}.stat
    #echo ${hwCacheEvts[$i]}, ${hwCacheEvts[$((i+1))]}, ${hwCacheEvts[$((i+2))]}, ${hwCacheEvts[$((i+3))]}
  else
    tail=$((hwCacheEvtsSz % ${MAX_EVTS_PER_CALL}))
    busybox-spa taskset 0x01 simpleperf stat -a --cpu 4 -e instructions,cpu-cycles,${hwCacheEvts[$((hwCacheEvtsSz-4))]},${hwCacheEvts[$((hwCacheEvtsSz-3))]},${hwCacheEvts[$((hwCacheEvtsSz-2))]},${hwCacheEvts[$((hwCacheEvtsSz-1))]} \
        --duration ${DURATION} --interval ${IVAL} -o ${DIR}/hwCacheEvts${i}.stat
	#echo ${hwCacheEvts[$i]}, ${hwCacheEvts[$((i+1))]}, ${hwCacheEvts[$((i+2))]}, ${hwCacheEvts[$((i+3))]}
  fi
done

for i in $(seq 0 4 $((hwEvtsSz-1)))
do
  if [[ $((i + 3)) -lt ${hwEvtsSz} ]]; then
    busybox-spa taskset 0x01 simpleperf stat -a --cpu 4 -e instructions,cpu-cycles,${hwEvts[$i]},${hwEvts[$((i+1))]},${hwEvts[$((i+2))]},${hwEvts[$((i+3))]} \
        --duration ${DURATION} --interval ${IVAL} -o ${DIR}/hwEvts${i}.stat
    #echo ${hwEvts[$i]}, ${hwEvts[$((i+1))]}, ${hwEvts[$((i+2))]}, ${hwEvts[$((i+3))]}
  else
    tail=$((hwEvtsSz % ${MAX_EVTS_PER_CALL}))
	busybox-spa taskset 0x01 simpleperf stat -a --cpu 4 -e instructions,cpu-cycles,${hwEvts[$((hwEvtsSz-4))]},${hwEvts[$((hwEvtsSz-3))]},${hwEvts[$((hwEvtsSz-2))]},${hwEvts[$((hwEvtsSz-1))]} \
        --duration ${DURATION} --interval ${IVAL} -o ${DIR}/hwEvts${i}.stat
	#echo ${hwEvts[$i]}, ${hwEvts[$((i+1))]}, ${hwEvts[$((i+2))]}, ${hwEvts[$((i+3))]}
  fi
done

for i in $(seq 0 4 $((rawPMUEvtsSz-1)))
do
  if [[ $((i + 3)) -lt ${rawPMUEvtsSz} ]]; then
    busybox-spa taskset 0x01 simpleperf stat -a --cpu 4 -e instructions,cpu-cycles,${rawPMUEvts[$i]},${rawPMUEvts[$((i+1))]},${rawPMUEvts[$((i+2))]},${rawPMUEvts[$((i+3))]} \
        --duration ${DURATION} --interval ${IVAL} -o ${DIR}/rawPMUEvts${i}.stat
    #echo ${rawPMUEvts[$i]}, ${rawPMUEvts[$((i+1))]}, ${rawPMUEvts[$((i+2))]}, ${rawPMUEvts[$((i+3))]}
  else
    tail=$((rawPMUEvtsSz % ${MAX_EVTS_PER_CALL}))
	busybox-spa taskset 0x01 simpleperf stat -a --cpu 4 -e instructions,cpu-cycles,${rawPMUEvts[$((rawPMUEvtsSz-4))]},${rawPMUEvts[$((rawPMUEvtsSz-3))]},${rawPMUEvts[$((rawPMUEvtsSz-2))]},${rawPMUEvts[$((rawPMUEvtsSz-1))]} \
        --duration ${DURATION} --interval ${IVAL} -o ${DIR}/rawPMUEvts${i}.stat
	#echo ${rawPMUEvts[$i]}, ${rawPMUEvts[$((i+1))]}, ${rawPMUEvts[$((i+2))]}, ${rawPMUEvts[$((i+3))]}
  fi
done

for i in $(seq 0 4 $((swEvtsSz-1)))
do
  if [[ $((i + 3)) -lt ${swEvtsSz} ]]; then
    busybox-spa taskset 0x01 simpleperf stat -a --cpu 4 -e instructions,cpu-cycles,${swEvts[$i]},${swEvts[$((i+1))]},${swEvts[$((i+2))]},${swEvts[$((i+3))]} \
        --duration ${DURATION} --interval ${IVAL} -o ${DIR}/swEvts${i}.stat
    #echo ${swEvts[$i]}, ${swEvts[$((i+1))]}, ${swEvts[$((i+2))]}, ${swEvts[$((i+3))]}
  else
    tail=$((swEvtsSz % ${MAX_EVTS_PER_CALL}))
	busybox-spa taskset 0x01 simpleperf stat -a --cpu 4 -e instructions,cpu-cycles,${swEvts[$((swEvtsSz-4))]},${swEvts[$((swEvtsSz-3))]},${swEvts[$((swEvtsSz-2))]},${swEvts[$((swEvtsSz-1))]} \
        --duration ${DURATION} --interval ${IVAL} -o ${DIR}/swEvts${i}.stat
	#echo ${swEvts[$i]}, ${swEvts[$((i+1))]}, ${swEvts[$((i+2))]}, ${swEvts[$((i+3))]}
  fi
done

#Combine the stat files
cat ${DIR}/hwCacheEvts*stat ${DIR}/hwEvts*stat ${DIR}/rawPMU* ${DIR}/swEvts* > combine_stat_$(date '+%m%d%y_%H%M%S').stat

