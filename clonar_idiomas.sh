#!/bin/bash
echo -e "\n----------------------------------------------"
echo -e "----       Clonador de idiomas B2G        ----"
echo -e "----    Script creado por @amirtorrez     ----"
echo -e "----------------------------------------------"

## Variables de idiomas
LANG_DIR="gaia-l10n"; ## Carpeta donde irán todos los idiomas de GAIA
LANG_VERSION="master"; ## Version de B2G para los idiomas (master,v2_5, v2_2, v2_0, v1_4, etc)
LANG_LIST=("bn-BD" "de" "el" "en-US" "es" "fr" "hi-IN" "hu" "it" "ja" "pl" "pt-BR" "ru" "sv-SE" "tr" "zh-CN"); ## Lista de idiomas a descargar

## Se verifica que el paquete mercurial esté instalado
if [ -x /usr/bin/hg ]; then
## si está instalado se ejecuta el script

## Si existe la carpeta anterior la borramos para meter los nuevos archivos dentro
if [ -d $LANG_DIR ]; then
	rm -r -f $LANG_DIR
fi

## Creamos de nuevo la carpeta
mkdir $LANG_DIR

## Definimos la url de descarga dependiendo la version de B2G
if [ "$LANG_VERSION" = "master" ]; then
	LANG_URL="gaia-l10n";
else
	LANG_URL="releases/gaia-l10n/$LANG_VERSION";
fi

echo -e "\nClonando idiomas GAIA";
## Clonamos los idiomas desde mozilla
for (( i = 0; i < ${#LANG_LIST[@]}; i++ ));
do
	echo -e "\n## Descargando el idioma: ${LANG_LIST[$i]} ##";
	hg clone https://hg.mozilla.org/$LANG_URL/${LANG_LIST[$i]} $LANG_DIR/${LANG_LIST[$i]};
done

## Nos ubicamos dentro la carpeta de los idiomas
cd $LANG_DIR

## Creamos el archivo languages_dev.json
cat << EOF > languages_dev.json
{
  "bn-BD"     : "বাংলা (বাংলাদেশ)",
  "de"        : "Deutsch",
  "el"        : "Ελληνικά",
  "en-US"     : "English (US)",
  "es"        : "Español",
  "fr"        : "Français",
  "hi-IN"     : "हिन्दी (भारत)",
  "hu"        : "Magyar",
  "it"        : "Italiano",
  "ja"        : "日本語",
  "pl"        : "Polski",
  "pt-BR"     : "Português (do Brasil)",
  "ru"        : "Русский",
  "sv-SE"     : "Svenska",
  "tr"        : "Türkçe",
  "zh-CN"     : "中文 (简体)"
}
EOF

## Descargamos el archivo json que lista todos los idiomas
wget https://raw.githubusercontent.com/amirtorrez/b2g-custome/master/gaia-l10n/languages_all.json

## Si el paquete mercurial no está instalado se muestra un aviso al usuario
else
echo -e '\nSe necesita "mercurial" instalado para usar este script.\n';
fi
