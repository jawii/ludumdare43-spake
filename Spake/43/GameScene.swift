//
//  GameScene.swift
//  43
//
//  Created by Jaakko Kenttä on 01/12/2018.
//  Copyright © 2018 Jaakko Kenttä. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None:   UInt32   = 0
    static let Head:    UInt32  = 0b1 // 1
    static let SnakeNode:  UInt32    = 0b10 // 2
    static let Enemy:    UInt32 = 0b100 // 4
    static let EnemyBullet:   UInt32   = 0b1000 // 8
    static let MotherNode:   UInt32   = 0b10000 // 16
    static let Edge:   UInt32   = 0b100000 // 32
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var head: HeadNode!
    var motherNode: MotherNode!
    var lastTouchLocation: CGPoint?
    
    //camera
    let cam = SKCameraNode()
    var enemies = [EnemyNode]()
    
    var controlNob: SKShapeNode!
    var controlCircle: SKShapeNode!
    var controlNobDown = false {
        didSet {
            let moveAction = SKAction.move(to: CGPoint.zero, duration: 0.5)
            controlNob.run(moveAction)
        }
    }
    var startTime: TimeInterval = 0
    var totalTime: TimeInterval = 0
    
    var surviveTime: TimeInterval = 0 {
        didSet {
            timerLabel.text = "\(Int(surviveTime))"
        }
    }
    let timerLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    let snakeLengthLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    
    var enemySpawnTime: Double = 15
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let bgEmitter = SKEmitterNode(fileNamed: "stars.sks")!
        bgEmitter.advanceSimulationTime(30)
        bgEmitter.position = CGPoint(x: scene!.size.width / 2, y: scene!.size.height / 2)
        bgEmitter.zPosition = -1
        addChild(bgEmitter)
        
        // Create Head node
        head = HeadNode()
        head.delegate = self
        addChild(head)
        
        motherNode = MotherNode()
        addChild(motherNode)
        motherNode.position = CGPoint(x: 1200, y: 1500)
        print(motherNode)
        
        print("View Size: \(self.view!.frame)")
        print("Scene Size: \(self.scene!.size)")
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: CGPoint.zero, size: self.size))
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        let shape = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        shape.physicsBody?.categoryBitMask = PhysicsCategory.Edge
        shape.strokeColor = UIColor.black
        shape.lineWidth = 15
        addChild(shape)
        
        addChild(cam)
        self.camera = cam
        setupSpawning()
        setupCamera()
        setupNob()
        setupUIElements()
        
        head.position = CGPoint(x: 1000, y: 1000)
    }
    
    func setupUIElements() {
        let releaseButton = SKSpriteNode(imageNamed: "releaseButton")
        releaseButton.setScale(4)
        releaseButton.position = CGPoint(
            x: -self.scene!.size.width / 2 + releaseButton.frame.width / 2 + 350,
            y: -self.scene!.size.height / 2 + releaseButton.frame.height / 20 + 550)
        releaseButton.name = "releaseButton"
        cam.addChild(releaseButton)
        
        timerLabel.text = "SURVIVED: \(surviveTime)"
        timerLabel.fontSize = 150
        timerLabel.fontColor = UIColor.white
        
        timerLabel.position = CGPoint(x: 0, y: size.height * 0.5 - 400)
        timerLabel.verticalAlignmentMode = .center
        cam.addChild(timerLabel)
        
        snakeLengthLabel.text = "Current length: \(0)"
        snakeLengthLabel.fontSize = 150
        snakeLengthLabel.fontColor = UIColor.white
        
        snakeLengthLabel.position = CGPoint(x: -size.width * 0.5 + 600, y: size.height * 0.5 - 400)
        snakeLengthLabel.verticalAlignmentMode = .center
        cam.addChild(snakeLengthLabel)
    }
    
    func setupCamera() {
        let camScale: CGFloat = 0.5
        camera?.setScale(camScale)
        
        guard let camera = camera else {
            return
        }
        let zeroDistance = SKRange(constantValue: 0)
        let playerConstraint = SKConstraint.distance(zeroDistance, to: head)
        
        
        let xInset = min(size.width/2 * camera.xScale, size.width/2)
        let yInset = min(size.height/2 * camera.yScale, size.height/2)
        let frame = CGRect(origin: CGPoint.zero, size: size)
        let constraintRect = frame.insetBy(dx: xInset, dy: yInset)
        let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
        let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)

        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = self

        camera.constraints = [playerConstraint, edgeConstraint]
