#!/bin/bash

INK=/Applications/Inkscape.app/Contents/Resources/bin/inkscape

if [[ -z "$1" ]]
then
	echo "SVG file needed."
	exit;
fi

BASE=`basename "$1" .svg`
SVG="$1"

"$INK" -z -D -e "$BASE-20@2x.png" -f 	$SVG -w 40 -h 40
"$INK" -z -D -e "$BASE-20@3x.png" -f 	$SVG -w 60 -h 60

"$INK" -z -D -e "$BASE-29@2x.png" -f 	$SVG -w 58 -h 58
"$INK" -z -D -e "$BASE-29@3x.png" -f 	$SVG -w 87 -h 87

"$INK" -z -D -e "$BASE-40@2x.png" -f 	$SVG -w 80 -h 80
"$INK" -z -D -e "$BASE-40@3x.png" -f 	$SVG -w 120 -h 120

"$INK" -z -D -e "$BASE-60@2x.png" -f 	$SVG -w 120 -h 120
"$INK" -z -D -e "$BASE-60@3x.png" -f 	$SVG -w 180 -h 180
