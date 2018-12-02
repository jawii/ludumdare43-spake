//
//  FollowerNode.swift
//  43
//
//  Created by Jaakko Kenttä on 01/12/2018.
//  Copyright © 2018 Jaakko Kenttä. All rights reserved.
//

import SpriteKit



class FollowerNode: SKSpriteNode, CanAddFollowers, CanBlowUp {
    var snakeChild: FollowerNode?
    var snakeParent: CanAddFollowers?
    var limitJoint: SKPhysicsJointLimit!
    
    var jointLength: CGFloat {
        return self.size.width + 10
    }
    
    weak var delegate: SnakeHeadDelegate?

    var isFollower = false {
        didSet {
            physicsBody?.angularDamping = 0.0
            physicsBody?.linearDamping = 10.0
            physicsBody?.restitution = 1.0
            physicsBody?.friction = 0.2
            physicsBody?.allowsRotation = false
            
            self.physicsBody!.mass = 0.5
            var color = UIColor.init(red: CGFloat.random(in: 0 ... 1), green: CGFloat.random(in: 0 ... 1), blue: CGFloat.random(in: 0 ... 1), alpha: 1)
            color = UIColor.yellow
            let action = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.5)
            run(action)
        }
    }
    
    convenience init() {
        let texture = SKTexture(imageNamed: "follower")
        self.init(texture: texture)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        
        physicsBody!.categoryBitMask = PhysicsCategory.SnakeNode
        physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Enemy | PhysicsCategory.SnakeNode
        physicsBody!.contactTestBitMask = PhysicsCategory.SnakeNode | PhysicsCategory.EnemyBullet | PhysicsCategory.Enemy
    
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
        self.setScale(0)
        run(scaleAction)
        
//        print("Node mass: \(physicsBody!.mass)")
//        print("Node area: \(physicsBody!.area)")
//        print("Node friction: \(physicsBody!.friction)")
//        print("Node linear damping: \(physicsBody!.linearDamping)")
//        print("Node Angular Damping: \(physicsBody!.angularDamping)")
//        print("Node Density: \(physicsBody!.density)")
//        print("Node restitution: \(physicsBody!.restitution)")
//        print("Node allows rotation: \(physicsBody!.allowsRotation)")
    }
    
    func released() {
        self.snakeParent?.snakeChild = nil
        
        self.physicsBody?.mass = 0.05
        self.physicsBody?.angularDamping = 0.1
        self.physicsBody?.linearDamping = 0.1
        self.physicsBody?.restitution = 0.2
        self.physicsBody?.allowsRotation = true
        
        let emitter = SKEmitterNode(fileNamed: "snakeComponentExplosion.sks")!
        emitter.position = self.position
        self.scene?.addChild(emitter)
        self.removeFromParent()
        
        
    }
    
    func stickTo(enemy: EnemyNode) {
        
        if let scene = scene as? GameScene {
            let joint = SKPhysicsJointPin.joint(withBodyA: enemy.physicsBody!, bodyB: self.physicsBody!, anchor: self.position)
            scene.physicsWorld.add(joint)
        }
    }
}