//        camera.constraints = [playerConstraint]
    }
    
    func setupNob() {
        let radius:CGFloat = 1200
        controlCircle = SKShapeNode(circleOfRadius: radius)
        controlCircle.fillColor = UIColor.black.withAlphaComponent(0.7)
        controlCircle.lineWidth = 20
        controlCircle.strokeColor = UIColor.white.withAlphaComponent(0.7)
        controlCircle.position = CGPoint(x: self.scene!.size.width / 2 - radius,
                                         y: -self.scene!.size.height / 2 + radius + 350)
        camera?.addChild(controlCircle)
        
        controlNob = SKShapeNode.init(circleOfRadius: 400)
        controlNob.fillColor = UIColor.gray
        controlNob.name = "control"
        controlNob.strokeColor = UIColor.clear
        controlNob.position = CGPoint(x: 0, y: 0)
        controlCircle.addChild(controlNob)
        
        let nobConstraint = SKConstraint.distance(SKRange(upperLimit: 1000), to: CGPoint.zero, in: controlCircle)
        controlNob.constraints = [nobConstraint]
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        //
        // HEAD AND NODE COLLISION
        //
        if collision == PhysicsCategory.SnakeNode | PhysicsCategory.Head {
            let node = contact.bodyA.categoryBitMask == PhysicsCategory.SnakeNode ?
                contact.bodyA.node :
                contact.bodyB.node
            
            if let followerNode = node as? FollowerNode, followerNode.isFollower == false {
                
                if head.snakeChild == nil {
                    self.head.addFollower(followerNode)
                } else {
//                     find last head follower
                    var follower = head.snakeChild
                    var lastFollower = follower
                    while follower != nil {
                        lastFollower = follower
                        follower = follower?.snakeChild
                    }
                    lastFollower!.addFollower(followerNode)
                }
                followerNode.isFollower = true
            }
        }
        
        //
        //  BULLET AND NODE COLLISION
        //
        if collision == PhysicsCategory.SnakeNode | PhysicsCategory.EnemyBullet {
            let node = contact.bodyA.categoryBitMask == PhysicsCategory.SnakeNode ? contact.bodyA.node : contact.bodyB.node
            if let followerNode = node as? FollowerNode, followerNode.isFollower == true {
                followerNode.released()
            }
            let bullet = contact.bodyA.categoryBitMask == PhysicsCategory.EnemyBullet ?
                contact.bodyA.node :
                contact.bodyB.node
            bullet?.removeFromParent()
        }
        
        //
        //  BULLET AND MOTHER COLLISION
        //
        if collision == PhysicsCategory.MotherNode | PhysicsCategory.EnemyBullet {
            let mother: SKNode?
            let bullet: SKNode?
            if contact.bodyA.categoryBitMask == PhysicsCategory.MotherNode {
                mother = contact.bodyA.node as? MotherNode
                bullet = contact.bodyB.node
            } else {
                mother = contact.bodyB.node
                bullet = contact.bodyA.node
            }
            
            bullet?.removeFromParent()
            let motherNode = mother as! MotherNode
            motherNode.hit()
        }
        
        
        //
        // NODE AND ENEMY
        //
        if collision == PhysicsCategory.Enemy | PhysicsCategory.SnakeNode {
            let snakePart: FollowerNode
            let enemy: EnemyNode
            if contact.bodyA.categoryBitMask == PhysicsCategory.SnakeNode {
                snakePart = contact.bodyA.node as! FollowerNode
                enemy = contact.bodyB.node as! EnemyNode
            } else {
                snakePart = contact.bodyB.node as! FollowerNode
                enemy = contact.bodyA.node as! EnemyNode
            }
            if snakePart.isFollower {
                snakePart.stickTo(enemy: enemy)
            } else {
                snakePart.released()
            }
        }
    }
    
    func setupSpawning() {
        // Spawn Enemys
        let spawnEnemyAction = SKAction.run { self.spawnEnemy() }
        let enemyWaitAction = SKAction.wait(forDuration: 5.0)
        let enemySequence = SKAction.sequence([enemyWaitAction, spawnEnemyAction])
        run(enemySequence)
        
        // Spawn Nodes
        let waitAction = SKAction.wait(forDuration: 0.2)
        let spawnBlockAction = SKAction.run {
            self.spawnPickup()
        }
        let sequence = SKAction.sequence([waitAction, spawnBlockAction])
        let repeatAction = SKAction.repeatForever(sequence)
        run(repeatAction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        if let name = touchedNode.name {
            if name == "releaseButton"{
                head.releaseSnake()
                return
            }
            if name == "control" {
                controlNobDown = true
            }
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let nobLoc = touch.location(in: controlCircle)

        if controlNobDown {
            controlNob.position = nobLoc
            let velocityVector = CGVector(dx: nobLoc.x, dy: nobLoc.y)
            head.setVelocity(to: velocityVector)
            return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        controlNobDown = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        if startTime == 0 {
            startTime = currentTime
        }
        totalTime = currentTime - startTime
        surviveTime = totalTime
        
        self.snakeLengthLabel.text = "LENGTH: \(head.snakeLength)"
    }
    
    override func didEvaluateActions() {
    }
    
    // SPAWNER
    func spawnPickup() {
        let number = FollowerNode()
        number.name = "block"
        number.position = CGPoint(
            x: CGFloat.random(in: 0.0 ... size.width),
            y: CGFloat.random(in: 0.0 ... size.height))
        addChild(number)
    }
    
    func spawnEnemy() {
        
        let enemy = EnemyNode(health: 5)
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: CGFloat.random(in: 0.0 ... size.width),
            y: CGFloat.random(in: 0.0 ... size.height))
        addChild(enemy)
        enemies.append(enemy)
        
        /*
        let warningLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        warningLabel.text = "ENEMY SPAWNED"
        warningLabel.fontSize = 150
        warningLabel.setScale(0)
        let scaleUpAction = SKAction.scale(to: 4, duration: 0.4)
        let scaleDownAction = SKAction.scale(to: 0, duration: 0.25)
        let removeAction = SKAction.run {
            warningLabel.removeFromParent()
        }
        cam.addChild(warningLabel)
        let sequence = SKAction.sequence([scaleUpAction, scaleDownAction, removeAction])
        warningLabel.run(sequence)
        */
        
        enemySpawnTime -= 0.5
        enemySpawnTime = max(2, enemySpawnTime)
        let spawnEnemyAction = SKAction.run { self.spawnEnemy() }
        let enemyWaitAction = SKAction.wait(forDuration: enemySpawnTime)
        let enemySequence = SKAction.sequence([enemyWaitAction, spawnEnemyAction])
        run(enemySequence)
    }
    
}

extension GameScene: SnakeHeadDelegate {
    func didAddSnakePart(count: Int) {
        self.snakeLengthLabel.text = "LENGTH: \(count)"
    }
}
