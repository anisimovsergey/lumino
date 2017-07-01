#!/bin/bash

INK=/Applications/Inkscape.app/Contents/Resources/bin/inkscape

if [[ -z "$1" ]]
then
	echo "SVG file needed."
	exit;
fi

BASE=`basename "$1" .svg`
SVG="$1"

"$INK" -z -D -e "$BASE-40.png" -f 		$SVG -w 120 -h 40
"$INK" -z -D -e "$BASE-40@2x.png" -f 	$SVG -w 240 -h 80
"$INK" -z -D -e "$BASE-40@3x.png" -f 	$SVG -w 360 -h 120
