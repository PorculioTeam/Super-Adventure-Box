//
//  GameLevelScene.m
//  SuperKoalio
//
//  Created by Jake Gundersen on 12/27/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "GameLevelScene.h"
#import "JSTileMap.h"
#import "Player.h"
#import "SKTUtils.h"
#import "SKTAudio.h"
#import "PlayScene.h"

@interface GameLevelScene()
@property (nonatomic, strong) JSTileMap *map;
@property (nonatomic, strong) Player *player;
@property (nonatomic, assign) NSTimeInterval previousUpdateTime;
@property (nonatomic, strong) TMXLayer *walls;
@property (nonatomic, strong) TMXLayer *hazards;
@property (nonatomic, assign) BOOL gameOver;


@end

@implementation GameLevelScene
// Sintetizo los SKLabelNodes
@synthesize endGameLabel;
@synthesize hudLives;
@synthesize hudTimer;
@synthesize sonido;
@synthesize hudScore;

// Inicializa el nivel
-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    // Al inicializar, se indica que el nivel no ha sido completado.
    self.levelClear = NO;
    
    // Configuramos el nivel y el escenario aquí.
    // Color de fondo (el cielo)
    self.backgroundColor = [SKColor colorWithRed:.4 green:.4 blue:.95 alpha:1.0];
    
    // Asigna el nivel y lo añade dentro del escenario como hijo
    self.map = [JSTileMap mapNamed:@"level1.tmx"];
    [self addChild:self.map];
    
    // Asigna las paredes dentro del mapa
    self.walls = [self.map layerNamed:@"walls"];
    // Asigna los peligros dentro del mapa
    self.hazards = [self.map layerNamed:@"hazards"];
    
    // Asigna el jugador con la imagen de píe (sin hacer nada), lo posiciona
    // y luego lo asigna dentro del mapa como hijo
    if(self.player.livesLeft == 0)
    {
      self.player = [[Player alloc] initWithImageNamed:@"player"];
      self.player.livesLeft = 3;
      self.player.position = CGPointMake(100, 50);
      self.player.zPosition = 15;
      [self.map addChild:self.player];
    } else {
      self.player.position = CGPointMake(100, 50);
      self.player.zPosition = 15;
    }
    
    //Carga la puntuación desde el NSUserDefaults.
    //Si no existen todavía datos guardados en el NSUserDefaults(porque no hemos jugado nunca) inicializamos la puntuacion en 0.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.player.score = [defaults integerForKey:@"PuntuacionAcumulada"];
    
    // Pone el indicador de vidas en pantalla
    self.hudLives = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    hudLives.text = [NSString stringWithFormat:@"Vidas: %d", self.player.livesLeft];
    hudLives.fontSize = 10;
    hudLives.position = CGPointMake(self.size.width * 0.0, 0.0);
    hudLives.horizontalAlignmentMode = 1;
    [self addChild:hudLives];
    
    // Pone el temporizador en pantalla
    self.hudTimer = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    hudTimer.text = [NSString stringWithFormat:@"Tiempo: 999"];
    hudTimer.fontSize = 10;
    hudTimer.position = CGPointMake(self.size.width * 0.0, 10.0);
    hudTimer.horizontalAlignmentMode = 1;
    hudTimer.name = @"Timer";
    [self addChild:hudTimer];
    
    // Pone la puntuación en pantalla
    self.hudScore = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
    hudScore.text = [NSString stringWithFormat:@"Ptos: %ld", self.player.score];
    hudScore.fontSize = 10;
    hudScore.position = CGPointMake(self.size.width * 0.0, 20.0);
    hudScore.horizontalAlignmentMode = 1;
    hudScore.name = @"Score";
    self.player.score = 0;
    [self addChild:hudScore];
    
    //Pone el icono de sonido
    self.sonido = [SKSpriteNode spriteNodeWithImageNamed:@"mute.png"];
    sonido.position = CGPointMake(self.size.width * 0.97,self.size.height * 0.93);
    [self addChild:sonido];
    
    // Una vez añadido todo, empieza la partida
    self.startGamePlay = YES;
  }
  // Añade música al nivel
  [[SKTAudio sharedInstance] playBackgroundMusic:@"level1.mp3"];
  self.userInteractionEnabled = YES;
  return self;
}

