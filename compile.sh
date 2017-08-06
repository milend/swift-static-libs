#!/bin/sh

rm -rf build

# Setup build dirs for Foo

mkdir -p build/foo/headers/Foo
mkdir -p build/foo/objects
mkdir -p build/foo/modules
mkdir -p build/foo/output

# Setup header symlink tree for Foo

ln -s ../../../../sources/foo/Foo.h build/foo/headers/Foo

# Compile Foo.swift

swift -frontend \
  -c \
  -enable-objc-interop \
  -module-name Foo \
  -swift-version 3 \
  -import-objc-header sources/foo/Foo-Bridging-Header.h \
  -emit-module-path build/foo/modules/Foo.swift.swiftmodule \
  -o build/foo/objects/Foo.swift.o \
  -Xcc -Ibuild/foo/headers \
  -sdk /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk \
  -primary-file sources/foo/Foo.swift \
  sources/foo/Baz.swift

# Compile Baz.swift

swift -frontend \
  -c \
  -enable-objc-interop \
  -module-name Foo \
  -swift-version 3 \
  -import-objc-header sources/foo/Foo-Bridging-Header.h \
  -emit-module-path build/foo/modules/Baz.swift.swiftmodule \
  -o build/foo/objects/Baz.swift.o \
  -Xcc -Ibuild/foo/headers \
  -sdk /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk \
  -primary-file sources/foo/Baz.swift \
  sources/foo/Foo.swift

# Generate docs and Foo.swiftmodule

swift -frontend \
  -emit-module \
  -module-name Foo \
  -o build/foo/output/Foo.swiftmodule \
  -emit-objc-header-path build/foo/headers/Foo/Foo-Swift.h \
  -emit-module-doc-path build/foo/output/Foo.swiftdoc \
  -sdk /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk \
  build/foo/modules/Baz.swift.swiftmodule \
  build/foo/modules/Foo.swift.swiftmodule

# Compile Foo.m

clang \
  -x objective-c \
  -fobjc-arc \
  -Ibuild/foo/headers \
  -Ibuild/foo/headers/Foo \
  -c sources/foo/Foo.m \
  -o build/foo/objects/Foo.m.o

# Link libFoo.a

libtool \
  -static \
  -syslibroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk \
  -L/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
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

ln -s ../../../../sources/bar/Bar.h build/bar/headers/Bar

# Compile Bar.swift

swift -frontend \
  -c \
  -enable-objc-interop \
  -module-name Bar \
  -swift-version 3 \
  -import-objc-header sources/bar/Bar-Bridging-Header.h \
  -emit-module-path build/bar/modules/Bar.swift.swiftmodule \
  -o build/bar/objects/Bar.swift.o \
  -Xcc -Ibuild/bar/headers \
  -Xcc -Ibuild/foo/headers \
  -Ibuild/foo/output \
  -sdk /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk \
  -primary-file sources/bar/Bar.swift

# Generate docs and Bar.swiftmodule

swift -frontend \
  -emit-module \
  -module-name Bar \
  -o build/bar/output/Bar.swiftmodule \
  -emit-objc-header-path build/bar/headers/Bar/Bar-Swift.h \
  -emit-module-doc-path build/bar/output/Bar.swiftdoc \
  -sdk /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk \
  build/bar/modules/Bar.swift.swiftmodule

# Compile Bar.m

clang \
  -x objective-c \
  -fobjc-arc \
  -Ibuild/foo/headers \
  -Ibuild/bar/headers \
  -Ibuild/bar/headers/Bar \
  -c sources/bar/Bar.m \
  -Wno-nonportable-include-path \
  -o build/bar/objects/Bar.m.o

# Link libBar.a

libtool \
  -static \
  -syslibroot /Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk \
  -L/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx \
  -o build/bar/output/libBar.a \
  build/bar/objects/Bar.swift.o \
  build/bar/objects/Bar.m.o
