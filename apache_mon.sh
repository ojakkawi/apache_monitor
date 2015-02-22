#!/bin/bash
#
# A simple script to monitor the number of running httpd (Apache) processes
#  and restart the service if necessary.

PROCESS_COUNT_COMMAND="pgrep -c 'httpd|apache2'"

PROCESS_RESTART_COMMAND="/usr/sbin/apachectl restart"

while true
do
  # Get the current number of processes
  proc_count=$(eval $PROCESS_COUNT_COMMAND)
  
  # Main logic.
  #  Processes < 10: print "[LOW] Web Server OK!"
  #  Processes > 20 but <= 100: print "[HIGH] Web Server Working hard!"
  #  Processes > 100: print "[CRITICAL] Web Server under heavy load, restart 
  #    required"; then restart the web server
  #
  # NOTE: This logic contains a hole at number of processes >= 10 and <= 20. 
  #  In this range the script prints no message, and takes no action.
  if [ "$proc_count" -gt 100 ]; then
      echo "[CRITICAL] Web Server under heavy load, restart required"

      # Restart web server
      eval $PROCESS_RESTART_COMMAND

      while [ $? -ne 0 ]
      do
	  # Web server failed to restart. There is no prescribed action for
	  #  this case, but it is a significant failure should this occur. For
	  #  this reason we will add a log message for this case, and attempt
	  #  to restart the web server every 30 seconds.
	  echo "[CRITICAL] Web Server failed to restart!"

	  sleep 30s

	  eval $PROCESS_RESTART_COMMAND
      done

  elif [ "$proc_count" -gt 20 ]; then
      echo "[HIGH] Web Server Working hard!"
  elif [ "$proc_count" -lt 10 ]; then
      echo "[LOW] Web Server OK!"
  fi

  sleep 30s
done