#!/bin/bash

## script per extreure el fitxer font d'una URL de 3cat
## #####################################################

URL="$1"
[ "$URL" == "" ] && echo "ERROR: has d'especificar una URL" && exit 1

# base URL (en principi no canvia)
URL_BASE="https://audios.ccma.cat/multimedia"

# identificador del fitxers
URL_ID=`echo "$URL" | grep -o -P "(/audio/).*($)" | cut -d"/" -f3`

# echo "`date '+%Y-%m-%d %T'` - $0 - ID fitxer [$URL_ID]"

# comprovacions
wget -V > /dev/null 
if [ "$?" != "0" ]; then
    echo "ERROR: no s'ha trobat la comanda wget"
    exit 1
fi
gron --version > /dev/null
if [ "$?" != "0" ]; then
    echo "ERROR: no s'ha trobat la comanda gron"
    exit 1
fi

# volcat de la pàgina
URL_TEXT=`wget -q --output-document - "$URL"`

# embellir-ho
# cat index.html | tidy -i > dos.html

# https://audios.ccma.cat/multimedia/mp3/8/4/1702815945148.mp3

# cadena que conté el json amb tota la info del reproductor
# <script id="__NEXT_DATA__" type="application/json">
# </script>

# extreim el json i descartam la resta del html
# JSON_TEXT=`echo "$URL_TEXT" | grep -o -P '(<script id="__NEXT_DATA__" type="application/json">).*(</script>)' | grep -o '</script>'`
JSON_TEXT=`echo "$URL_TEXT" | grep -o -P '(<script id="__NEXT_DATA__" type="application/json">).*(</script>)' | sed 's,^<script id="__NEXT_DATA__" type="application/json">,,'`
# echo "DEBUG: JSON_TEXT [$JSON_TEXT]" ; exit 1

# tranformam el json amb gron
GRON_TEXT=`echo "$JSON_TEXT" | gron`

# ens quedam només amb els items del ID que hem demanat
# json.props.pageProps.layout.structure[4].children[0].finalProps.items[2].id = 1192101;
GRON_ITEMS=`echo "$GRON_TEXT" | grep "finalProps.items.*id = $URL_ID" | sed "s/id = ${URL_ID}.*//"`

# echo "DEBUG: GRON_ITEMS [$GRON_ITEMS]"

# extreim el mp3 (al loro amb -F del grep)
GRON_MP3=`echo "$GRON_TEXT" | grep -F "$GRON_ITEMS" | grep 'text = "mp3' | cut -d'"' -f2`

# echo "DEBUG: GRON_MP3 [$GRON_MP3]"

# completam la URL del mp3 final
URL_MP3_DESCARREGA="${URL_BASE}/${GRON_MP3}"

# echo "DEBUG: URL_MP3_DESCARREGA [$URL_MP3_DESCARREGA]"

wget -nv "$URL_MP3_DESCARREGA"
