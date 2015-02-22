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
@synthesize sonido;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {        
        // Color de fondo (el cielo)
        self.backgroundColor = [SKColor colorWithRed:.4 green:.4 blue:.95 alpha:1.0];
        self.sonido = [SKSpriteNode spriteNodeWithImageNamed:@"play.png"];
        self.sonido.name = @"So";
        sonido.position = CGPointMake(self.size.width * 0.5,self.size.height * 0.5);
        [self addChild:sonido];
        
        
        
    }
    [[SKTAudio sharedInstance] playBackgroundMusic:@"level1.mp3"];
    self.userInteractionEnabled = YES;
    return self;
}
 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
        {
            UITouch *touch = [touches anyObject];
            CGPoint location = [touch locationInNode:self];
            SKNode *node = [self nodeAtPoint:location];
            //if fire button touched, bring the rain
            if ([node.name isEqualToString:@"So"]) {
            SKScene *spaceshipScene  = [[GameLevelScene alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
            [self.view presentScene:spaceshipScene transition:doors];
    }
}
}
@end