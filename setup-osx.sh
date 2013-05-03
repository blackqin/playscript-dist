echo "Installs the pkgconfig .pc files for compiling MonoMac and MonoDevelop projects using xbuild.  Sets up links to req tools, etc."

echo "Copying MonoDevelop pkgconfig files to /Library/Frameworks/Mono.framework/External/pkgconfig folder."
sudo cp pkgconfig-osx/* /Library/Frameworks/Mono.framework/External/pkgconfig

echo "Making symlink to monodevelop libs in /usr/local/lib/monodevelop."
sudo rm /usr/local/lib/monodevelop
sudo ln -s /Applications/Xamarin\ Studio.app/Contents/MacOS /usr/local/lib/monodevelop

echo "OSX setup complete."
