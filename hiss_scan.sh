#!/bin/bash
# empty_circle - 2023
# v1.0
# Hiss is an aggressive nmap scanner designed to find as many open ports as possible. It has advanced mac spoofing built in.
# This is not a stealthy scan.

# Display banner
display_banner() {
  echo -e "\e[44m\e[97m########################################\e[0m"
  echo -e "\e[44m\e[97m#     Hiss Scan   -   empty_circle     #\e[0m"
  echo -e "\e[44m\e[97m#         Hiss is not stealth          #\e[0m"
  echo -e "\e[44m\e[97m#                                      #\e[0m"
  echo -e "\e[44m\e[97m#                                      #\e[0m"
  echo -e "\e[44m\e[97m########################################\e[0m"
}

# Generate a random MAC address with a valid OUI
generate_random_mac() {
  local OUI_LIST=("00:0C:29" "00:50:56" "00:1C:42" "00:1D:0F" "00:1E:68" "00:1F:29" "00:21:5A" "00:25:B5" "00:26:5E" "00:50:43")
  local OUI=${OUI_LIST[$((RANDOM % ${#OUI_LIST[@]}))]}
  local NIC=$(openssl rand -hex 3 | sed 's/\(..\)/\1:/g; s/.$//')
  echo "$OUI:$NIC"
}

# Generate a random list of DNS servers
generate_random_dns_servers() {
  # List of popular public DNS server IPs
  local DNS_SERVERS=("208.67.222.222" "208.67.220.220" "8.8.8.8" "8.8.4.4" "9.9.9.9" "149.112.112.112" "1.1.1.1" "1.0.0.1" "64.6.64.6" "64.6.65.6")

  # Randomize the DNS_SERVERS array
  local RANDOM_DNS_SERVERS=($(shuf -e "${DNS_SERVERS[@]}"))

  # Join the randomized array with commas
  local RANDOM_DNS_SERVERS_LIST=$(IFS=,; echo "${RANDOM_DNS_SERVERS[*]}")

  echo "$RANDOM_DNS_SERVERS_LIST"
}

# Usage function for user information
usage() {
  echo "Usage: $0 -t <target range> -o <output file> [-v|-f]"
  echo ""
  echo "  -t  target range in CIDR notation (required)"
  echo "  -o  output file (required)"
  echo "  -v  use verbose mode"
  echo "  -f  use fragmentation"
  echo ""
  exit 1
}

# Variables
tgtrange=""
output=""
verbose=""
fragment=""

# Process command-line options
while getopts "t:o:vf" opt; do
  case $opt in
    t) tgtrange="$OPTARG" ;;
    o) output="$OPTARG" ;;
    v) verbose=1 ;;
    f) fragment=1 ;;
    \?) usage ;;
  esac
done

# Display banner
display_banner

# Error handling
if [[ -z "$tgtrange" ]] || [[ -z "$output" ]]; then
  echo "Error: Missing required options"
  usage
fi

# Create nmap command with options
mac=$(generate_random_mac)

# Load a list of random DNS servers
random_dns_servers=$(generate_random_dns_servers)

nmap_command="nmap -n -PE -PP -PS21,22,23,25,80,113,443,31339 -PA80,113,443,10042 -PU40125,161 --source-port 53 --randomize-hosts --host-timeout 1250 -T4 --max-retries 2 --spoof-mac $mac --dns-servers $random_dns_servers $tgtrange -oA $output"

if [[ -n "$verbose" ]]; then
  nmap_command="$nmap_command -v"
fi

if [[ -n "$fragment" ]]; then
  nmap_command="$nmap_command -f"
fi

# Execute nmap command
eval $nmap_command

# Confirm the scan has completed
echo "Completed. Check your output location: $output"
