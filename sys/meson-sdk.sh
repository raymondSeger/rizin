#!/bin/sh
# sys/meson.py || exit 1
sys/meson.py --options use_libuv=false use_sys_magic=false || exit 1
(
	cd build || exit 1
	rm -rf a
	mkdir a
	for a in `find *| grep '\.a$' | grep -v 'librz\.a'` ; do
		echo $a
		b=`basename $a`
		mkdir a/$b
		(cd a/$b ; ${AR} xv ../../$a) > /dev/null
	done
	(
		rm -f librz.a
		cd a
		${AR} rs ../librz.a */*.o
	)
)
D=rizin-sdk
rm -rf $D
mkdir -p $D/lib || exit 1
cp -rf librz/include $D
cp -f build/r_userconf.h $D/include
cp -f build/r_version.h $D/include
cp -f build/librz.a $D/lib
rm -f $D.zip
zip -r $D.zip $D > /dev/null

cat > .test.c <<EOF
#include <rz_core.h>
int main() {
	RzCore *core = rz_core_new ();
	rz_core_free (core);
}
EOF
gcc .test.c -I $D/include $D/lib/librz.a
