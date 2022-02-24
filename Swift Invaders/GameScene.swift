//
//  GameScene.swift
//  Swift Invaders
//
//  Created by Alexus =P on 22.02.2022.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: Объявления
    
    //Переменные
    var enemies : [SKNode] = []
    var shipSize: CGSize = CGSize(width: 0, height: 0)
    var isShielded = true
    var isDamaged = false
    var canFire = true
    var enemyDir: CGFloat = 1
    
    
    //Textures
    var playerTexture : SKTexture!
    var playerCurrentTexture : SKTexture!
    var playerLeftTexture : SKTexture!
    var playerRightTexture : SKTexture!
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
    let playerMask : UInt32 = 0x1 << 0
    let enemyMask : UInt32 = 0x1 << 1
    let playerShotMask : UInt32 = 0x1 << 2
    let enemyShotMask : UInt32 = 0x1 << 3
    let nothingMask : UInt32 = 0x1 << 4

    //Timers
    var enemyShotTimer = Timer()
    var playerHitTimer = Timer()
    var enemyHitTimer = Timer()
    
    
    //MARK: didMove
    override func didMove(to view: SKView) {
        
        playerTexture = SKTexture(imageNamed: "player")
        playerLeftTexture = SKTexture(imageNamed: "playerLeft")
        playerRightTexture = SKTexture(imageNamed: "playerRight")
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
    
    //MARK: Creating things
    
    func createObjects() {
        
        createEnemies()
        createPlayer()
        createControls()
        startTimers()
        
        self.addChild(player)
        self.addChild(playerShot)
        self.addChild(enemy)
        self.addChild(enemyShot)
        self.addChild(controls)
    }
    
    func createPlayer() {
        playerSprite = SKSpriteNode(texture: playerTexture)
        playerSprite.position = CGPoint(x: self.frame.midX, y: playerSprite.size.height * 2 + 140)
        playerSprite.zPosition = 1
        playerSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: playerSprite.size.width - 20, height: playerSprite.size.height - 40))
        playerSprite.physicsBody?.categoryBitMask = playerMask
        playerSprite.physicsBody?.contactTestBitMask = enemyShotMask
        playerSprite.physicsBody?.isDynamic = false
        playerSprite.size = CGSize(width: shipSize.width * 1.5, height: shipSize.height * 1.5)
        
        shieldSprite = SKSpriteNode(texture: shieldTexture)
        shieldSprite.position = playerSprite.position
        shieldSprite.zPosition = 1
        shieldSprite.size = CGSize(width: shipSize.width * 2.5, height: shipSize.height * 2.5)
        
        playerCurrentTexture = playerTexture
        
        player.addChild(playerSprite)
        player.addChild(shieldSprite)
        //player.setScale(0.7)
    }
    
    func createEnemies() {
        for i in 0...19 {
            let enemyShip = SKSpriteNode(texture: enemyTexture)
            enemyShip.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemyShip.size.width - 40, height: enemyShip.size.height - 10))
            enemyShip.physicsBody?.categoryBitMask = enemyMask
            enemyShip.physicsBody?.contactTestBitMask = playerShotMask
            enemyShip.physicsBody?.collisionBitMask = playerShotMask
            enemyShip.physicsBody?.affectedByGravity = false
            shipSize = CGSize(width: self.frame.width / 15, height: self.frame.width / 15)
            enemyShip.size = shipSize
            
            let gap = 3.5 * enemyShip.size.width
            switch i {
            case 0...4:
                enemyShip.position = CGPoint(x: CGFloat(i) * enemyShip.size.width * 2 + gap,
                                             y: (scene?.size.height)! - (enemyTexture.size().height * 2))
            case 5...9:
                enemyShip.position = CGPoint(x: (CGFloat(i) - 5) * enemyShip.size.width * 2 + gap,
                                             y: (scene?.size.height)! - (enemyTexture.size().height * 4))
            case 10...14:
                enemyShip.position = CGPoint(x: (CGFloat(i) - 10) * enemyShip.size.width * 2 + gap,
                                             y: (scene?.size.height)! - (enemyTexture.size().height * 6))
            case 15...19:
                enemyShip.position = CGPoint(x: (CGFloat(i) - 15) * enemyShip.size.width * 2 + gap,
                                             y: (scene?.size.height)! - (enemyTexture.size().height * 8))
            default:
                print("Bazinga!")
            }
            enemies.append(enemyShip)
            enemy.addChild(enemies[i])
            enemy.physicsBody?.isDynamic = true
            enemy.physicsBody?.categoryBitMask = enemyMask
            enemy.physicsBody?.contactTestBitMask = playerShotMask
            enemy.physicsBody?.collisionBitMask = playerShotMask
        }
    }
    
    func addEnemyShot() {
        if enemies.count > 0 {
            enemyShotSprite = SKSpriteNode(texture: enemyShotTexture)
            enemyShotSprite.physicsBody = SKPhysicsBody(rectangleOf: enemyShotSprite.size)
            enemyShotSprite.physicsBody?.categoryBitMask = enemyShotMask
            enemyShotSprite.physicsBody?.contactTestBitMask = playerMask
            enemyShotSprite.physicsBody?.collisionBitMask = playerMask
            enemyShotSprite.physicsBody?.allowsRotation = false
            enemyShotSprite.zPosition = 2
            enemyShotSprite.physicsBody?.restitution = 0
            enemyShotSprite.position = enemies[Int.random(in: 0...enemies.count - 1)].position
            enemyShot.addChild(enemyShotSprite)
            enemyShot.physicsBody?.categoryBitMask = enemyShotMask
            enemyShot.physicsBody?.collisionBitMask = playerMask
            enemyShot.physicsBody?.contactTestBitMask = playerMask
        }
    }
    
    func addPlayerShot() {
        playerShotSprite = SKSpriteNode(texture: playerShotTexture)
        playerShotSprite.physicsBody = SKPhysicsBody(rectangleOf: playerShotSprite.size)
        playerShotSprite.physicsBody?.categoryBitMask = playerShotMask
        playerShotSprite.physicsBody?.contactTestBitMask = enemyMask
        playerShotSprite.physicsBody?.collisionBitMask = enemyMask
        playerShotSprite.physicsBody?.allowsRotation = false
        playerShotSprite.physicsBody?.affectedByGravity = false
        playerShotSprite.zPosition = 1
        playerShotSprite.physicsBody?.restitution = 0
        playerShotSprite.position = CGPoint(x: player.position.x + self.frame.midX, y: playerSprite.position.y + 10)
        playerShot.addChild(playerShotSprite)
        playerShot.physicsBody?.categoryBitMask = playerShotMask
        playerShot.physicsBody?.contactTestBitMask = enemyMask
        playerShot.physicsBody?.collisionBitMask = enemyMask
        playerShotSprite.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        
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
    
    
    //MARK: Physics Interactions
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
                 
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        //Попадание в игрока
        if((firstBody.categoryBitMask & playerMask != 0) && (secondBody.categoryBitMask & enemyShotMask != 0)){
            print("Player got Shot!")
            enemyShotSprite.texture = SKTexture(imageNamed: "laserRedShot")
            enemyShotSprite.size = SKTexture(imageNamed: "laserRedShot").size()
            enemyShotSprite.setScale(1.5)
            playerHitTimer.invalidate()
            playerHitTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [self]_ in
            
                if isShielded {
                    shieldSprite.removeFromParent()
                    enemyShotSprite.removeFromParent()
                    isShielded = false
                } else if isDamaged == false {
                    isDamaged = true
                    enemyShotSprite.removeFromParent()
                    playerCurrentTexture = SKTexture(imageNamed: "playerDamaged")
                    playerSprite.texture = playerCurrentTexture
                } else {
                    playerSprite.removeFromParent()
                    enemyShotSprite.removeFromParent()
                }
            })
        }
        
        //Попадание во врага
        if((firstBody.categoryBitMask & enemyMask != 0) && (secondBody.categoryBitMask & playerShotMask != 0)){
            playerShotSprite.texture = SKTexture(imageNamed: "laserGreenShot")
            playerShotSprite.size = SKTexture(imageNamed: "laserGreenShot").size()
            //playerShotSprite.setScale(1.05)
            var index = 0
            for i in enemies.indices {
                if enemies[i] == firstBody.node {
                    index = i
                }
            }
            enemies.remove(at: index)
            print(enemies.count)
            firstBody.node?.removeFromParent()
            secondBody.applyImpulse(CGVector(dx: 0, dy: 2))
            enemyHitTimer.invalidate()
            enemyHitTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [self]_ in
                
                secondBody.node?.removeFromParent()
                //enemies.removeLast()
                canFire = true
            })
        }
    }
    
    //MARK: Касания экрана
    
    func touchDown(atPoint pos : CGPoint) {
        
        if leftSprite.contains(pos) {
            let moveLeft = SKAction.moveTo(x: -self.frame.midX + playerSprite.size.width * 1.5, duration: 1)
            playerSprite.texture = playerLeftTexture
            player.run(moveLeft)
        }
        
        if rightSprite.contains(pos) {
            let moveRight = SKAction.moveTo(x: self.frame.midX - playerSprite.size.width * 1.5, duration: 1)
            playerSprite.texture = playerRightTexture
            player.run(moveRight)
            //print (player.position)
        }
        
        if fireSprite.contains(pos) {
            if canFire {
                addPlayerShot()
                canFire = false
            }
        }
    }
    
    
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        player.removeAllActions()
        playerSprite.texture = playerCurrentTexture
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
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        var moveDown = false
        for i in enemies.indices {
            if enemies[i].position.x >= self.frame.size.width - 100 {
                //enemies[0].position.x -= 1
                enemyDir = -1
                moveDown = true
            } else if enemies[i].position.x <= 100 {
                //enemies[0].position.x += 1
                enemyDir = 1
                moveDown = true
            }
            enemies[i].position.x += enemyDir
        }
        
        for i in enemies.indices {
            if moveDown { enemies[i].position.y -= enemyTexture.size().height }
        }
        
        if enemyShotSprite.position.y < -5 {
            enemyShotSprite.removeFromParent()
        }
        
        if playerShotSprite.position.y > self.frame.maxY + 10 {
            playerShotSprite.removeFromParent()
            canFire = true
        }
    }
}
