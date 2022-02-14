#!/bin/bash
#               _             _____ _
#     /\       | |           |  __ (_)
#    /  \   ___| |_ _ __ ___ | |__) |
#   / /\ \ / __| __| '__/ _ \|  ___/ |
#  / ____ \__ \ |_| | | (_) | |   | |
# /_/    \_\___/\__|_|  \___/|_|   |_|
########### AstroPi System ###########

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

IndexPath="${HOME}"/.local/share/kstars/astrometry

cd ${IndexPath} || exit 1
for y in `seq -w 00 47`; do
	for x in `seq -w 00 04`; do
		Index=("index-42${x}-${y}.fits")
		if [ ! -f ${Index} ]; then
        		# Download missing Index file
        		( wget http://data.astrometry.net/4200/index-42${x}-${y}.fits ) 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | \
			zenity --progress --title="Downloading ${Index}..." --pulsate --auto-close --auto-kill --width=420
		else
        	echo "${Index} found in ${IndexPath}"
		fi
	done
done

for y in `seq -w 00 11`; do
	for x in `seq -w 05 07`; do
		Index=("index-42${x}-${y}.fits")
		if [ ! -f ${Index} ]; then
        		# Download missing Index file
        		( wget http://data.astrometry.net/4200/index-42${x}-${y}.fits ) 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | \
			zenity --progress --title="Downloading ${Index}..." --pulsate --auto-close --auto-kill --width=420
		else
        		echo "${Index} found in ${IndexPath}"
		fi
	done
done

for x in `seq -w 4208 4219`; do
	Index=("index-${x}.fits")
	if [ ! -f ${Index} ]; then
        	# Download missing Index file
        	( wget http://data.astrometry.net/4200/index-${x}.fits ) 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | \
		zenity --progress --title="Downloading ${Index}..." --pulsate --auto-close --auto-kill --width=420
	else
		echo "${Index} found in ${IndexPath}"
	fi
done

# Check Thyco2 Index for Astrometry
# Tycho-2 catalog; scales 7-19 available, good for images wider than 1 degree.
for x in `seq -w 4107 4119`; do
	Index=("index-${x}.fits")
	if [ ! -f ${Index} ]; then
        	# Download missing Index file
        	( wget http://data.astrometry.net/4100/index-${x}.fits ) 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, Time \3/' | \
		zenity --progress --title="Downloading ${Index}..." --pulsate --auto-close --auto-kill --width=420
	else
		echo "${Index} found in ${IndexPath}"
	fi
done
