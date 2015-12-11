#!/bin/bash
#==========================================================================
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#==========================================================================
# Description:
#   This script was written for shallow flash the gaia and/or gecko.
#
# Author: Askeing fyen@mozilla.com
# History:
#   2013/08/02 Askeing: v1.0 First release.
#   2014/08/09 Added Cygwin support by revelon.
#==========================================================================


####################
# Parameter Flags  #
####################
VERY_SURE=false
KEEP_PROFILE=false
ADB_DEVICE="dispositivo"
FLASH_GAIA=false
FLASH_GAIA_FILE=""
FLASH_GECKO=false
FLASH_GECKO_FILE=""
NO_FTU=${NO_FTU:-false}
# for other bash script tools call.
case `uname` in
    "Linux"|"CYGWIN"*) SP="";;
    "Darwin") SP=" ";;
esac

####################
# Functions        #
####################

## helper function
function helper(){
    echo -e "Este script fue escrito para el flasheo de gaia y/o gecko.\n"
    echo -e "Use: ./shallow_flash.sh [parametros]"
    echo -e "-g|--gaia\tFlashea gaia (zip format) en su dispositivo."
    echo -e "-G|--gecko\tFlashea gecko (tar.gz format) en su dispositivo."
    echo -e "--keep_profile\tMantener el perfil de usuario en su dispositivo. (BETA)"
    echo -e "-s <serial number>\tDirige comandos para el dispositivo con el número de serie dado."
    echo -e "-y\t\tflash the file without asking askeing (it's a joke...)"
    echo -e "-h|--help\tMuestra la ayuda."
    echo -e "Ejemplo:"
    case `uname` in
        "Linux"|"CYGWIN"*)
            echo -e "  Flash gaia.\t\t./shallow_flash.sh --gaia=gaia.zip"
            echo -e "  Flash gecko.\t\t./shallow_flash.sh --gecko=b2g.tar.gz"
            echo -e "  Flash gaia and gecko.\t./shallow_flash.sh -ggaia.zip -Gb2g.tar.gz";;
        "Darwin")
            echo -e "  Flash gaia.\t\t./shallow_flash.sh --gaia gaia.zip"
            echo -e "  Flash gecko.\t\t./shallow_flash.sh --gecko b2g.tar.gz"
            echo -e "  Flash gaia and gecko.\t./shallow_flash.sh -g gaia.zip -G b2g.tar.gz";;
    esac
    exit 0
}

## adb with flags
function run_adb()
{
    # TODO: Bug 875534 - Unable to direct ADB forward command to inari devices due to colon (:) in serial ID
    # If there is colon in serial number, this script will have some warning message.
	adb $ADB_FLAGS $@
}

## make sure user want to shallow flash
function make_sure() {
    echo "¿Seguro que quieres a flashear?"
    if [[ $FLASH_GAIA == true ]]; then
        echo -e "Gaia: $FLASH_GAIA_FILE "
    fi
    if [[ $FLASH_GECKO == true ]]; then
        echo -e "Gecko: $FLASH_GECKO_FILE "
    fi
    read -p "en su $ADB_DEVICE? [y/N]" isFlash
    test "$isFlash" != "y"  && test "$isFlash" != "Y" && echo -e "bye bye." && exit 0
}

## check the return code, exit if return code is not zero.
function check_exit_code() {
	RET=$1
	ERROR_MSG=$2
	if [[ ${RET} != 0 ]]; then
        if [[ -z ${ERROR_MSG} ]]; then
            echo "### Failed!"
        else
        	echo "### Failed: ${ERROR_MSG}"
        fi
        exit 1
	fi
}

function check_adb_result() {
    RET=$1
    if [[ $RET == *"error"* ]]; then
        check_exit_code 1 "Por favor, asegurese de adb se esta ejecutando como root."
    elif [[ $RET == *"no se puede ejecutar como root"* ]]; then
        check_exit_code 1 "Por favor, asegurese de adb se esta ejecutando como root."
    elif [[ $RET == *"Remontar fallo"* ]]; then
        check_exit_code 1 "Por favor, asegurese de adb se esta ejecutando como root."
    elif [[ $RET == *"Operacion no permitida"* ]]; then
        check_exit_code 1 "Por favor, asegurese de adb se esta ejecutando como root."
    fi
}

