#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
####### AstroPi update system ########

# Source http://data.astrometry.net
# "4200-series" index files for Astrometry.net
# ============================================

# These files use 2MASS as the astrometric reference catalog.
# http://www.ipac.caltech.edu/2mass/releases/allsky/index.html

# "This publication makes use of data products from the Two Micron All
# Sky Survey, which is a joint project of the University of
# Massachusetts and the Infrared Processing and Analysis
# Center/California Institute of Technology, funded by the National
# Aeronautics and Space Administration and the National Science
# Foundation."

# The filenames are:  index-42XX-YY.fits.bz2

# XX is the "scale": 01, the smallest, contains micro-constellations
# between 2.8 and 4 arcminutes in diameter.  This scale number is the
# same as in the earlier "200-series" of files.

# YY is the "healpix" tile number.

# For scales 01, 02, 03, and 04, we split the sky into 48 healpix tiles.
#  See the file "hp2.png" for a map of where they are in RA,Dec.

# For scales 05, 06, and 07 we split the sky into 12 healpix tiles; see
# "hp.png" for the map.

# Scales 08-19 are named like index-40XX.fits.bz2 and each one covers
# the whole sky.

(
    cd ${IndexPath} || exit 1
    for i in `seq -w 00 47`; do
	if [ ! -f ${IndexPath}/index-4200-${i}.fits ]; then
	    Index=("index-4200-${i}.fits")
        # Download missing Index file
        wget http://data.astrometry.net/4200/index-4200-${i}.fits
	else
		Index=("index-4200-${i}.fits")
        echo "${Index} found"
	fi
done

for i in `seq -w 00 47`; do
	if [ ! -f ${IndexPath}/index-4201-${i}.fits ]; then
	    Index=("index-4201-${i}.fits")
        # Download missing Index file
        wget --continue http://broiler.astrometry.net/~dstn/4200/index-4201-${i}.fits
	else
		Index=("index-4201-${i}.fits")
        echo "${Index} found"
	fi
done

for i in `seq -w 00 47`; do
	if [ ! -f ${IndexPath}/index-4202-${i}.fits ]; then
	    Index=("index-4202-${i}.fits")
        # Download missing Index file
        wget --continue http://broiler.astrometry.net/~dstn/4200/index-4202-${i}.fits
	else
		Index=("index-4202-${i}.fits")
        echo "${Index} found"
	fi
done

for i in `seq -w 00 47`; do
	if [ ! -f ${IndexPath}/index-4203-${i}.fits ]; then
	    Index=("index-4203-${i}.fits")
        # Download missing Index file
        wget --continue http://broiler.astrometry.net/~dstn/4200/index-4203-${i}.fits
	else
		Index=("index-4203-${i}.fits")
        echo "${Index} found"
	fi
done

for i in `seq -w 00 47`; do
	if [ ! -f ${IndexPath}/index-4204-${i}.fits ]; then
	    Index=("index-4204-${i}.fits")
        # Download missing Index file
        wget --continue http://broiler.astrometry.net/~dstn/4200/index-4204-${i}.fits
	else
		Index=("index-4204-${i}.fits")
        echo "${Index} found"
	fi
done

for i in `seq -w 00 11`; do
	if [ ! -f ${IndexPath}/index-4205-${i}.fits ]; then
	    Index=("index-4205-${i}.fits")
        # Download missing Index file
        wget --continue http://broiler.astrometry.net/~dstn/4200/index-4205-${i}.fits
	else
		Index=("index-4205-${i}.fits")
        echo "${Index} found"
	fi
done

for i in `seq -w 00 11`; do
	if [ ! -f ${IndexPath}/index-4206-${i}.fits ]; then
	    Index=("index-4206-${i}.fits")
        # Download missing Index file
        wget --continue http://broiler.astrometry.net/~dstn/4200/index-4206-${i}.fits
	else
		Index=("index-4206-${i}.fits")
        echo "${Index} found"
	fi
done

for i in `seq -w 00 11`; do
	if [ ! -f ${IndexPath}/index-4207-${i}.fits ]; then
	    Index=("index-4207-${i}.fits")
        # Download missing Index file
        wget --continue http://broiler.astrometry.net/~dstn/4200/index-4207-${i}.fits
	else
		Index=("index-4207-${i}.fits")
        echo "${Index} found"
	fi
done

for i in `seq -w 4208 4219`; do
	if [ ! -f ${IndexPath}/index-${i}.fits ]; then
	    Index=("index-${i}.fits")
        # Download missing Index file
        wget --continue http://broiler.astrometry.net/~dstn/4200/index-${i}.fits
	else
		Index=("index-${i}.fits")
        echo "${Index} found"
	fi
done

# Check Thyco2 Index for Astrometry
# Tycho-2 catalog; scales 7-19 available, good for images wider than 1 degree.
for i in `seq -w 4107 4119`; do
	if [ ! -f ${IndexPath}/index-${i}.fits ]; then
	    Index=("index-${i}.fits")
        # Download missing Index file
        wget http://data.astrometry.net/4100/index-${i}.fits
	else
		Index=("index-${i}.fits")
        echo "${Index} found"
	fi
done

) | zenity --progress --title="${W_Title}" --percentage=1 --pulsate --auto-close --auto-kill --width=${Wprogress}