- (void)update:(NSTimeInterval)currentTime
{
  // HC: Si el juego está detenido, el tiempo es pausado y no actualiza nada más.
  // en el marcador
  if (self.gameOver) {
    self.pauseTime = currentTime - self.startTime;
    self.startTime = currentTime;
    return;
  }
  NSTimeInterval delta = currentTime - self.previousUpdateTime;
  
  if (delta > 0.02) {
    delta = 0.02;
  }
  
  self.previousUpdateTime = currentTime;
  
  [self.player update:delta];
  
  [self checkForAndResolveCollisionsForPlayer:self.player forLayer:self.walls];
  
  [self handleHazardCollisions:self.player];
  
  [self checkForWin];
  
  [self setViewpointCenter:self.player.position];
  
  // HC: Refresco del Temporizador.
  if (self.startGamePlay) {
    self.startTime = currentTime;
    if (self.pauseTime == 0) {
      self.pauseTime = currentTime - self.startTime;
    }
    self.startGamePlay = NO;
  }
  // HC: El contador, el cual cuenta hacia atrás
  self.countDown = 100.0 - (int)(currentTime-self.startTime);
  if (self.countDown <= 0) {
    [self gameOver:0];
  }
  hudTimer.text = [NSString stringWithFormat:@"Tiempo: %i", (int)(self.countDown)];
}

-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords {
  float levelHeightInPixels = self.map.mapSize.height * self.map.tileSize.height;
  CGPoint origin = CGPointMake(tileCoords.x *self.map.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.map.tileSize.height));
  return CGRectMake(origin.x, origin.y, self.map.tileSize.width, self.map.tileSize.height);
}

- (NSInteger)tileGIDAtTileCoord:(CGPoint)coord forLayer:(TMXLayer *)layer {
  TMXLayerInfo *layerInfo = layer.layerInfo;
  return [layerInfo tileGidAtCoord:coord];
}

- (void)checkForAndResolveCollisionsForPlayer:(Player *)player forLayer:(TMXLayer *)layer {
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
  player.onGround = NO;
  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [layer coordForPoint:player.desiredPosition];
    
    if (playerCoord.y >= self.map.mapSize.height -1) {
      [self gameOver:0];
      return;
    }
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow -1));
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:layer];
    
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      // NSLog(@"GID %ld, Tile Coord %@, Tile Rect %@, player rect %@", (long)gid, NSStringFromCGPoint(tileCoord), NSStringFromCGRect(tileRect), NSStringFromCGRect(playerRect));
      
      // La resolución de colisión va aquí
      if (CGRectIntersectsRect(playerRect, tileRect)) {
        CGRect intersection = CGRectIntersection(playerRect, tileRect);
        
        if (tileIndex == 7) {
          // El tile está debajo del Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height);
          player.velocity = CGPointMake(player.velocity.x, 0.0);
          player.onGround = YES;
        } else if (tileIndex == 1) {
          // El tile está sobre el Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.size.height);
        } else if (tileIndex == 3) {
          // El tile está a la izquierda del Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.size.width, player.desiredPosition.y);
        } else if (tileIndex == 5) {
          // El tile está al a derecha del Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.size.width, player.desiredPosition.y);
        } else {
          if (intersection.size.width > intersection.size.height) {
            // El tile está diagonal, pero resolviendo la colisión verticalmente
            player.velocity = CGPointMake(player.velocity.x, 0.0);
            float intersectionHeight;
            if (tileIndex > 4) {
              intersectionHeight = intersection.size.height;
              player.onGround = YES;
            } else {
              intersectionHeight = -intersection.size.height;
            }
            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height);
          } else {
            // El tile está diagonal, pero resolviendo la colisión horizontalmente
            float intersectionWidth;
            if (tileIndex == 6 || tileIndex == 0) {
              intersectionWidth = intersection.size.width;
            } else {
              intersectionWidth = -intersection.size.width;
            }
            player.desiredPosition = CGPointMake(player.desiredPosition.x + intersectionWidth, player.desiredPosition.y);
          }
        }
      }
    }
  }
  player.position = player.desiredPosition;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    if (touchLocation.x > self.size.width / 2.0) {
      self.player.mightAsWellJump = YES;
    } else {
      self.player.forwardMarch = YES;
      [self.player walkingPlayer];
    }
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    
    float halfWidth = self.size.width / 2.0;
    CGPoint touchLocation = [touch locationInNode:self];
    
    // obtener el anterior touch y convertirlo en un espacio de nodo
    CGPoint previousTouchLocation = [touch previousLocationInNode:self];
    
    if (touchLocation.x > halfWidth && previousTouchLocation.x <= halfWidth) {
      self.player.forwardMarch = NO;
      self.player.mightAsWellJump = YES;
    } else if (previousTouchLocation.x > halfWidth && touchLocation.x <= halfWidth) {
      self.player.forwardMarch = YES;
      self.player.mightAsWellJump = NO;
    }
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    if (touchLocation.x < self.size.width / 2.0) {
      self.player.forwardMarch = NO;
      [self.player walkStop];
    } else {
      self.player.mightAsWellJump = NO;
    }
  }
}