## adb root, then remount and stop b2g
function adb_root_remount() {
    echo "### Esperando dispositivo ... por favor asegurese de que esta conectado, encendido y que la depuracion remota esta activada en Gaia"
    run_adb wait-for-device     #in: gedit display issue

    echo "### Reiniciando adb con permisos root..."
    RET=$(run_adb root)
    echo "$RET"
    check_adb_result "$RET"
    run_adb wait-for-device     #in: gedit display issue

    echo "### Remontando la particion /system ..."
    RET=$(run_adb remount)
    echo "$RET"
    check_adb_result "$RET"
    RET=$(run_adb shell mount -o remount,rw /system)
    echo "$RET"
    check_adb_result "$RET"

    echo "### Deteniendo proceso b2g ..."
    run_adb shell stop b2g
}

## adb sync then reboot
function adb_reboot() {
    run_adb shell sync
    run_adb shell reboot
    run_adb wait-for-device     #in: gedit display issue
}

## clean cache, gaia (webapps) and profiles
function adb_clean_gaia() {
    echo "### Limpiando Gaia y Perfiles ..."
    run_adb shell rm -r /cache/* ##&&
    ##run_adb shell rm -r /data/b2g/* &&
    ##run_adb shell rm -r /data/local/storage/persistent/* &&
    ##run_adb shell rm -r /data/local/svoperapps &&
    ##run_adb shell rm -r /data/local/webapps &&
    ##run_adb shell rm -r /data/local/user.js &&
    ##run_adb shell rm -r /data/local/permissions.sqlite* &&
    run_adb shell rm -r /data/local/OfflineCache ##&&
    ##run_adb shell rm -r /data/local/indexedDB &&
    ##run_adb shell rm -r /data/local/debug_info_trigger &&
    ##run_adb shell rm -r /system/b2g/webapps &&
    echo "### Limpieza realizada."
}

## push gaia into device
function adb_push_gaia() {
    GAIA_DIR=$1
    ## Adjusting user.js
    cat $GAIA_DIR/gaia/profile/user.js | sed -e "s/user_pref/pref/" > $GAIA_DIR/user.js &&
    if [[ `uname` == "CYGWIN"* ]]; then
        if [[ ! -d "/cygdrive/c/tmp" ]]; then
            mkdir "/cygdrive/c/tmp"
        fi
        cp -r $GAIA_DIR /cygdrive/c/tmp/
    fi &&

    echo "### Instalando Gaia en el dispositivo ..."
    run_adb shell mkdir -p /system/b2g/defaults/pref &&
    run_adb push $GAIA_DIR/gaia/profile/webapps /system/b2g/webapps &&
    run_adb push $GAIA_DIR/user.js /system/b2g/defaults/pref &&
    run_adb push $GAIA_DIR/gaia/profile/settings.json /system/b2g/defaults &&
    echo "### Instalacion hecha."
}

## shallow flash gaia
function shallow_flash_gaia() {
    GAIA_ZIP_FILE=$1
    
    if ! [[ -f $GAIA_ZIP_FILE ]]; then
        echo "### No se puede encontrar $GAIA_ZIP_FILE file."
        exit 2
    fi

    if ! which mktemp > /dev/null; then
        echo "### Paquete \"mktemp\" no encontrado!"
        rm -rf ./shallowflashgaia_temp
        mkdir shallowflashgaia_temp
        cd shallowflashgaia_temp
        TMP_DIR=`pwd`
        cd ..
    else
        TMP_DIR=`mktemp -d -t shallowflashgaia.XXXXXXXXXXXX`
    fi

    unzip_file $GAIA_ZIP_FILE $TMP_DIR &&
    adb_clean_gaia &&
    adb_push_gaia $TMP_DIR
    check_exit_code $? "La instalacion de Gaia ha fallado."

    rm -rf $TMP_DIR
}

## unzip zip file
function unzip_file() {
    ZIP_FILE=$1
    DEST_DIR=$2
    if ! [[ -z $ZIP_FILE ]]; then
        test ! -f $ZIP_FILE && echo -e "### El archivo $ZIP_FILE no existe." && exit 2
    else
        echo "### No input zip file."
        exit 2
    fi
    echo "### Descomprimiendo $ZIP_FILE en $DEST_DIR ..."
    test -e $ZIP_FILE && unzip -q $ZIP_FILE -d $DEST_DIR
    check_exit_code $? "Fallo la descompresion de $ZIP_FILE."
    #ls -LR $DEST_DIR
}

## shallow flash gecko
function shallow_flash_gecko() {
    GECKO_TAR_FILE=$1

    if ! [[ -f $GECKO_TAR_FILE ]]; then
        echo "### No puede encontrarse el archivo $GECKO_TAR_FILE."
        exit 2
    fi

    if ! which mktemp > /dev/null; then
        echo "### Paquete \"mktemp\" no encontrado!"
        rm -rf ./shallowflashgecko_temp
        mkdir shallowflashgecko_temp
        cd shallowflashgecko_temp
        TMP_DIR=`pwd`
        cd ..
    else
        TMP_DIR=`mktemp -d -t shallowflashgecko.XXXXXXXXXXXX`
    fi

	## push gecko into device
    untar_file $GECKO_TAR_FILE $TMP_DIR &&
    if [[ `uname` == "CYGWIN"* ]]; then
        cp -r $TMP_DIR /cygdrive/c/tmp/
    fi &&
    echo "### Instalando Gecko en el dispositivo..." &&
    run_adb push $TMP_DIR/b2g /system/b2g &&
    echo "### Instalacion hecha."
    check_exit_code $? "La instalacion de Gecko ha fallado."

    rm -rf $TMP_DIR
}

## untar tar.gz file
function untar_file() {
    TAR_FILE=$1
    DEST_DIR=$2
    if ! [[ -z $TAR_FILE ]]; then
        test ! -f $TAR_FILE && echo -e "### El archivo $TAR_FILE no existe." && exit 2
    else
        echo "### No input tar file."
        exit 2
    fi
    echo "### Descomprimiendo $TAR_FILE en $DEST_DIR ..."
    test -e $TAR_FILE && tar -xzf $TAR_FILE -C $DEST_DIR
    check_exit_code $? "Fallo la descompresion de $TAR_FILE ."
    #ls -LR $DEST_DIR
}

## option $1 is temp_folder
function backup_profile() {
    DEST_DIR=$1
    echo "### Perfil respaldado en ${DEST_DIR}"
    bash ./backup_restore_profile.sh -p${SP}${DEST_DIR} --no-reboot -b
}

## option $1 is temp_folder
function restore_profile() {
    DEST_DIR=$1
    echo "### Restaurando Perfil desde ${DEST_DIR}"
    bash ./backup_restore_profile.sh -p${SP}${DEST_DIR} --no-reboot -r
}

## option $1 is temp_folder
function remove_profile() {
    DEST_DIR=$1
    echo "### Removiendo perfil en ${DEST_DIR}"
    rm -rf ${DEST_DIR}
    echo "### Extraccion de perfil completado ."
}

#########################
# Processing Parameters #
#########################

## show helper if nothing specified
if [[ $# = 0 ]]; then echo "Nothing specified"; helper; exit 0; fi

## distinguish platform
case `uname` in
    "Linux"|"CYGWIN"*)
        ## add getopt argument parsing
        TEMP=`getopt -o g::G::s::yh --long gaia::,gecko::,keep_profile,help \
        -n 'invalid option' -- "$@"`

        if [[ $? != 0 ]]; then echo "Introduzca '--help' para mas informacion." >&2; exit 1; fi

        eval set -- "$TEMP";;
    "Darwin");;
esac

while true
do
    case "$1" in
        -h|--help) helper; exit 0;;
        -g|--gaia) 
            FLASH_GAIA=true;
            case "$2" in
                "") echo -e "Por favor especifica la ruta de Gaia.\nIntroduzca '--help' para mas informacion.";exit 1;;
                *) FLASH_GAIA_FILE=$2; shift 2;;
            esac ;;
        -G|--gecko)
            FLASH_GECKO=true;
            case "$2" in
                "") echo -e "Por favor especifica la ruta de Gecko.\nIntroduzca '--help' para mas informacion."; exit 1;;
                *) FLASH_GECKO_FILE=$2; shift 2;;
            esac ;;
        --keep_profile) if [[ -e ./backup_restore_profile.sh ]]; then KEEP_PROFILE=true; else echo "### No hay ningún archivo backup_restore_profile.sh."; fi; shift;;
        -s)
            case "$2" in
                "") shift 2;;
                *) ADB_DEVICE=$2; ADB_FLAGS+="-s $2"; shift 2;;
            esac ;;
        -y) VERY_SURE=true; shift;;
        --) shift;break;;
        "") shift;break;;
        *) helper; echo ha ocurrido un error; exit 1;;
    esac
done


####################
# Make Sure        #
####################
if [[ $VERY_SURE == false ]] && ([[ $FLASH_GAIA == true ]] || [[ $FLASH_GECKO == true ]]); then
    make_sure
fi
if ! [[ -f $FLASH_GAIA_FILE ]] && [[ $FLASH_GAIA == true ]]; then
    echo "### No se puede encontrar $FLASH_GAIA_FILE file."
    exit 2
fi
if ! [[ -f $FLASH_GECKO_FILE ]] && [[ $FLASH_GECKO == true ]]; then
    echo "### No se puede encontrar $FLASH_GECKO_FILE file."
    exit 2
fi


####################
# ADB Work         #
####################
adb_root_remount

####################
# Backup Profile   #
####################
if [[ $KEEP_PROFILE == true ]] && ([[ $FLASH_GAIA == true ]] || [[ $FLASH_GECKO == true ]]) ; then
    if ! which mktemp > /dev/null; then
        echo "### Paquete \"mktemp\" no encontrado!"
        rm -rf ./profile_temp
        mkdir profile_temp
        cd profile_temp
        TMP_PROFILE_DIR=`pwd`
        cd ..
    else
        TMP_PROFILE_DIR=`mktemp -d -t shallowflashprofile.XXXXXXXXXXXX`
    fi
    backup_profile ${TMP_PROFILE_DIR}
fi

####################
# Processing Gaia  #
####################
if [[ $FLASH_GAIA == true ]]; then
    echo "### Procesando Gaia: $FLASH_GAIA_FILE"
    shallow_flash_gaia $FLASH_GAIA_FILE
fi


####################
# Processing Gecko #
####################
if [[ $FLASH_GECKO == true ]]; then
    echo "### Procesando Gecko: $FLASH_GECKO_FILE"
    shallow_flash_gecko $FLASH_GECKO_FILE
fi


####################
# NO FTU           #
####################
if [[ ${NO_FTU} == true ]]; then
    if [[ -f ./disable_ftu.py ]]; then
        echo "### Procesando NO FTU..."
        ./disable_ftu.py
        echo "### NO FTU realizado."
    fi
fi


####################
# Restore Profile  #
####################
if [[ $KEEP_PROFILE == true ]] && ([[ $FLASH_GAIA == true ]] || [[ $FLASH_GECKO == true ]]) ; then
    restore_profile ${TMP_PROFILE_DIR}
    remove_profile ${TMP_PROFILE_DIR}
fi

## Hack for windows with cygwin for permission issue
## should use the correct permission instead of 777
## TODO: resolve in some better way in the future?
if [[ `uname` == "CYGWIN"* ]]; then
    run_adb shell chmod 777 /system/b2g/b2g
    run_adb shell chmod 777 /system/b2g/updater
    run_adb shell chmod 777 /system/b2g/run-mozilla.sh
    run_adb shell chmod 777 /system/b2g/plugin-container
fi &&

####################
# ADB Work         #
####################
adb_reboot


####################
# Version          #
####################
if [[ -e ./check_versions.sh ]]; then
    bash ./check_versions.sh
fi


####################
# Done             #
####################
echo -e "### Flasheo exitoso!!"

