//
//  HeadNode.swift
//  43
//
//  Created by Jaakko Kenttä on 01/12/2018.
//  Copyright © 2018 Jaakko Kenttä. All rights reserved.
//

import SpriteKit

protocol SnakeHeadDelegate: class {
    func didAddSnakePart(count: Int)
}

class HeadNode: SKSpriteNode, CanAddFollowers {

    // CONSTANTS
    private var VELOCITY: CGFloat = 1250
    let rotateRadiansPerSec: CGFloat = 4.0 * π

    var snakeChild: FollowerNode? = nil
    var snakeParent: CanAddFollowers? = nil
    
    var limitJoint: SKPhysicsJointLimit!
    var jointLength: CGFloat {
        return 100
    }
    
    weak var delegate: SnakeHeadDelegate?
    
    convenience init() {
        let texture = SKTexture(imageNamed: "head")
        self.init(texture: texture)
        
        let size = CGSize(width: self.size.width, height: self.size.height)
        self.physicsBody = SKPhysicsBody(texture: texture, size: size)
        
        physicsBody!.categoryBitMask = PhysicsCategory.Head
        physicsBody!.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Enemy | PhysicsCategory.MotherNode
        physicsBody!.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.SnakeNode

        self.physicsBody!.restitution = 0.0
        self.physicsBody!.mass = 300
        self.physicsBody!.angularDamping = 500
        
//        let emitter = SKEmitterNode(fileNamed: "thrust")!
//        addChild(emitter)
    }
    
    func setVelocity(to vector: CGVector) {
        let angle = CGPoint(x: self.physicsBody!.velocity.dx, y: self.physicsBody!.velocity.dy).angle - π/2
        zRotation = angle
        self.physicsBody?.velocity = vector * CGFloat(2.5)
    }
    
    func releaseSnake() {
        if snakeChild == nil { return }
        
        self.scene?.physicsWorld.remove(limitJoint)
 
        let currentVelocity = physicsBody!.velocity
        let force = CGVector(dx: currentVelocity.dx, dy: currentVelocity.dy)
        
        var currentFollower = snakeChild
        while currentFollower != nil {
//            currentFollower?.released()
            currentFollower?.physicsBody?.applyForce(force)
            currentFollower = currentFollower?.snakeChild
        }
        snakeChild?.snakeParent = nil
        snakeChild = nil
    }

}
