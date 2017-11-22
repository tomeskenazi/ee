#!/usr/bin/bash
PROGNAME=${0##*/}
OPTIND=1 # Reset in case getopts has been used previously in the shell.
FREQUENCY=30 # Resting period in seconds between 2 GitHub Api calls

# Register the top level shell for the TERM signal to exit
trap "exit 1" TERM
export TOP_PID=$$

# Kill function
function forcekill()
{
   echo "Goodbye"
   kill -s TERM $TOP_PID
}

# Verbose mode function
dbg_print () {
  if [ ! -z "$DEBUGMODE"  ]; then
    echo [DEBUG] $1 >&2
  fi
  return 1
}

# Get Gist Number
get_gistnb() {
  cmdres=$(curl -X GET https://api.github.com/users/$USERNAME 2>&1)
  if [[ "$cmdres" =~ "Not Found" ]];then
    echo "[ERROR] GITHUB User not found" >&2
    echo $(forcekill)
  elif [[ "$cmdres" =~ "API rate limit exceeded" ]];then
    echo "[ERROR] GITHUB API rate limit exceeded" >&2
    echo $(forcekill)
  fi
  echo $(echo "$cmdres" | grep public_gists | sed 's/.*: //' | sed 's/,$//')
}

# Get last Created Gist Time
get_gist_latestCreatedTime(){
  cmdres=$(curl -X GET https://api.github.com/users/$USERNAME/gists 2>&1 | grep created_at)
  time_top=0
  while read -r line; do
    time_created=$(echo "$line" | sed -e 's/.*: "//' -e 's/".*$//')
    time_created_conv=$(date -d "$time_created" +%s)
    dbg_print "FUNC: Found Created at: $time_created"
    if (( $time_created_conv > $time_top )); then
      dbg_print "FUNC: Latest Created at: $time_created"
      time_top=$time_created_conv
    fi
  done <<< "$cmdres"
  echo $time_top
}

# Usage function
usage()
{
cat << EOF
        Usage: $PROGNAME [options]
               $PROGNAME <GITHUB_USERNAME>

        Regularly pull Gist Contents from a chosen user and notify in case of new gist publication

        Options:
EOF
cat <<EOF | column -s\& -t

        -t & monitoring frequency in seconds
        -h & show this output
        -v & add debug traces
EOF
exit
}

# Process Command Line Arguments
while getopts "h?vt:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    v)  DEBUGMODE=1
        ;;
    t)  FREQUENCY=$OPTARG
        ;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift
USERNAME=$@
dbg_print "USERNAME: $USERNAME"
dbg_print "FREQUENCY: $FREQUENCY"

# Check if no user name given
if [ "$USERNAME" == "" ]
then
  usage
fi

# Compute original Latest Gist found
gist_createdTime=$(get_gist_latestCreatedTime)
dbg_print "Latest Created Gist: $gist_createdTime"

# Main Monitoring loop, compare latest Gist found with reference
while sleep $FREQUENCY;do
  current_time_top=$(get_gist_latestCreatedTime)
  if (( $current_time_top > $gist_createdTime )); then
    echo "NEW GIST PUBLISHED"
  fi
  gist_createdTime=$current_time_top
  dbg_print "Latest Gist published at $gist_createdTime"
done
