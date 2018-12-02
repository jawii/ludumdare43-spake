//
//  EnemyNode.swift
//  43
//
//  Created by Jaakko Kenttä on 01/12/2018.
//  Copyright © 2018 Jaakko Kenttä. All rights reserved.
//

import SpriteKit

class EnemyNode: SKSpriteNode, CanBlowUp {
    
    var health: Int = 5
    
    convenience init(health: Int) {
        let texture = SKTexture(imageNamed: "enemy2")
        self.init(texture: texture)
        self.health = health
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: size)
        
        physicsBody!.categoryBitMask = PhysicsCategory.Enemy
        physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.SnakeNode | PhysicsCategory.Enemy
        physicsBody!.contactTestBitMask = PhysicsCategory.Head | PhysicsCategory.SnakeNode 
        color = UIColor.yellow
        
        let scaleUpAction = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDownAction = SKAction.scale(to: 0.8, duration: 0.5)
        let bombTickAction = SKAction.repeatForever(SKAction.sequence([scaleUpAction, scaleDownAction]))
        
        self.run(bombTickAction, withKey: "tick")
        
        let random = TimeInterval(Int.random(in: 5 ... 15))
        let waitAction = SKAction.wait(forDuration: random)
        let colorizeAction = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: random)
        let actionGroup = SKAction.group([waitAction, colorizeAction])
        
        run(actionGroup) {
            self.removeAction(forKey: "tick")
            self.blowUp()
        }
    }
}
