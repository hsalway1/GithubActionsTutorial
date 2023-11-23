function cpu_util ()
{
  # number of cpu cores
  CORES=$(nproc)

  # cpu load average of 15 minutes
  LOAD_AVERAGE=$(uptime | awk '{print $10}')
  LOAD_PERCENT=$(bc <<<"scale=0; $LOAD_AVERAGE * 100")

  echo -e "........................................\nCPU UTILIZATION\n"
  echo -e "Number of Cores\t:$CORES\n"

  echo -e "Total CPU Load Average for the past 15 minutes\t:$LOAD_AVERAGE"
  echo -e "CPU Load %\t\t\t\t\t:$LOAD_PERCENT"
  echo -e "\nThe load average reading takes into account all the core(s) present in the system"

  # if load average is equal to the number 
  # of cores, print warning
  if [[ $(echo "if (${LOAD_AVERAGE} == ${CORES}) 1 else 0" | bc) -eq 1 ]] ; then
    echo "Load average not ideal."
  elif [[ $(echo "if (${LOAD_AVERAGE} > ${CORES}) 1 else 0" | bc) -eq 1 ]] ; then
    echo "Critical! Load average is too high!"
  else
    echo -e "\nCPU LOAD OK"
  fi

  # capturing the second iteration of top and storing the CPU% id.
  IDLE=$(top -b -n2 | awk '/Cpu/ {print $8}' | tail -1)
  CPU_USAGE_PERCENT=$(bc <<<"scale=2; 100 - $IDLE/$CORES")

  echo -e "\nCPU Usage %\t:$CPU_USAGE_PERCENT\n........................................"  
}

function main() {
  cpu_util
}

main
