Prepared customization to build B2G, with languages like:
- বাংলা (বাংলাদেশ)
- Deutsch
- Ελληνικά
- English (US)
- Español
- Français
- हिन्दी (भारत)
- Magyar
- Italiano
- 日本語
- Polski
- Português (do Brasil)
- Русский
- 中文 (简体)


And including .userconfig file with build preferences, also a bash scripts to update languages and a personalisation of GAIA since <a href="https://vegnuxmod.wordpress.com" target="_blank">VegnuxMod</a>.

To download languages edit sh scripts variables:

In <b>clonar_idiomas_gaia.sh</b>
- <b>LANG_DIR="gaia-l10n";</b> --> Is a folder where download GAIA languages
- <b>LANG_VERSION="master";</b>  --> Is a GAIA version like B2G, example: v1_2,v1_3,v2_0, etc, master is a last version of B2G

In <b>clonar_idiomas_gecko.sh</b>
- <b>LANG_DIR="gecko-l10n";</b> --> Is a folder where download GECKO languages

Change file permissions:<br>
$>  chmod 777 clonar_idiomas_gaia.sh<br>
$>  chmod 777 clonar_idiomas_gecko.sh

And run in console:<br>
./clonar_idiomas_gaia.sh  &&  ./clonar_idiomas_gecko.sh
