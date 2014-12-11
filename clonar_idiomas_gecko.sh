#!/bin/bash
echo -e "\n----------------------------------------------"
echo -e "----      Clonador de idiomas GECKO       ----"
echo -e "----    Script creado por @amirtorrez     ----"
echo -e "----------------------------------------------"

LANG_DIR="gecko-l10n"; ## Carpeta donde irán todos los idiomas

## Se verifica que el paquete mercurial esté instalado
if [ -x /usr/bin/hg ]; then
## si está instalado se ejecuta el script

## Si existe la carpeta anterior la borramos
## para meter los nuevos archivos dentro
if [ -d $LANG_DIR ];
then
rm -r -f $LANG_DIR
fi

echo -e "\nClonando idiomas\n";
## Clonamos los idiomas desde mozilla
hg clone https://hg.mozilla.org/l10n-central/bn-BD $LANG_DIR/bn-BD
hg clone https://hg.mozilla.org/l10n-central/de $LANG_DIR/de
hg clone https://hg.mozilla.org/l10n-central/el $LANG_DIR/el
hg clone https://hg.mozilla.org/l10n-central/en-GB $LANG_DIR/en-GB
hg clone https://hg.mozilla.org/l10n-central/es-MX $LANG_DIR/es-MX
hg clone https://hg.mozilla.org/l10n-central/fr $LANG_DIR/fr
hg clone https://hg.mozilla.org/l10n-central/hi-IN $LANG_DIR/hi-IN
hg clone https://hg.mozilla.org/l10n-central/hu $LANG_DIR/hu
hg clone https://hg.mozilla.org/l10n-central/it $LANG_DIR/it
hg clone https://hg.mozilla.org/l10n-central/ja $LANG_DIR/ja
hg clone https://hg.mozilla.org/l10n-central/pl $LANG_DIR/pl
hg clone https://hg.mozilla.org/l10n-central/pt-BR $LANG_DIR/pt-BR
hg clone https://hg.mozilla.org/l10n-central/ru $LANG_DIR/ru
hg clone https://hg.mozilla.org/l10n-central/zh-CN $LANG_DIR/zh-CN

## Nos ubicamos dentro la carpeta de los idiomas
cd $LANG_DIR

## Creamos el archivo all-locales
cat << EOF > $LANG_DIR/all-locales
bn-BD
de
el
en-GB
es-MX
fr
hi-IN
hu
it
ja
pl
pt-BR
ru
zh-CN
EOF

## Si el paquete mercurial no está instalado
## se muestra un aviso al usuario
else
echo -e '\nSe necesita "mercurial" instalado para usar este script.\n';
fi
