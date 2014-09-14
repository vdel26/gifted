//
//  NSColor+GFColors.m
//  Gifted
//
//  Created by Victor Delgado on 11/12/13.
//  Copyright (c) 2013 Victor Delgado. All rights reserved.
//

#import "NSColor+GFColors.h"

@implementation NSColor (GFColors)

+ (NSColor *)GFGreenColor {
    return [NSColor colorWithCalibratedRed:0.0 green:0.90 blue:0.40 alpha:1.0];
}

+ (NSColor *)GFBlueColor {
    return [NSColor colorWithCalibratedRed:0.15 green:0.58 blue:1.0 alpha:1.0];
}

+ (NSColor *)GFBgGreyColor {
    return [NSColor colorWithCalibratedRed:0.93 green:0.94 blue:0.96 alpha:1.0];
}

+ (NSColor *)GFBorderGreyColor {
    return [NSColor colorWithCalibratedRed:0.467 green:0.541 blue:0.624 alpha:1.0];
}

+ (NSColor *)GFTextGreyColor {
    return [NSColor colorWithDeviceRed:0.67 green:0.67 blue:0.67 alpha:1.0];
}

@end
