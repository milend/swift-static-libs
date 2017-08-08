What is this?
-------------

This repository shows an example of how to set up mixed modules (i.e., Swift + Obj-C) which compile down to static libraries. Do note that *module* is used to denote a named collection of source code, **not** a Clang Module.

You **must be running** Xcode 9 beta 4 or later as Swift static libraries were not previously [supported](https://twitter.com/daniel_dunbar/status/889546788633321472).

Approach
--------

The approach presented fulfils the following requirements:

- Module header files are publicly exposed through imports such as `#import <Module/File.h>`.
- The same source code can be compiled through the command line or Xcode without any modifications or preprocessing steps.
- Static libraries are produced by both Xcode and through command line compilation.
- Obj-C code is not required to be compiled as modular (i.e., `-fmodules`).
- Module maps are not required.
- Swift and Obj-C can be freely mixed, within and across modules.

How do I use it?
----------------

- Run `compile.sh` to manually compile the source code. You will find relevant output files in `build/foo/output` and `build/bar/output`.
- Open `Swift-Static-Libs.xcworkspace`, select the `Bar` target from the toolbar and build the library.

How does it work?
------------------

The setup *almost* works out of the box except for one aspect: you cannot import another module's Obj-C Generated Interface Header through an import like `<Module/Module-Swift.h>`. The reason is that `Module-Swift.h` is placed inside a module's own `DerivedSources`.

To workaround the above issue, there is a custom Run Script build phase which exposes the generated header so that it can be imported using the desired syntax. The code snippet below shows the relevant parts:

```shell
FOO_HEADER_DIR="${BUILT_PRODUCTS_DIR}/Foo"
FOO_HEADER_DIR_FOO_SWIFT_H="${FOO_HEADER_DIR}/Foo-Swift.h"
FOO_SWIFT_HEADER="${DERIVED_FILES_DIR}/Foo-Swift.h"

if [ ! -f "$FOO_HEADER_DIR" ]; then
  mkdir -p "$FOO_HEADER_DIR"
fi

if [ ! -f "${FOO_HEADER_DIR_FOO_SWIFT_H}" ]; then
  ln -s "${FOO_SWIFT_HEADER}" "${FOO_HEADER_DIR_FOO_SWIFT_H}"
fi
```

Alternative
-----------

There's an alternative way to achieve the ability to refer to another module's Obj-C Generated Interface Header through an import like `<Module/Module-Swift.h>`.

- Map `<Module/Module-Swift.h>` to `Module-Swift.h`. This can be achieved using a header map.
- Add a module's `DerivedSources` directory to the include path.

The last part can be achieved in one of the following ways:

- Guess where all artifacts will be stored. This is usually `~/Library/Developer/Xcode/DerivedData/Name-HASH`. The way the hashes are constructed has been [reverse engineered]((https://pewpewthespells.com/blog/xcode_deriveddata_hashes.html) but this approach is fragile due to relying on private behaviour.
- You can just set `SYMROOT` (Build Products Path) in the project settings so that all artifacts are placed in a predictable location.

If you want to find out more about build locations, check out [Xcode Build Locations](https://pewpewthespells.com/blog/xcode_build_locations.html).

Acknowledgements
----------------

- [Daniel Dunbar](https://github.com/ddunbar) for advice about the best way to make the cross-module import syntax work for the generated Obj-C header.
- [Robbert van Ginkel](https://github.com/robbertvanginkel) for detailed conversations about the Swift compilation process and Xcode project generation.