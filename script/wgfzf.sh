#!/usr/bin/env bash

shopt -s extglob

wireguard_path='/etc/wireguard'
version_number="0.2.3"

red='\e[31m'
green='\e[32m'
yellow='\e[1;33m'
blue='\e[34m'
cyan='\e[36m'
normal='\e[0m'

show_help() {
  printf '\nfzguard: A small tool to interactively use wireguard-tools with fzf\n\n'
  printf 'Usage: fzguard [OPTION] [-p PATH]\n'
  printf '\t-a\tDisconnect from all active wireguard interfaces.\n'
  printf '\t-c\tConnect to a wireguard interface using fzf.\n'
  printf '\t-d\tDisconnect from an active wireguard interface using fzf.\n'
  printf '\t-h\tPrint this message and exit.\n'
  printf '\t-l\tList active connections and exit.\n'
  printf '\t-p PATH\tPath to config file. Ignored if not used with -c or the interactive mode.\n'
  printf '\t-r\tReplace one active connection with a new one.\n'
  printf '\t-v\tPrint version number and exit.\n'
}

error() {
  printf '\n%b[ERROR]:%b %b\n' "${red}" "${normal}" "${1}" >&2
}

info() {
  printf '\n%b[INFO]:%b %b\n' "${blue}" "${normal}" "${1}"
}

message() {
  printf '\n%b[MESSAGE]:%b %b\n' "${green}" "${normal}" "${1}"
}

question() {
  printf '\n%b[QUESTION]:%b %b ' "${cyan}" "${normal}" "${1}"
}

warn() {
  printf '\n%b[WARNING]:%b %b\n' "${yellow}" "${normal}" "${1}" >&2
}

check_privilage() {
  if [ "$(id -u)" -ne 0 ]; then
    error "This command must be run as root!\nPlease run the command again as root or with elevated privileges (use tools such as '${green}sudo${normal}' or '${green}doas${normal}')."
    exit 126
  fi
}

print_copy() {
  printf '%bfzguard%b Copyright (C) 2024  Rahul Sivananda (CodingOtaku) <contact@codingotaku.com>\n' "${green}" "${blue}"
  printf 'This program comes with ABSOLUTELY NO WARRANTY;\n'
  printf 'This is free software, and you are welcome to redistribute it under certain conditions;\n'
  printf 'Read https://codeberg.org/codingotaku/fzguard/src/branch/main/LICENSE for more details.%b\n' "${normal}"
}

get_interfaces() {
  interfaces="$(wg show interfaces)"
  if [ -z "${interfaces}" ]; then
    warn 'You are not connected to any wireguard interface.'
    return 1
  fi

  printf '%s' "$interfaces"
}

select_interface() {
  interfaces="$1"
  interface=$(printf '%s' "${interfaces}" | tr ' ' '\n' | fzf --reverse --height 20 --prompt "Select Interface: ")
  if [ -z "${interface}" ]; then
    warn 'No interface was selected, aborting.'
    return 130
  fi
  printf '%s' "${interface}"
}

show_connections() {
  info 'Retrieving current connection information...'
  result="$(get_interfaces)" || return $?

  info 'You are currently connected to the following interface(s):'
  printf '\t%b%s%b\n' "${green}" "${result}" "${normal}"

}

## Used by disconnect and replace_interface
disconnect_interface() {
  interface="$1"

  prompt=$(question "Are you sure you want to disconnect from ${green}${interface}${normal}? [${red}y${normal}/${green}N${normal}]:")
  read -e -n 1 -r -p "${prompt}" answer

  if [[ ! "${answer}" == [Yy]* ]]; then
    warn "you chose not to disconnect from ${green}${interface}${normal}."
    return 130
  fi

  warn "Disconnecting from ${green}${interface}${normal}."

  if ! wg-quick down "${wireguard_path}/${interface}.conf"; then
    error "Unable to disconnect from ${green}${interface}${normal}, aborting."
    return 1
  fi
  message "You are now disconnected from ${green}${interface}${normal}."
}

## TODO simplify this
replace_interface() {
  new_interface="${1}"
  old_interface="${2}"

  disconnect_interface "${old_interface}" || return $?

  message "Connecting to ${green}${new_interface}${normal}."
  if wg-quick up "${wireguard_path}/${new_interface}.conf"; then
    message "You have replaced the connection to ${green}${old_interface}${normal} with ${green}${new_interface}${normal}."
    return 0
  fi
  error "Failed to connect to ${green}${new_interface}${normal}."

  prompt=$(question "You are still disconnected from ${green}${old_interface}${normal}, would you like to reconnect to it? [${red}y${normal}/${green}N${normal}]:")
  read -e -n 1 -r -p "${prompt}" answer
  if [[ "${answer}" != [Yy]* ]]; then
    warn "you chose not to reconnect to ${green}${old_interface}${normal}."
    return 130
  fi

  message "Attempting to reconnect to ${green}${old_interface}${normal}."
  if ! wg-quick up "${wireguard_path}/${old_interface}.conf"; then
    error "Unable to reconnect to ${green}${old_interface}${normal}, aborting."
    return 1
  fi

  message "You are now reconnected to ${green}${old_interface}${normal}.\n"
}

connect() {
  warn 'adding a new interface.'
  message 'Choose an interface to connect to:'
  interfaces="$(find "${wireguard_path}" -maxdepth 1 -name '*.conf' -type f -execdir basename {} .conf ';' 2>/dev/null)"
  interface="$(select_interface "${interfaces}")" || return 130

  message "Connecting to ${green}${interface}${normal}."
  if ! wg-quick up "${wireguard_path}/${interface}.conf"; then
    error "Unable to connect to ${green}${interface}${normal}, aborting."
    return 1
  fi
  message "You are now connected to ${green}${interface}${normal}.\n"
}

