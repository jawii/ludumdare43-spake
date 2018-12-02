//
//  MotherNode.swift
//  43
//
//  Created by Jaakko Kenttä on 02/12/2018.
//  Copyright © 2018 Jaakko Kenttä. All rights reserved.
//

import SpriteKit


class MotherNode: SKSpriteNode {
    
    var health: Int = 20 {
        didSet {
            healthLabel.text = "\(health)"
            healthLabel.zPosition += 1
        }
    }
    var healthLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    
    convenience init() {
        let texture = SKTexture(imageNamed: "mothernode")
        self.init(texture: texture)
        self.setScale(5)
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: size)
        self.physicsBody?.mass = 200
        physicsBody!.categoryBitMask = PhysicsCategory.MotherNode
        physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Enemy | PhysicsCategory.EnemyBullet
        physicsBody!.contactTestBitMask = PhysicsCategory.EnemyBullet
        physicsBody?.friction = 1.0
        
        physicsBody!.applyForce(CGVector(dx: 100, dy: 100))
        
//        let field = SKFieldNode.radialGravityField()
//        field.strength = 0.5
//        field.falloff = 0.25
//        field.categoryBitMask = PhysicsCategory.SnakeNode
//        field.position = self.position
//        field.region = SKRegion(radius: Float(self.size.width/2) * Float(1))
//        self.addChild(field)
        
        healthLabel = SKLabelNode(text: "\(health)")
        healthLabel.fontName = "AvenirNext-Heavy"
        healthLabel.fontSize = 25
        healthLabel.verticalAlignmentMode = .center
        healthLabel.horizontalAlignmentMode = .center
//        healthLabel.position.y -= self.size.height / 2
        self.addChild(healthLabel)
    }
    
    func hit() {
        print("Mother Hit")
        self.health -= 1
        if health <= 0 {
            self.removeFromParent()
            print("Mother Dead")
        }
    }
}
