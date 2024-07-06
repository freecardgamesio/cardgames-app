#!/bin/sh
echo 'Make sure to run \033[1;31msudo ./install_deps.sh\033[0m before compiling!\n'

PREFIX="../install"
OFFICIAL_BUILD=ON

clean() {
	rm -rf build
	rm -rf build_cef
	rm -rf install
	rm -rf build_package
	rm *.deb
	rm *.rpm
	echo 'Cleaned'
}

build_cardgames() {
	if [ ! -d "build" ]; then
		mkdir build
	fi
	cd build
	cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_CEF=OFF -DWITH_GTEST=OFF -DOFFICIAL_BUILD=$OFFICIAL_BUILD -DFORCE_BUNDLED_WXGTK=$OFFICIAL_BUILD -DFORCE_BUNDLED_BOOST=$OFFICIAL_BUILD -DFORCE_BUNDLED_CURL=$OFFICIAL_BUILD || exit 1
	NUM_PROC=`nproc`
	echo "${NUM_PROC} processors detected"
#	make V=1 -j${NUM_PROC} install $@
	make -j${NUM_PROC} install $@
	cd ..
	echo 'Building CardGames completed'
}

build_cef() {
	if [ ! -d "build_cef" ]; then
		mkdir build_cef
	fi
	cd build_cef
	cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_ONLY_CEF=ON -DFORCE_BUNDLED_BOOST=ON || exit 1
	NUM_PROC=`nproc`
	echo "${NUM_PROC} processors detected"
	make -j${NUM_PROC} install $@
	cd ..
	echo 'Building CEF completed'
}

pack() {
	if [ ! -d "build_package" ]; then
		mkdir build_package
	fi
	cd build_package
	cmake .. -DPACKAGE_TYPE=$PACKAGE -DINSTALL_DESKTOP_FILE=ON -DCMAKE_INSTALL_PREFIX="/opt/cardgames" -DDESKTOP_EXE="/opt/cardgames/cardgames" -DDESKTOP_ICON="/opt/cardgames/cardgames.png" -DOFFICIAL_BUILD=$OFFICIAL_BUILD -DFORCE_BUNDLED_WXGTK=$OFFICIAL_BUILD -DFORCE_BUNDLED_BOOST=$OFFICIAL_BUILD -DFORCE_BUNDLED_CURL=$OFFICIAL_BUILD || exit 1
	NUM_PROC=`nproc`
	echo "${NUM_PROC} processors detected"
	make -j${NUM_PROC} package $@
	if [ $PACKAGE = "DEB" ]; then
		mv CardGames-*.deb ..
	elif [ $PACKAGE = "RPM" ]; then
		mv CardGames-*.rpm ..
	fi
	echo 'Building $PACKAGE completed'
	cd ..
}

if [ -z "$1" ]; then
	build_cardgames || exit 2
	build_cef || exit 2
elif [ "$1" = "clean" ]; then
	shift
	clean
elif [ "$1" = "pack" ]; then
	shift
	PACKAGE="$1"
	shift
	pack || exit 2
elif [ "$1" = "release" ]; then
	shift
	PACKAGE="$1"
	OFFICIAL_BUILD="ON"
	shift
	pack || exit 2
elif [ "$1" = "only_cardgames" ]; then
	shift
	build_cardgames || exit 2
elif [ "$1" = "only_cef" ]; then
	shift
	build_cef || exit 2
elif [ "$1" = "help" ]; then
	echo 'This script will allow you to easy compile Card Games on Linux.'
	echo 'Type "./build_cardgames.sh clean" to remove build files.'
	echo 'Type "./build_cardgames.sh" to build Card Games client.'
	echo 'Type "./build_cardgames.sh pack DEB" to prepare .deb package.'
	echo 'Type "./build_cardgames.sh pack RPM" to prepare .rpm package.'
	echo 'Type "./build_cardgames.sh only_cardgames" to compile Card Games without CEF(Chormium Embedded Framework).'
	echo 'Type "./build_cardgames.sh only_cef" to compile CEF without Card Games.'
	echo 'Type "./build_cardgames.sh help" to display this message.'
	echo 'Any additonal shell argument will be given to "make" command.\n'
fi

echo 'Run \033[1;31m./install/cardgames\033[0m to start Card Games!'
