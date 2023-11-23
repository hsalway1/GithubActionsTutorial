function disk_util ()
{
  ROOT_DISK_USED=$(df -h | grep -w '/' | awk '{print $5}')
  ROOT_DISK_USED=$(printf %s "$ROOT_DISK_USED" | tr -d [="%"=])
  ROOT_DISK_AVAIL=$(( 100 - $ROOT_DISK_USED ))

  echo -e "........................................\nDISK UTILIZATION\n"
  echo -e "Root(/) Used\t\t:$ROOT_DISK_USED%"
  echo -e "Root(/) Available\t:$ROOT_DISK_AVAIL%\n"

  # print warning if any of the disk is used above 95%
  if [ $ROOT_DISK_USED -ge 95 ] ; then
    echo -e "\nDisk is almost full! Free up some space!"
  else
    echo -e "\nDISK OK"
  fi
}

function main() {
    disk_util
}

main