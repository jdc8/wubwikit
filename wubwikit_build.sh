#!/bin/sh

rm -Rf wubwikit.vfs

# Create directory structure for starkit vfs
mkdir -p wubwikit.vfs/lib
cd wubwikit.vfs/lib

# Get WUB
svn checkout http://wub.googlecode.com/svn/trunk wub
find . -name ".svn" | xargs rm -Rf

# Get wikit
svn checkout http://wikitcl.googlecode.com/svn/trunk wikitcl
find . -name ".svn" | xargs rm -Rf

# Login to sourceforge cvs server
# cvs -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib login

# Get tclib packages
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d struct -P tcllib/modules/struct
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d snit -P tcllib/modules/snit
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d fileutil -P tcllib/modules/fileutil
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d cmdline -P tcllib/modules/cmdline
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d dns -P tcllib/modules/dns
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d tie -P tcllib/modules/tie
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d crc -P tcllib/modules/crc
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d textutil -P tcllib/modules/textutil
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d csv -P tcllib/modules/csv
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d tar -P tcllib/modules/tar
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d jpeg -P tcllib/modules/jpeg
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d inifile -P tcllib/modules/inifile
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d md5 -P tcllib/modules/md5
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d mime -P tcllib/modules/mime
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d base64 -P tcllib/modules/base64

# Optional: remove test and documentations file to keep size of .kit low
cd ..
find . -name "CVS" | xargs rm -Rf
find . -name "*.test" | xargs rm
find . -name "*.testsuite" | xargs rm
find . -name "*.testsupport" | xargs rm
find . -name "*.man" | xargs rm
find . -name "*.bench" | xargs rm
#find . -name "*.html" | xargs rm
find . -name "ChangeLog" | xargs rm
find . -name "*.[ch]" | xargs rm
cd ..

# Copy/move some files
cp local.tcl wubwikit.vfs/lib/wikitcl/wubwikit/local.tcl
cp local.tcl wubwikit.vfs/deflocal.tcl
cp vars.tcl wubwikit.vfs/lib/wikitcl/wubwikit/vars.tcl
cp wikit.ini wubwikit.vfs/lib/wikitcl/wubwikit/wikit.ini
cp wubwikit_main.tcl wubwikit.vfs/main.tcl
cp welcome.html wubwikit.vfs/lib/wikitcl/wubwikit/docroot/html
cp wikitoc.jpg wubwikit.vfs/lib/wikitcl/wubwikit/docroot/images
mkdir -p wubwikit.vfs/lib/tdbc
# Get tdbc::sqlite3 from tdbc.tcl.tk manually
cp sqlite3-1.0b13.tm wubwikit.vfs/lib/tdbc
cp tdbc_sqlite3_pkgIndex.tcl wubwikit.vfs/lib/tdbc/pkgIndex.tcl
cp wikit.config.templ wubwikit.vfs/lib/wikitcl/wubwikit
cp wub.config wubwikit.vfs

mkdir -p builds

# Create Linux starkit
cp -r teapot/linux/* wubwikit.vfs/lib
sdx wrap wubwikit.kit -writable
mv wubwikit.kit builds/wubwikit-linux-`date +%Y%m%d`.kit
tclsh8.6 mkzip.tcl wubwikit.zipkit -zipkit -directory wubwikit.vfs
mv wubwikit.zipkit builds/wubwikit-linux-`date +%Y%m%d`.zipkit
rm -Rf wubwikit.vfs/lib/sqlite33.6.23  
rm -Rf wubwikit.vfs/lib/tdbc1.0b14.1

# Create Windows starkit
cp -r teapot/windows/* wubwikit.vfs/lib
sdx wrap wubwikit.kit -writable
mv wubwikit.kit builds/wubwikit-windows-`date +%Y%m%d`.kit
tclsh8.6 mkzip.tcl wubwikit.zipkit -zipkit -directory wubwikit.vfs
mv wubwikit.zipkit builds/wubwikit-windows-`date +%Y%m%d`.zipkit
rm -Rf wubwikit.vfs/lib/sqlite33.6.23  
rm -Rf wubwikit.vfs/lib/tdbc1.0b14.1

# Create zip without binaries
mv wubwikit.vfs wubwikit`date +%Y%m%d`.vfs
zip -r wubwikit`date +%Y%m%d`.vfs.zip wubwikit`date +%Y%m%d`.vfs
mv wubwikit`date +%Y%m%d`.vfs.zip builds
mv wubwikit`date +%Y%m%d`.vfs wubwikit.vfs

# Create Wub-only zipkit without binaries
cp wub_main.tcl wubwikit.vfs/main.tcl
rm -Rf wubwikit.vfs/lib/wikitcl
rm -Rf wubwikit.vfs/lib/tdbc
mv wubwikit.vfs wub.vfs
sdx wrap wub.kit -writable
mv wub.kit builds/wub-`date +%Y%m%d`.kit
tclsh8.6 mkzip.tcl wub.zipkit -zipkit -directory wub.vfs
mv wub.zipkit builds/wub-`date +%Y%m%d`.zipkit

rm -Rf wub.vfs
