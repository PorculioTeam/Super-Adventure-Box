//
//  GameLevelScene.h
//  SuperKoalio
//

//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameLevelScene : SKScene

// HC: Texto del juego
@property (nonatomic, assign) NSString *gameText;
// HC: Nodo de etiqueta donde aparece el texto del juego
@property (nonatomic, strong) SKLabelNode *endGameLabel;
// HC: Booleano que indica si el jugador ha pasado el nivel
@property (nonatomic, assign) BOOL levelClear;
// HC: Booleano que indica si el juego ha comenzado
@property (nonatomic, assign) BOOL gameStart;
// HC: Nodo de etiqueta donde aparece el marcador de vidas
@property (nonatomic, strong) SKLabelNode *hudLives;
// HC: Nodo de etiqueta donde aparece el temporizador
@property (nonatomic, strong) SKLabelNode *hudTimer;
// HC: Booleano que indica si el juego ha empezado
@property (nonatomic, assign) BOOL startGamePlay;
// HC: Intervalo que indica en qué momento comienza el temporizador
@property (nonatomic, assign) NSTimeInterval startTime;
// HC: Intervalo que indica la última marca del temporizador
@property (nonatomic, assign) NSTimeInterval pauseTime;
//Nodo para mutear el sonido
@property(nonatomic,strong) SKSpriteNode *sonido;
// HC: Nodo de etiqueta donde aparece la puntuación
@property (nonatomic, strong) SKLabelNode *hudScore;
// HC: La cuenta atras del temporizador
@property (nonatomic, assign) int countDown;

@end
