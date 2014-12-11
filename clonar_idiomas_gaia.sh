#!/bin/bash
echo -e "\n----------------------------------------------"
echo -e "----      Clonador de idiomas GAIA        ----"
echo -e "----    Script creado por @amirtorrez     ----"
echo -e "----------------------------------------------"

LANG_DIR="gaia-l10n"; ## Carpeta donde irá todo
LANG_VERSION="master"; ## Version de B2G para los idiomas (master,v2_1, v2_0, v1_4, etc)

## Se verifica que el paquete mercurial esté instalado
if [ -x /usr/bin/hg ]; then
## si está instalado se ejecuta el script

## Si existe la carpeta anterior la borramos
## para meter los nuevos archivos dentro
if [ -d $LANG_DIR ];
then
rm -r -f $LANG_DIR
fi

## Definimos la url de descarga
## dependiendo la version de B2G
if [ "$LANG_VERSION" = "master" ]; then
	LANG_URL="gaia-l10n";
else
	LANG_URL="releases/gaia-l10n/$LANG_VERSION";
fi

echo -e "\nClonando idiomas\n";
## Clonamos los idiomas desde mozilla
hg clone https://hg.mozilla.org/$LANG_URL/bn-BD $LANG_DIR/bn-BD
hg clone https://hg.mozilla.org/$LANG_URL/de $LANG_DIR/de
hg clone https://hg.mozilla.org/$LANG_URL/el $LANG_DIR/el
hg clone https://hg.mozilla.org/$LANG_URL/en-US $LANG_DIR/en-US
hg clone https://hg.mozilla.org/$LANG_URL/es $LANG_DIR/es
hg clone https://hg.mozilla.org/$LANG_URL/fr $LANG_DIR/fr
hg clone https://hg.mozilla.org/$LANG_URL/hi-IN $LANG_DIR/hi-IN
hg clone https://hg.mozilla.org/$LANG_URL/hu $LANG_DIR/hu
hg clone https://hg.mozilla.org/$LANG_URL/it $LANG_DIR/it
hg clone https://hg.mozilla.org/$LANG_URL/ja $LANG_DIR/ja
hg clone https://hg.mozilla.org/$LANG_URL/pl $LANG_DIR/pl
hg clone https://hg.mozilla.org/$LANG_URL/pt-BR $LANG_DIR/pt-BR
hg clone https://hg.mozilla.org/$LANG_URL/ru $LANG_DIR/ru
hg clone https://hg.mozilla.org/$LANG_URL/zh-CN $LANG_DIR/zh-CN

## Creamos el archivo languages_dev.json
cat << EOF > gaia-l10n/languages_dev.json
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
  "zh-CN"     : "中文 (简体)"
}
EOF

## Nos ubicamos dentro la carpeta de los idiomas
cd $LANG_DIR

## Descargamos el archivo json que lista todos los idiomas
wget https://raw.githubusercontent.com/amirtorrez/b2g-custome/master/gaia-l10n/languages_all.json

## Si el paquete mercurial no está instalado
## se muestra un aviso al usuario
else
echo -e '\nSe necesita "mercurial" instalado para usar este script.\n';
fi
