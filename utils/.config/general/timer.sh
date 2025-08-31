seconds=$1
start_time=$(($(date +%s) + seconds))
while [ "$start_time" -ge $(date +%s) ]; do
  time_left=$((start_time - $(date +%s)))
  printf '%s\r' "$(date -u -d "@$time_left" +%H:%M:%S)"
  sleep 0.1
done
