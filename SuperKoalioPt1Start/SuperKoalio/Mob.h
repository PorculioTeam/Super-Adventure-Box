//
//  Mob.h
//  SuperKoalio
//
//  Created by alumno on 25/2/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Mob : SKSpriteNode
// Velocidad del jugador
@property (nonatomic, assign) CGPoint velocity;
// Posición deseada en el CGPoint
@property (nonatomic, assign) CGPoint desiredPosition;

-(SKAction*)ronda;
- (CGRect)collisionBoundingBox;
@end
