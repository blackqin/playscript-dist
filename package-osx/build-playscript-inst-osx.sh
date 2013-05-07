if [[ -z "$1" ]]; then
	echo "Builds the playscript osx install framework folder and install package."
	echo "Usage: ./build-playscript-inst-osx.sh version"
	echo "    Example: ./build-playscript-inst-osx.sh 1.2.0"
	exit -1
fi

#
# Create the PlayScript.framework folder
#

PLAYSCRIPT_MONO="../playscript-mono"
PLAYSCRIPT_MONO_INST="../playscript-mono-inst"
PLAYSCRIPT_FRAMEWORK="./PlayScript.framework"
PLAYSCRIPT_OUT="$PLAYSCRIPT_FRAMEWORK/Versions/$1"

echo "Building playscript OSX install folder image at $PLAYSCRIPT_FRAMEWORK"

if [ -d "$PLAYSCRIPT_FRAMEWORK" ]; then
	rm -rf "$PLAYSCRIPT_FRAMEWORK"
fi
mkdir "$PLAYSCRIPT_FRAMEWORK"
mkdir "$PLAYSCRIPT_FRAMEWORK/Versions"
mkdir "$PLAYSCRIPT_OUT"
cp -r "./template_osx/" "$PLAYSCRIPT_OUT"
cp "$PLAYSCRIPT_MONO_INST/lib/mono/4.5/playc.exe" "$PLAYSCRIPT_OUT/bin/playc.exe"
cp "$PLAYSCRIPT_MONO_INST/bin/playc" "$PLAYSCRIPT_OUT/bin/playc"
cp "$PLAYSCRIPT_MONO_INST/lib/mono/4.0/pscorlib.dll" "$PLAYSCRIPT_OUT/lib"
cp "$PLAYSCRIPT_MONO_INST/lib/mono/4.0/pscorlib_aot.dll" "$PLAYSCRIPT_OUT/lib"
cp "$PLAYSCRIPT_MONO_INST/lib/mono/4.0/PlayScript.Dynamic.dll" "$PLAYSCRIPT_OUT/lib"
cp "$PLAYSCRIPT_MONO_INST/lib/mono/4.0/PlayScript.Dynamic_aot.dll" "$PLAYSCRIPT_OUT/lib"
cp "$PLAYSCRIPT_MONO_INST/lib/mono/4.0/Mono.PlayScript.dll" "$PLAYSCRIPT_OUT/lib"
cp -r "$PLAYSCRIPT_MONO/mcs/class/pscorlib" "$PLAYSCRIPT_OUT/src"
cp -r "$PLAYSCRIPT_MONO/mcs/class/pscorlib_aot" "$PLAYSCRIPT_OUT/src"
cp -r "$PLAYSCRIPT_MONO/mcs/class/PlayScript.Dynamic" "$PLAYSCRIPT_OUT/src"
cp -r "$PLAYSCRIPT_MONO/mcs/class/PlayScript.Dynamic_aot" "$PLAYSCRIPT_OUT/src"
cp -r "$PLAYSCRIPT_MONO/mcs/class/Mono.PlayScript" "$PLAYSCRIPT_OUT/src"
pushd "$PLAYSCRIPT_FRAMEWORK/Versions"
ln -s "./$1" "Current"
popd
pushd "$PLAYSCRIPT_FRAMEWORK"
ln -s "./Versions/$1/bin" "Commands"
ln -s "./Versions/$1/lib" "Libraries"
popd

#
# Buils the .mpkg file
#

echo "Building install package using Packages tool by Stephane Sudre http://s.sudre.free.fr/Software/Packages/about.html"
/usr/local/bin/packagesbuild ./PlayScript.pkgproj

pushd $(dirname $0) &>/dev/null

#
# Buils the .DMG file
#

DMG_APP=./build/PlayScript.mpkg
RENDER_OP=$2

if test ! -e "$DMG_APP" ; then
	echo "Missing $DMG_APP"
	exit 1
fi

NAME="PlayScript"
VERSION=$1

#if we use the version in the volume name, Finder can't find the background image
#because the DS_Store depends on the volume name, and we aren't currently able
#to alter it programmatically
VOLUME_NAME="$NAME"

echo "Building bundle for $NAME $VERSION..."

DMG_FILE="$NAME-$VERSION.dmg"
MOUNT_POINT="$VOLUME_NAME.mounted"

rm -f "$DMG_FILE"
rm -f "$DMG_FILE.master"
 	
# Compute an approximated image size in MB, and bloat by 1MB
image_size=$(du -ck "$DMG_APP" | tail -n1 | cut -f1)
image_size=$((($image_size + 2000) / 1000))

echo "Creating disk image (${image_size}MB)..."
hdiutil create "$DMG_FILE" -megabytes $image_size -volname "$VOLUME_NAME" -fs HFS+ -quiet || exit $?

echo "Attaching to disk image..."
hdiutil attach "$DMG_FILE" -readwrite -noautoopen -mountpoint "$MOUNT_POINT" -quiet || exit $?

echo "Populating image..."
mv "$DMG_APP" "$MOUNT_POINT"

mkdir -p "$MOUNT_POINT/.background"
cp dmg-bg.png "$MOUNT_POINT/.background/dmg-bg.png"

cp DS_Store "$MOUNT_POINT/.DS_Store"
if [ -e VolumeIcon.icns ] ; then
	cp VolumeIcon.icns "$MOUNT_POINT/.VolumeIcon.icns"
	SetFile -c icnC "$MOUNT_POINT/.VolumeIcon.icns"
fi
SetFile -a C "$MOUNT_POINT"

echo "Detaching from disk image..."
hdiutil detach "$MOUNT_POINT" -quiet || exit $?

mv "$DMG_FILE" "$DMG_FILE.master"

echo "Creating distributable image..."
hdiutil convert -quiet -format UDBZ -o "$DMG_FILE" "$DMG_FILE.master" || exit $?

echo "Built disk image $DMG_FILE"

if [ ! "x$1" = "x-m" ]; then
rm "$DMG_FILE.master"
fi

rm -rf "$MOUNT_POINT"

echo "Done."

popd &>/dev/null 

#
# Done
#

echo "PlayScript $DMG_FILE install file created."
