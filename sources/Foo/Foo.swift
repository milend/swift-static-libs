//  Copyright (c) 2017 Milen Dzhumerov. All rights reserved.

import Foundation

// Swift-only Types

public struct FooStruct {
	let name: String
}

// Obj-C Types

public class FooLogger: NSObject {
  public func log() {
		// Swift -> Obj-C
    let foo = FooObject()
    print("foo: \(foo.makeBaz())")
  }
}

@objc public class FooSubclass: FooObject {
  
}
