//
//  ViewController.m
//  SuperKoalio
//
//  Created by Jake Gundersen on 12/27/13.
//  Copyright (c) 2013 Razeware, LLC. All rights reserved.
//

#import "ViewController.h"
#import "GameLevelScene.h"
#import "PlayScene.h"

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  // Configure la vista
  //Desactivamos los fps y el contador de nodos en la pantalla.
  SKView * skView = (SKView *)self.view;
  skView.showsFPS = NO;
  skView.showsNodeCount = NO;
  
  // Crea y configura la escena.
  SKScene * scene = [PlayScene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  
  // Presenta la scene.
  [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
  return NO;
}

//El juego soporta solamente Landscape
- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

@end
