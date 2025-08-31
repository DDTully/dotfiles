start_time=$(date +%s)
while true; do
  elapsed_time=$(($(date +%s) - start_time))
  printf '%s\r' "$(date -u -d "@$elapsed_time" +%H:%M:%S)"
  sleep 0.1
done
