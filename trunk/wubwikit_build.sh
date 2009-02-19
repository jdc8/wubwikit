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
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d autoscroll -P tklib/modules/autoscroll
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d inifile -P tcllib/modules/inifile
cvs -z3 -d:pserver:anonymous@tcllib.cvs.sourceforge.net:/cvsroot/tcllib co -d md5 -P tcllib/modules/md5

# Optional: remove test and documentations file to keep size of .kit low
find . -name "CVS" | xargs rm -Rf
find . -name "*.test" | xargs rm
find . -name "*.testsuite" | xargs rm
find . -name "*.testsupport" | xargs rm
find . -name "*.man" | xargs rm
find . -name "*.bench" | xargs rm
find . -name "*.html" | xargs rm
find . -name "ChangeLog" | xargs rm
find . -name "*.[ch]" | xargs rm

# Get gbutton
mkdir gbutton-temp
cd gbutton-temp
#get http://mini.net/sdarchive/gbutton.kit
cp ../../../gbutton.kit .
sdx unwrap gbutton.kit
mv gbutton.vfs/lib/gbutton ..
cd ..
rm -Rf gbutton-temp
cd ../..

# Copy/move some files
cp gbutton-pkgIndex.tcl wubwikit.vfs/lib/gbutton/pkgIndex.tcl
cp local.tcl wubwikit.vfs/lib/wikitcl/wubwikit/local.tcl
cp vars.tcl wubwikit.vfs/lib/wikitcl/wubwikit/vars.tcl
cp wikit.ini wubwikit.vfs/lib/wikitcl/wubwikit/wikit.ini
cp wubwikit_main.tcl wubwikit.vfs/main.tcl
cp welcome.html wubwikit.vfs/lib/wikitcl/wubwikit/docroot/html
cp wikitoc.jpg wubwikit.vfs/lib/wikitcl/wubwikit/docroot/images

# Create starkit
sdx wrap wubwikit.kit -writable
mkdir -p builds
mv wubwikit.kit builds/wubwikit`date +%Y%m%d`.kit