- (void)setViewpointCenter:(CGPoint)position {
  NSInteger x = MAX(position.x, self.size.width / 2);
  NSInteger y = MAX(position.y, self.size.height / 2);
  x = MIN(x, (self.map.mapSize.width * self.map.tileSize.width) - self.size.width / 2);
  y = MIN(y, (self.map.mapSize.height * self.map.tileSize.height) - self.size.height / 2);
  CGPoint actualPosition = CGPointMake(x, y);
  CGPoint centerOfView = CGPointMake(self.size.width/2, self.size.height/2);
  CGPoint viewPoint = CGPointSubtract(centerOfView, actualPosition);
  self.map.position = viewPoint;
}

- (void)handleHazardCollisions:(Player *)player
{
  if (self.gameOver) return;
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
  
  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [self.hazards coordForPoint:player.desiredPosition];
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow -1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:self.hazards];
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      if (CGRectIntersectsRect(playerRect, tileRect)) {
        [self gameOver:0];
      }
    }
  }
}

// Este método es llamado si el jugador recibe un golpe o termina el nivel.
// Won indica si la razón es que el jugador ha ganado (true) o no (false).
- (void)gameOver:(BOOL)won {
  self.gameOver = YES;
  // Reproduce el sonido
  [self runAction:[SKAction playSoundFileNamed:@"hurt.wav" waitForCompletion:NO]];
  
  // Se asigna el texto dependiendo del booleano Won.
  if (won) {
    // Si ha ganado
    int timeLeftReward = self.countDown * 10;
    self.gameText = [NSString stringWithFormat: @"¡Has ganado!, +%d ptos", timeLeftReward];
    // Si ha ganado, el tiempo que quedó restante se guarda en un int (para evitar que siga contando más hacia abajo
    self.player.score += timeLeftReward;
    //Aquí guardo el score en local en el NSUserDefaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.player.score forKey:@"PuntuacionAcumulada"];
    [defaults synchronize];
    
    self.levelClear = YES;
  } else {
    // HC: Si no ha ganado, se le resta una vida y dependiendo del caso muesrta que ha muerto o game over.
    self.player.livesLeft = self.player.livesLeft - 1;
    // HC: Hay que indicar si ha muerto por tiempo o no.
    if (self.countDown <= 0 && self.player.livesLeft > 0) {
      // HC: Tiempo, le quedan vidas.
      self.gameText = [NSString stringWithFormat:@"¡Se acabó el tiempo!, Vidas: %d", self.player.livesLeft];
    }
    else if (self.player.livesLeft > 0) {
      // HC: Peligro, le quedan vidas
      self.gameText = [NSString stringWithFormat:@"¡Has muerto!, Vidas: %d", self.player.livesLeft];
    } else if (self.countDown <= 0 && self.player.livesLeft == 0) {
      // HC: Tiempo, no le quedan vidas
      self.gameText = @"Time and Game Over";
    } else {
      // HC: Peligro, no le quedan vidas
      self.gameText = @"Game Over";
    }
  }
  //Añadimos un nodo que pintara en la pantalla el string almacenado en gameText, y se le asigna un tipo de fuente, un tamaño y su posición.
  self.endGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
  endGameLabel.text = self.gameText;
  endGameLabel.fontSize = 40;
  endGameLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 1.7);
  [self addChild:endGameLabel];
  
  //Añadimos un boton, le asignamos la posicion y la imagen,y un controlador de touch que cuando se pulsa llama a la funcion replay.
  UIButton *replay = [UIButton buttonWithType:UIButtonTypeCustom];
  replay.tag = 321;
  UIImage *replayImage = [UIImage imageNamed:@"repl.png"];
  [replay setImage:replayImage forState:UIControlStateNormal];
  [replay addTarget:self action:@selector(replay:) forControlEvents:UIControlEventTouchUpInside];
  replay.frame = CGRectMake(self.size.width / 2.0 - replayImage.size.width / 2.0, self.size.height / 2.0 - replayImage.size.height / 2.0, replayImage.size.width, replayImage.size.height);
  [self.view addSubview:replay];
}
- (void)replay:(id)sender
{
  // Tras apretar el botón replay, se quitan el botón y la etiqueta.
  [[self.view viewWithTag:321] removeFromSuperview];
  // Descomentar esta línea en caso de que se quiera que el texto se desvanezca en 1 segundo
  /* [endGameLabel runAction:[SKAction fadeAlphaTo:0.0 duration: 1.0] completion:^{
   [endGameLabel removeFromParent];
   }]; */
  // En esta linea el texto desaparece de golpe
  [endGameLabel removeFromParent];
  // Orden de condiciones:
  // 1. ¿Ha pasado el nivel?
  // 2. ¿Tiene vidas?
  if (self.levelClear) {
    // Si el jugador completa el nivel, se supone que cargará el siguiente nivel.
    // TODO: Añadir un nuevo nivel.
    self.gameOver = NO;
    int vidasAnteriores = self.player.livesLeft;
    // Asigna el siguiente mapa a la segunda fase
    [self.map removeFromParent];
    [self.player removeFromParent];
    self.player = nil;
    self.map = nil;
    self.map = [JSTileMap mapNamed:@"level2.tmx"];
    [self addChild:self.map];
    self.walls = [self.map layerNamed:@"walls"];
    self.hazards = [self.map layerNamed:@"hazards"];
    self.player = [[Player alloc] initWithImageNamed:@"player"];
    // HC: Posiciona al jugador al principio de la fase
    self.player.position = CGPointMake(100, 50);
    self.player.zPosition = 15;
    self.player.livesLeft = vidasAnteriores;
    [self.map addChild:self.player];
    // HC: Y también se actualiza la puntuación
    // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //self.player.score = [defaults integerForKey:@"PuntuacionAcumulada"];
    // HC: Al final hay que indicar que el nivel ya no está completo para evitar problemas
    self.levelClear = NO;
  } else if (self.player.livesLeft > 0) {
    // Si el jugador tiene vidas, será reposicionado un poco atras.
    self.gameOver = NO;
    self.player.position = CGPointMake(self.player.position.x - 80, self.player.position.y + 80);
    // Y se actualizará el contador de vidas.
    hudLives.text = [NSString stringWithFormat:@"Vidas: %d", self.player.livesLeft];
  } else {
    // Si no tiene vidas y no ha completado el nivel, volverá a cargar el nivel
    // desde el principio
    [self.view presentScene:[[GameLevelScene alloc] initWithSize:self.size]];
  }
}

// Si el player llega a la posicion 3130(el final) le pasa al funcion gameOver el parametro 1 (true)
- (void)checkForWin {
  if (self.player.position.x > 3130.0) {
    [self gameOver:1];
  }
}

@end
