//  Copyright (c) 2017 Milen Dzhumerov. All rights reserved.

#import "Foo.h"

#import "Foo-Swift.h"

@implementation FooObject

- (id)makeBaz {
	// Obj-C -> Swift
  return [BazObject new];
}

@end
