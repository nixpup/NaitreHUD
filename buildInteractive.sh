#!/usr/bin/env bash

buildProcess() {
    read -p "[ Begin build process? ] ( y|yes / n|no ) ~> " beginBuildProcess
    beginBuildProcess=${beginBuildProcess,,}
    if [[ "$beginBuildProcess" = "y" || "$beginBuildProcess" = "yes" ]]; then
	echo "[ Starting build process... ]"
        mkdir -p build
        meson setup build || return 1
        ninja -C build || return 1
        echo "[ Build process finished! ]"
    else
        echo "[ Aborted build process. ]"
        return 1
    fi
}

read -p "[ Cleanup builds beforehand? ] ( y|yes / n|no ) ~> " cleanupBeforehand
cleanupBeforehand=${cleanupBeforehand,,}
case "$cleanupBeforehand" in
    y|yes)
	rm -rf build/
        echo "[ Cleaned up old builds! ]"
	buildProcess
	;;
    n|no)
	buildProcess
	;;
    *)
	echo "[ Invalid answer/input! ]"
	exit 1
	;;
esac
