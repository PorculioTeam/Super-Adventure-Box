//
//  PlayScene.m
//  SuperKoalio
//
//  Created by alumno on 22/02/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

#import "PlayScene.h"
#import "SKTAudio.h"
#import "GameLevelScene.h"

@implementation PlayScene
@synthesize play;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {        
        // Color de fondo
        //self.backgroundColor = [SKColor colorWithRed:.4 green:.4 blue:.95 alpha:1.0];
        
        //Añadimos el fondo con la imagen, lo posiciona en la escena
        //y luego lo asigna dentro del mapa como hijo.
        self.fondo = [SKSpriteNode spriteNodeWithImageNamed:@"fondo.png"];
        self.fondo.position = CGPointMake(self.size.width *0.58,self.size.height*0.58);
        [self addChild:self.fondo];
        
        // Asigna el boton play con la imagen, lo posiciona en la escena
        // y luego lo asigna dentro del mapa como hijo.
        self.play = [SKSpriteNode spriteNodeWithImageNamed:@"play.png"];
        self.play.name = @"Jugar";
        play.position = CGPointMake(self.size.width * 0.5,self.size.height * 0.5);
        [self addChild:play];
        
        
        
    }
    self.userInteractionEnabled = YES;
    return self;
}
 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
        {
            UITouch *touch = [touches anyObject];
            CGPoint location = [touch locationInNode:self];
            SKNode *node = [self nodeAtPoint:location];
            
            //Si el nodo que pulsas es jugar abre la escena GameLevel
            if ([node.name isEqualToString:@"Jugar"]) {
            SKScene *gamescene  = [[GameLevelScene alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:gamescene transition:doors];
    }
}
}
@end