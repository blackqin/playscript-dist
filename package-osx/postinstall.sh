#!/bin/sh
if [ -f /usr/bin/playc ]; then
   rm /usr/bin/playc
fi
ln -s /Library/Frameworks/PlayScript.framework/Commands/playc /usr/bin/playc
if [ ! -d "/Library/Frameworks/Mono.framework/External" ]; then
	mkdir "/Library/Frameworks/Mono.framework/External"
fi
if [ ! -d "/Library/Frameworks/Mono.framework/External/pkgconfig" ]; then
	mkdir "/Library/Frameworks/Mono.framework/External/pkgconfig"
fi
cp "/Library/Frameworks/PlayScript.framework/Libraries/pkgconfig/playscript.pc" "/Library/Frameworks/Mono.framework/External/pkgconfig"
exit 0
