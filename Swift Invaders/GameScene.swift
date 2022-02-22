//
//  GameScene.swift
//  Swift Invaders
//
//  Created by Alexus =P on 22.02.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Variables
    var enemies : [SKNode] = []
    //var enemyShots : [SKNode] = []
    //var playerShots : [SKNode] = []
    var shipSize: CGSize = CGSize(width: 0, height: 0)
    var isShielded = true
    var isDamaged = false
    
    
    //Textures
    var playerTexture : SKTexture!
    var enemyTexture : SKTexture!
    var playerShotTexture : SKTexture!
    var enemyShotTexture : SKTexture!
    var shieldTexture : SKTexture!
    var leftTexture : SKTexture!
    var rightTexture : SKTexture!
    var fireTexture : SKTexture!
    
    //Label Nodes
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    
    //Sprite Nodes
    var playerSprite = SKSpriteNode()
    var enemySprite = SKSpriteNode()
    var playerShotSprite = SKSpriteNode()
    var enemyShotSprite = SKSpriteNode()
    var shieldSprite = SKSpriteNode()
    var leftSprite = SKSpriteNode()
    var rightSprite = SKSpriteNode()
    var fireSprite = SKSpriteNode()
    
    //Sprite Objects
    var player = SKNode()
    var enemy = SKNode()
    var playerShot = SKNode()
    var enemyShot = SKNode()
    var controls = SKNode()
    
    //Bit Masks
    let playerMask : UInt32 = 0x1 << 1
    let enemyMask : UInt32 = 0x1 << 2
    let playerShotMask : UInt32 = 0x1 << 3
    let enemyShotMask : UInt32 = 0x1 << 4

    //Timers
    var enemyShotTimer = Timer()
    var tempTimer = Timer()
    
    override func didMove(to view: SKView) {
        playerTexture = SKTexture(imageNamed: "player")
        enemyTexture = SKTexture(imageNamed: "enemyShip")
        playerShotTexture = SKTexture(imageNamed: "laserGreen")
        enemyShotTexture = SKTexture(imageNamed: "laserRed")
        shieldTexture = SKTexture(imageNamed: "shield")
        leftTexture = SKTexture(imageNamed: "left")
        rightTexture = SKTexture(imageNamed: "right")
        fireTexture = SKTexture(imageNamed: "fire")
        
        self.physicsWorld.contactDelegate = self
        
        let bg = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
        bg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bg.scale(to: self.frame.size)
        bg.zPosition = -1
        self.addChild(bg)
        createObjects()
      
    }
    
    func createObjects() {
        
        createEnemies()
        createPlayer()
        createControls()
        startTimers()
        
        self.addChild(player)
        self.addChild(enemy)
        self.addChild(enemyShot)
        self.addChild(controls)
    }
    
    func createPlayer() {
        playerSprite = SKSpriteNode(texture: playerTexture)
        playerSprite.position = CGPoint(x: self.frame.midX, y: playerSprite.size.height * 2 + 140)
        playerSprite.zPosition = 1
        playerSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: playerSprite.size.width - 10, height: playerSprite.size.height - 40))
        playerSprite.physicsBody?.categoryBitMask = playerMask
        playerSprite.physicsBody?.isDynamic = false
        playerSprite.size = CGSize(width: shipSize.width * 1.5, height: shipSize.height * 1.5)
        
        shieldSprite = SKSpriteNode(texture: shieldTexture)
        shieldSprite.position = playerSprite.position
        shieldSprite.zPosition = 1
        shieldSprite.size = CGSize(width: shipSize.width * 2.5, height: shipSize.height * 2.5)
        
        player.addChild(playerSprite)
        player.addChild(shieldSprite)
        //player.setScale(0.7)
    }
    
    func createEnemies() {
        for i in 0...19 {
            let enemyShip = SKSpriteNode(texture: enemyTexture)
            enemyShip.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemyShip.size.width - 10, height: enemyShip.size.height - 10))
            enemyShip.physicsBody?.categoryBitMask = enemyMask
            enemyShip.physicsBody?.affectedByGravity = false
            shipSize = CGSize(width: self.frame.width / 15, height: self.frame.width / 15)
            enemyShip.size = shipSize
            
            let gap = 3.5 * enemyShip.size.width
            switch i {
            case 0...4:
                enemyShip.position = CGPoint(x: CGFloat(i) * enemyShip.size.width * 2 + gap,
                                             y: (scene?.size.height)! - (enemyTexture.size().height + CGFloat(120)))
            case 5...9:
                enemyShip.position = CGPoint(x: (CGFloat(i) - 5) * enemyShip.size.width * 2 + gap,
                                             y: (scene?.size.height)! - (enemyTexture.size().height + CGFloat(160)))
            case 10...14:
                enemyShip.position = CGPoint(x: (CGFloat(i) - 10) * enemyShip.size.width * 2 + gap,
                                             y: (scene?.size.height)! - (enemyTexture.size().height + CGFloat(200)))
            case 15...19:
                enemyShip.position = CGPoint(x: (CGFloat(i) - 15) * enemyShip.size.width * 2 + gap,
                                             y: (scene?.size.height)! - (enemyTexture.size().height + CGFloat(240)))
            default:
                print("Bazinga!")
            }
            enemies.append(enemyShip)
            enemy.addChild(enemies[i])
        }
    }
    
    @objc func addEnemyShot() {
        enemyShotSprite = SKSpriteNode(texture: enemyShotTexture)
        enemyShotSprite.physicsBody = SKPhysicsBody(rectangleOf: enemyShotSprite.size)
        enemyShotSprite.physicsBody?.categoryBitMask = enemyShotMask
        enemyShotSprite.physicsBody?.allowsRotation = false
        enemyShotSprite.zPosition = 1
        enemyShotSprite.physicsBody?.restitution = 0
        enemyShotSprite.position = enemies[Int.random(in: 15...19)].position
        enemyShot.addChild(enemyShotSprite)
        
    }
    
    func startTimers() {
        enemyShotTimer.invalidate()
        
        //enemyShotTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Float.random(in: 1...5)), target: self, selector: #selector(GameScene.addEnemyShot), userInfo: nil, repeats: true)
        
        enemyShotTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Float.random(in: 1...5)), repeats: true, block: {_ in
            self.addEnemyShot()
        })
    }
    
    func createControls() {
        leftSprite = SKSpriteNode(texture: leftTexture)
        leftSprite.position = CGPoint (x: self.frame.width / 5, y: leftSprite.size.height + 140)
        //leftSprite.position = playerSprite.position
        leftSprite.zPosition = 2
        
        rightSprite = SKSpriteNode(texture: rightTexture)
        rightSprite.position = CGPoint (x: self.frame.width / 5 + rightSprite.size.height + 40, y: rightSprite.size.height + 140)
        rightSprite.zPosition = 2
        
        fireSprite = SKSpriteNode(texture: fireTexture)
        fireSprite.position = CGPoint (x: self.frame.width - self.frame.width / 5, y: fireSprite.size.height + 140)
        fireSprite.zPosition = 2
        
        controls.addChild(leftSprite)
        controls.addChild(rightSprite)
        controls.addChild(fireSprite)
        controls.alpha = 0.7
    }
    
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if enemyShotSprite.intersects(playerSprite) {
            enemyShotSprite.texture = SKTexture(imageNamed: "laserRedShot")
            enemyShotSprite.size = SKTexture(imageNamed: "laserRedShot").size()
            enemyShotSprite.setScale(3)
            tempTimer.invalidate()
            tempTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [self]_ in
                enemyShotSprite.removeFromParent()
                if isShielded {
                    shieldSprite.removeFromParent()
                    isShielded = false
                } else if isDamaged == false {
                    isDamaged = true
                    playerSprite.texture = SKTexture(imageNamed: "playerDamaged")
                } else {
                    playerSprite.removeFromParent()
                }
            })
            
        }
        
        if enemyShotSprite.position.y < -5 {
            enemyShotSprite.removeFromParent()
        }
    }
}
