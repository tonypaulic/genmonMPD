#!/usr/bin/env bash
#	descript: genmon plugin to query mpd, create album cover, and print out with song info
# 	requires: mpd mpc ffmpeg imagemagick

# set mpd music_directory
MUSIC="/home/toz/Music"

# symobls for tootip
S1="$(echo -e '\U266B')"
S2="$(echo -e '\U25B7')"
S3="$(echo -e '\U2707')"

# extract the metadata
IFS=';' read -r FILE TITLE ARTIST <<< $(mpc -f "%file%;%title%;%artist%" | head -1)
	# deal with the ampersand so pango can handle it
	TITLE="$(echo $TITLE | sed -e "s/&/&amp;/g")"
	ARTIST="$(echo $ARTIST | sed -e "s/&/&amp;/g")"
STATUS="<big>$S1</big>  $(mpc status | sed -e "s/&/&amp;/g" | \
													sed -e "s/\[/\n$S2   [/" | \
													sed -e "s/volume/\n$S3   volume/")"

# if no title, show filename
[[ "$TITLE" == "" ]] && TITLE="$FILE" && ARTIST="(no metadata)"
	
# if the filename has changed...
if [ "$FILE" != "$(cat /tmp/.music.txt)" ]; then

	# extract and resize the cover art
	ffmpeg -y -i "$MUSIC/$FILE" -an -c:v copy /tmp/.music.jpg > /dev/null 2>&1
		[[ $? -eq 0 ]] || cp /home/toz/vinyl.jpg /tmp/.music.jpg
	magick /tmp/.music.jpg -resize 32x32 /tmp/.music.jpg
	
	# save the filename for next iteration comparison
	echo $FILE > /tmp/.music.txt
	
fi

# do the genmon
echo -e "<img>/tmp/.music.jpg</img>"
echo -e "<click>xfmpc</click>"
echo -e "<txt>$TITLE\n$ARTIST</txt>"
echo -e "<txtclick>xfmpc</txtclick>"
echo -e "<tool>$STATUS</tool>"
	
exit 0
