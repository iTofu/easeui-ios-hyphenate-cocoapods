//
//  SBEaseHelper.m
//  Pods
//
//  Created by LΞO on 2019/6/23.
//

#import "SBEaseHelper.h"

@implementation SBEaseHelper

+ (UIImage *)imageWithName:(NSString *)imageName {
  NSString *bundlePath = [[NSBundle bundleForClass:[EaseMessageViewController class]] pathForResource:@"EaseUIResource" ofType:@"bundle"];
  NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
  UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
  return image;
}

@end
