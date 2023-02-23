#!/bin/bash
starttime=`date +%s`

PWD
moviedir='/Users/alexandriatis/UCSD/Andriatis_Thesis/Projects/LangmuirCirculation/Model_Output/Model_Movie'
pardir='parfigs_movie'
moviename='MyMovie'
echo "$moviedir/$pardir/"

ffmpeg -framerate 30 -pattern_type glob -i "$moviedir/$pardir/*.png"  -c:v libx264 -pix_fmt yuv420p -y $moviedir/$moviename.mp4

endtime=`date +%s`
runtime=$((endtime-starttime))
echo "Runtime is " $runtime " seconds"
date
