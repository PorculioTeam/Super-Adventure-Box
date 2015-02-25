//
//  Mob.m
//  SuperKoalio
//
//  Created by alumno on 25/2/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

#import "Mob.h"
#import "SKTUtils.h"

@implementation Mob


//Mueve el mob indefinidamente
- (SKAction*)ronda{
    SKAction *right   = [SKAction moveByX:100 y:0 duration:1];
    SKAction *left    = [SKAction moveByX:-100 y:0 duration:1];
    SKAction *action1 = [SKAction repeatActionForever:[SKAction sequence:@[right, left]]];
    return action1;
}
//Crea un box para controlar las colisiones
- (CGRect)collisionBoundingBox {
    CGRect boundingBox = CGRectInset(self.frame, 2, 0);
    CGPoint diff = CGPointSubtract(self.desiredPosition, self.position);
    return CGRectOffset(boundingBox, diff.x, diff.y);
}
@end
