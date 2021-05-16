#!/bin/bash
cd /home/astropi/.local/share/kstars/astrometry
	wget http://data.astrometry.net/debian/astrometry-data-4208-4219_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4207_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4206_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4205_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4204_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4203_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4202_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4201-1_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4201-2_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4201-3_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4201-4_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4200-1_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4200-2_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4200-3_0.45_all.deb
	wget http://data.astrometry.net/debian/astrometry-data-4200-4_0.45_all.deb

sudo dpkg -i astrometry-data-*.deb
sudo rm *.deb



