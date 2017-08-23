#!/bin/sh

rm -rf build

# Setup build dirs for Foo

mkdir -p build/foo/headers/Foo
mkdir -p build/foo/objects
mkdir -p build/foo/modules
mkdir -p build/foo/output

XCODE_APP="/Applications/Xcode-beta.app"
SDK="${XCODE_APP}/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk"
TOOLCHAIN="${XCODE_APP}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain"
SWIFT_BIN="${TOOLCHAIN}/usr/bin/swift"
CLANG_BIN="${TOOLCHAIN}/usr/bin/clang"
LIBTOOL_BIN="${TOOLCHAIN}/usr/bin/libtool"
SWIFT_MACOSX_LIB_DIR="${TOOLCHAIN}/usr/lib/swift/macosx"
SWIFT_VERSION="3"

# Setup header symlink tree for Foo

ln -s ../../../../sources/Foo/Foo.h build/foo/headers/Foo

# Compile Foo.swift

$SWIFT_BIN -frontend \
  -c \
  -enable-objc-interop \
  -module-name Foo \
  -swift-version $SWIFT_VERSION \
  -import-objc-header sources/Foo/Foo-Bridging-Header.h \
  -emit-module-path build/foo/modules/Foo.swift.swiftmodule \
  -o build/foo/objects/Foo.swift.o \
  -Xcc -Ibuild/foo/headers \
  -sdk $SDK \
  -primary-file sources/Foo/Foo.swift \
  sources/Foo/Baz.swift

# Compile Baz.swift

$SWIFT_BIN -frontend \
  -c \
  -enable-objc-interop \
  -module-name Foo \
  -swift-version $SWIFT_VERSION \
  -import-objc-header sources/Foo/Foo-Bridging-Header.h \
  -emit-module-path build/foo/modules/Baz.swift.swiftmodule \
  -o build/foo/objects/Baz.swift.o \
  -Xcc -Ibuild/foo/headers \
  -sdk $SDK \
  -primary-file sources/Foo/Baz.swift \
  sources/Foo/Foo.swift

# Generate docs and Foo.swiftmodule

$SWIFT_BIN -frontend \
  -emit-module \
  -module-name Foo \
  -swift-version $SWIFT_VERSION \
  -o build/foo/output/Foo.swiftmodule \
  -emit-objc-header-path build/foo/headers/Foo/Foo-Swift.h \
  -emit-module-doc-path build/foo/output/Foo.swiftdoc \
  -sdk $SDK \
  -Xcc -Ibuild/foo/headers \
  -Xcc -Ibuild/foo/headers/Foo \
  -import-objc-header sources/Foo/Foo-Bridging-Header.h \
  build/foo/modules/Baz.swift.swiftmodule \
  build/foo/modules/Foo.swift.swiftmodule

# Compile Foo.m

$CLANG_BIN \
  -x objective-c \
  -fobjc-arc \
  -Ibuild/foo/headers \
  -Ibuild/foo/headers/Foo \
  -I. \
  -isysroot $SDK \
  -c sources/Foo/Foo.m \
  -o build/foo/objects/Foo.m.o

# Link libFoo.a

$LIBTOOL_BIN \
  -static \
  -syslibroot $SDK \
  -L$SWIFT_MACOSX_LIB_DIR \
  -o build/foo/output/libFoo.a \
  build/foo/objects/Baz.swift.o \
  build/foo/objects/Foo.swift.o \
  build/foo/objects/Foo.m.o

# Setup build dirs for Bar

mkdir -p build/bar/headers/Bar
mkdir -p build/bar/objects
mkdir -p build/bar/modules
mkdir -p build/bar/output

# Setup header symlink tree for Bar

ln -s ../../../../sources/Bar/Bar.h build/bar/headers/Bar

# Compile Bar.swift

$SWIFT_BIN -frontend \
  -c \
  -enable-objc-interop \
  -module-name Bar \
  -swift-version $SWIFT_VERSION \
  -import-objc-header sources/Bar/Bar-Bridging-Header.h \
  -emit-module-path build/bar/modules/Bar.swift.swiftmodule \
  -o build/bar/objects/Bar.swift.o \
  -Xcc -Ibuild/bar/headers \
  -Xcc -Ibuild/foo/headers \
  -Ibuild/foo/output \
  -sdk $SDK \
  -primary-file sources/Bar/Bar.swift

# Generate docs and Bar.swiftmodule

$SWIFT_BIN -frontend \
  -emit-module \
  -module-name Bar \
  -swift-version $SWIFT_VERSION \
  -o build/bar/output/Bar.swiftmodule \
  -emit-objc-header-path build/bar/headers/Bar/Bar-Swift.h \
  -emit-module-doc-path build/bar/output/Bar.swiftdoc \
  -Xcc -Ibuild/bar/headers \
  -Xcc -Ibuild/foo/headers \
  -sdk $SDK \
  build/bar/modules/Bar.swift.swiftmodule

# Compile Bar.m

$CLANG_BIN \
  -x objective-c \
  -fobjc-arc \
  -Ibuild/foo/headers \
  -Ibuild/bar/headers \
  -Ibuild/bar/headers/Bar \
  -isysroot $SDK \
  -I. \
  -c sources/Bar/Bar.m \
  -Wno-nonportable-include-path \
  -o build/bar/objects/Bar.m.o

# Link libBar.a

$LIBTOOL_BIN \
  -static \
  -syslibroot $SDK \
  -L$SWIFT_MACOSX_LIB_DIR \
  -o build/bar/output/libBar.a \
  build/bar/objects/Bar.swift.o \
  build/bar/objects/Bar.m.o
