#!/bin/bash

#EFFECT="fx_warp_by_intensity -2.664,-1.212,128,128,0,1,3,0,0,50,50"
EFFECT="fx_pixelsort 1,1,0,3,0,85.9,0,0,0"

mkdir frames
mkdir EXPORT

# Extract Frames From Video
echo "Extracting frames..."
ffmpeg -i ./*.mp4 -r 30/1 ./frames/out%06d.jpg 2>/dev/null

# Apply effect to each frame
cd ./frames
FILES="./*"
number=1
total=$(ls ./ | wc -l)
echo "Applying Effect..."
for f in $FILES
do
	echo -en "Rendering frame $( echo $f | sed 's/[^0-9]*//g' | sed 's/^0*//') out of $total frames\r";
	# DEBUG OUTPUT:	gmic debug input $f $EFFECT output ../EXPORT/$(( ++number )).jpg
	gmic debug input $f $EFFECT output ../EXPORT/$(( ++number )).jpg >/dev/null
done

cd ../EXPORT

# Rename files to 000X format.
for a in [0-9]*.jpg; do
    mv $a `printf %06d.%s ${a%.*} ${a##*.}`
done

# Rebuild Video with new frames
echo ""
echo "Building Video..."
ffmpeg -framerate 30 -pattern_type glob -i '*.jpg' \
  -c:v libx264 -pix_fmt yuv420p out.mp4 2>/dev/null
  
mv out.mp4 ../
cd ../
# Remove these if you want to keep the extracted and edited frames
rm -r ./EXPORT
rm -r ./frames

mpv out.mp4
