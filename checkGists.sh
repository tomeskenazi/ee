#!/bin/bash
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
    echo [DEBUG] $1
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

if [ "$USERNAME" == "" ]
then
  usage
fi

numgists=$(get_gistnb)
dbg_print "Original nb gists: $numgists"

while sleep $FREQUENCY;do
  current_gists=$(get_gistnb)
  if (( $current_gists > $numgists )); then
    echo "NEW GIST PUBLISHED"
  fi
  numgists=$current_gists
  dbg_print "Nb gists: $numgists"
done
