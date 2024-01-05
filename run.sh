#!/bin/bash

SCRIPT_DIR="$( dirname ${BASH_SOURCE:-$0} )"
SOURCE_DIR="${SCRIPT_DIR}/source"
DATA_DIR="${SCRIPT_DIR}/data"
CACHE_DIR="${SCRIPT_DIR}/.cache"
SETTINGS_FILE="${DATA_DIR}/settings.conf"
TEMPLATE_SETTINGS_FILE="${SCRIPT_DIR}/settings.conf.template"
HELP_FILE="help.txt"
TMP_SHA_FILE="${CACHE_DIR}/tmp_sha"
SHA_FILE="${CACHE_DIR}/sha"
VIEW_FILE="${CACHE_DIR}/view"

# Source library
. ${SOURCE_DIR}/lib || { echo "ERROR: Sourcing has failed, file: ${SOURCE_DIR}/lib"; exit 1; }

cd_to_script_return_on_exit

# Ensure directories
mkdir -p "${DATA_DIR}" "${CACHE_DIR}"

# If settings file is missing copy from template
[ -f "${SETTINGS_FILE}" ] || cp "${TEMPLATE_SETTINGS_FILE}" "${SETTINGS_FILE}"

if ! [ -f "${DATA_DIR}/web-connect" ]
then

cat << EOF > "${DATA_DIR}/web-connect"
ID='1'
TITLE='Google'
GROUP='DEFAULT'
VPN=''
PORTFORWARD=''
URL='https://google.com'
DETAILS=''

EOF

fi


# From settings file source only variables
eval $( egrep '^[ \t]*[a-zA-Z0-9_-]*=' "${SETTINGS_FILE}" )


case $1 in

    "" | [a-zA-Z0-9]* )

        source_file dependencies; install_dependencies
        source_file generate_view_file; build
        source_file portforward
        source_file vpn
        source_file run; run_with_arguments "$@"

        if [[ $PORTFORWARD_IS_CREATED == true ]]
        then

          read -n 1 -s -r -p "$( echo -e "\n${COLOR_YELLOW}[PRESS ANY KEY TO DISCONNECT PORTS]${COLOR_END}" )"

        fi

        exit 0
        ;;

    -n | --new )

        INCLUDED_FILE="$2"
        [[ -n "$INCLUDED_FILE" ]] || error "Included file is required." "print_help"


        shift 2
        [[ -n $1 ]] || error "Options are required" "print_help"

		# Set variables
        while [[ $# -gt 0 ]]; do
            case $1 in

                -t | --title )

                    TITLE=$2
                    [[ -n $TITLE ]] || error "Title name is required"
                    shift 2
                    ;;

                -g | --group )

                    GROUP=$2
                    [[ -n $GROUP ]] || error "Group name is required"
                    shift 2
                    ;;

                -i | --id )

                    ID=$2
                    [[ -n $ID ]] || error "ID can not be empty"
                    shift 2
                    ;;

                -v | --vpn )

                    VPN=$2
                    [[ -n $VPN ]] || error "VPN is empty"
                    shift 2
                    ;;

                -p | --portforward )

                    PORTFORWARD=$2
                    [[ -n $PORTFORWARD ]] || error "Portforward command is empty"
                    shift 2
                    ;;

                -u | --url )

                    URL=$2
                    [[ -n $URL ]] || error "URL is empty"
                    shift 2
                    ;;

                -d | --details )

                    DETAILS=$2
                    [[ -n $DETAILS ]] || error "Group name is required"
                    shift 2
                    ;;

                * )

                    error "Unknown option: $1" "print_help"
                    ;;

            esac
        done

		    # Insert new record using variables above
        source_file new_record; add_new_record
        exit 0
        ;;

    -e | --edit )

        ALIAS=$2
        [[ -n $ALIAS ]] || error "ID is required" "print_help"

        shift 2
        while [[ $# -gt 0 ]]; do
            case $1 in

                -t | --title )

                    TITLE=$2
                    [[ -n $TITLE ]] || error "Title name is required"
                    shift 2
                    ;;

                -g | --group )

                    GROUP=$2
                    [[ -n $GROUP ]] || error "Group name is required"
                    GROUP_TRIGGER=true
                    shift 2
                    ;;

                -i | --id )

                    ID_NEW=$2
                    [[ -n $ID_NEW ]] || error "ID can not be empty"
                    shift 2
                    ;;

                -v | --vpn )

                    VPN=$2
                    [[ -n $VPN ]] || error "VPN is empty"
                    VPN_TRIGGER=true
                    shift 2
                    ;;

                -p | --portforward )

                    PORTFORWARD=$2
                    [[ -n $PORTFORWARD ]] || error "Portforward command is empty"
                    PORTFORWARD_TRIGGER=true
                    shift 2
                    ;;

                -u | --url )

                    URL=$2
                    [[ -n $URL ]] || error "URL is empty"
                    shift 2
                    ;;

                -d | --details )

                    DETAILS=$2
                    [[ -n $DETAILS ]] || error "Details is empty"
                    DETAILS_TRIGGER=true
                    shift 2
                    ;;

                * )

                    error "Unknown option: $1" "print_help"
                    ;;

            esac
        done

        source_file edit_entry; edit_entry_cmd
        exit 0
        ;;

    -s | --show )

        source_file show_record; show $2
        exit 0
        ;;

    -h | --help ) 

        print_help
        exit 0 
        ;;

    --settings )

      $EDITOR "$SETTINGS_FILE"
      exit 0
      ;;

    * )

        error "Unknown option: $1" "print_help"
        ;;

esac

