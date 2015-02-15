//
//  Player.h
//  Super Adventure Box
//
//  Created by alumno on 15/02/15.
//  Copyright (c) 2015 Alvaro. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Player : SKSpriteNode

// Velocidad del jugador
@property (nonatomic, assign) CGPoint velocity;
// Posición deseada en el CGPoint
@property (nonatomic, assign) CGPoint desiredPosition;
// En el suelo, boolean utilizado para evitar saltos dobles
@property (nonatomic, assign) BOOL onGround;
// Marchar hacia delante, funciona cuando se pulsa el lado izquierdo de la pantalla
@property (nonatomic, assign) BOOL forwardMarch;
// Puede que salte, funciona cuando se pulsa el lado derecho de la pantalla
@property (nonatomic, assign) BOOL mightAsWellJump;
// El número de vidas restantes para el jugador
@property (nonatomic, assign) int livesLeft;
- (void)update:(NSTimeInterval)delta;
- (CGRect)collisionBoundingBox;

@end

