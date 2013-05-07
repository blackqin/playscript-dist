echo "Building PlayScript distribution files for OSX."

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION=`cat version`

pushd playscript-mono
git clean -xdf
git reset --hard
git submodule update
git submodule foreach git clean -xdf
git submodule foreach git reset --hard
./autogen.sh --prefix=$ROOT_DIR/playscript-mono-inst --with-glib=embedded --enable-nls=no
rm -rf $ROOT_DIR/playscript-mono-inst
make
make install
popd

pushd playscript-monodevelop
git clean -xdf
git reset --hard
git submodule update
git submodule foreach git clean -xdf
git submodule foreach git reset --hard
export ACLOCAL_FLAGS="-I /Library/Frameworks/Mono.framework/Versions/Current/share/aclocal"
export PATH="/Library/Frameworks/Mono.framework/Versions/Current/bin:$PATH"
export DYLD_FALLBACK_LIBRARY_PATH=/Library/Frameworks/Mono.framework/Versions/Current/lib:/lib:/usr/lib
./configure --profile=mac
make
popd

pushd package-osx
./build-playscript-inst-osx.sh $VERSION
popd

pushd playscript-monodevelop-binding
./rebuild-binding.sh $VERSION
popd

echo "Copying distribution files to /bin/osx folder."
if [ ! -d ./bin ]; then
  mkdir ./bin
fi
if [ -d ./bin/osx ]; then
  rm -rf ./bin/osx
fi
mkdir ./bin/osx
cp ./package-osx/PlayScript-$VERSION ./bin/osx
cp ./playscript-monodevelop-binding/addin-build/MonoDevelop.PlayScriptBinding_* ./bin/osx

echo "PlayScript distribution files complete for OSX."