//  Copyright (c) 2017 Milen Dzhumerov. All rights reserved.

import Foundation
import Foo
import CoreMedia

@objc class BarObject: NSObject {
  let time: CMTime
	@objc init(time: CMTime) {
		self.time = time
	}
}

struct Bar {
	// Swift -> Swift (Foo)
	let baz: BazStruct
  // Swift -> Obj-C (Foo)
  let fooObj: FooObject
}
