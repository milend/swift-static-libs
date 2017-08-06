//  Copyright (c) 2017 Milen Dzhumerov. All rights reserved.

#import "Bar.h"

// Needed due to import of CoreMedia in Swift through @import
#import <CoreMedia/CoreMedia.h>
#import "Bar-Swift.h"

#import <Foo/Foo.h>
#import <Foo/Foo-Swift.h>

@implementation Bar

-(id)makeBaz {
  // Obj-C -> Swift (Foo)
	FooLogger *logger = [FooLogger new];
	[logger log];
	
	return [BazObject new];
}

- (void)useCoreMediaTime {
	// Obj-C -> Swift
	BarObject *bar = [[BarObject alloc] initWithTime:(CMTime){}];
	NSLog(@"%@", bar);
}

@end