disconnect() {
  result="$(get_interfaces)" || return $?

  if [[ $result = *' '* ]]; then
    message 'You care connected to multiple interfaces.'
    message 'Please choose the interface you want to disconnect from:'
    interface=$(select_interface "${result}") || return 130
  else
    interface=$result
  fi

  disconnect_interface "${interface}" || return $?
}

replace() {
  result="$(get_interfaces)" || return $?

  if [[ $result = *' '* ]]; then
    message 'You care connected to multiple interfaces.'
    message 'Please choose the interface you want to replace:'
    old_interface=$(select_interface "${result}") || return 130
  else
    old_interface=$result
  fi

  message "Choose an interface to replace with ${green}${old_interface}${normal}:"
  interfaces=$(find "${wireguard_path}" -maxdepth 1 -name '*.conf' -type f -execdir basename {} .conf ';' 2>/dev/null)
  new_interface=$(select_interface "${interfaces}") || return 130

  replace_interface "${new_interface}" "${old_interface}" || return $?
}

disconnect_all() {
  result="$(get_interfaces)" || return $?

  warn 'This will disconnect you from the following interfaces:'
  printf '\t%b%s%b\n' "${green}" "${result}" "${normal}"

  prompt=$(question "Are you sure you want to continue? [${red}y${normal}/${green}N${normal}]:")
  read -e -n 1 -r -p "${prompt}" answer

  if [[ "${answer}" != [Yy]* ]]; then
    info 'you chose not to disconnect any interface.'
    return 130
  fi

  warn "Attempting to disconnect from ${green}${result}${normal} interface(s)."
  printf '%s' "$result" | tr -d '\n' | xargs -0 -I % -d' ' wg-quick down "${wireguard_path}/%.conf"
  printf '\n'
}

show_options() {
  info 'You can do one of the following:'
  printf '\tType %ba%b to disconnect from %ball%b connected interfaces.\n' "${cyan}" "${normal}" "${cyan}" "${normal}"
  printf '\tType %bc%b to choose a new interface to %bconnect%b to.\n' "${cyan}" "${normal}" "${cyan}" "${normal}"
  printf '\tType %bd%b to %bdisconnect%b from an interface.\n' "${cyan}" "${normal}" "${cyan}" "${normal}"
  printf '\tType %br%b to %breplace%b the one active connection with a new one.\n' "${cyan}" "${normal}" "${cyan}" "${normal}"
  printf '\tType %bq%b to %bquit%b.\n' "${cyan}" "${normal}" "${cyan}" "${normal}"
}

quit=1 # TODO find a better way for graceful exit
handle_choice() {
  choice=$(printf '%s' "${1}" | tr '[:upper:]' '[:lower:]')
  case "${choice}" in
  a)
    disconnect_all
    ;;
  c)
    connect
    ;;
  d)
    disconnect
    ;;
  q)
    quit=0
    ;;
  r)
    replace
    ;;
  *)
    error 'Invalid command!\n'
    ;;
  esac
  return $?
}

manage() {
  printf '\e[2J\e[H'
  print_copy
  show_connections

  show_options
  prompt=$(question "What would you like to do? [${cyan}C${normal}onnect/${cyan}D${normal}isconnect/${cyan}R${normal}eplace/disconnect ${cyan}A${normal}ll/${cyan}Q${normal}uit]:")
  read -e -n 1 -r -p "${prompt}" choice

  handle_choice "${choice}"
  ret=$?

  if [ $quit -eq 1 ]; then
    prompt=$(info 'Press any key to continue ')
    read -n 1 -r -p "${prompt}"
  fi
  return $ret
}

main() {
  check_privilage
  # Save the user s terminal screen.
  printf '\e[?1049h'

  manage

  ret=$?

  while [ $quit -ne 0 ]; do
    manage
    ret=$?
  done

  # Restore the user's terminal screen.
  printf '\e[?1049l'
  exit $ret
}

choice=''

validate_option() {
  if [ -n "${choice}" ]; then
    error "Switch '-${1}' cannot be combined with '-${choice}'.\n"
    show_help
    exit 65
  fi
}

path_set=0
while getopts 'acdhrp:lv' option; do
  case "${option}" in
  p)
    if [ $path_set -eq 1 ]; then
      error "Using multiple wireguard config path is not yet supported\n"
      show_help
      exit 65
    fi

    wireguard_path=$(realpath "${OPTARG}" 2>/dev/null)
    if [ ! -d "${wireguard_path}" ]; then
      error "Could not find the path ${red}${OPTARG}${normal} or ${green}fzguard${normal} do not have access to it!"
      exit 1
    fi
    path_set=1
    ;;
  a | c | d | r)
    validate_option "${option}"
    choice="${option}"
    ;;
  h)
    show_help
    exit 0
    ;;
  l)
    validate_option "${option}"
    show_connections
    exit $?
    ;;
  v)
    printf 'fzguard v%s\n' "${version_number}"
    exit 0
    ;;
  *)
    if [[ -n "${option}" ]]; then
      printf '\n'
      show_help
      exit 66
    fi
    ;;
  esac
done
shift $((OPTIND - 1))

config_files=$(find "${wireguard_path}" -maxdepth 1 -name '*.conf' -type f -execdir basename {} .conf ';' 2>/dev/null)

if [ $# -gt 0 ]; then
  error "Invalid argument $1"
  show_help
  exit 65
fi

if [ -z "${config_files}" ]; then
  error "Could not find any config files in path ${red}${wireguard_path}${normal} or ${green}fzguard${normal} do not have access to them!"
  exit 1
fi

if [ -n "${choice}" ]; then
  check_privilage
  handle_choice "${choice}"
  exit $?
fi

main
