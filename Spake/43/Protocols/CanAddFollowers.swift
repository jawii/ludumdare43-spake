//
//  CanAddFollowers.swift
//  43
//
//  Created by Jaakko Kenttä on 02/12/2018.
//  Copyright © 2018 Jaakko Kenttä. All rights reserved.
//

import SpriteKit


protocol CanAddFollowers: class  {
    //    associatedtype Node = SKNode
    var snakeChild: FollowerNode? { get set }
    var snakeParent: CanAddFollowers? { get set }
    var limitJoint: SKPhysicsJointLimit! { get set }
    var jointLength: CGFloat { get }
    
    var delegate: SnakeHeadDelegate? { get }
}

extension CanAddFollowers {
    var snakeLength: Int {
        #warning("Fix this")
        if self.snakeChild == nil { return 0 }
        var count = 0
        var child: FollowerNode?  = self.snakeChild
        while child != nil {
            count += 1
            child = child?.snakeChild
        }
        return count
    }
}

extension CanAddFollowers where Self : SKSpriteNode {
    
    func addFollower(_ follower: FollowerNode) {
        
        if self.snakeChild != nil { return }
        self.snakeChild = follower
        follower.snakeParent = self
        // Hide
        let scaleUpAction = SKAction.scale(to: 1.1, duration: 0.05)
        let scaleDownAction = SKAction.scale(to: 0.05, duration: 0.10)
        let moveAction = SKAction.run {
            follower.position = self.position
        }
        let hideAction = SKAction.sequence([scaleUpAction, scaleDownAction, moveAction])
        
        let reveal = SKAction.scale(to: 1.0, duration: 0.15)
        let followerHideAndMoveSequence = SKAction.sequence([hideAction, reveal])
        
        let addJointAction = SKAction.run {
            self.limitJoint = SKPhysicsJointLimit.joint(withBodyA: self.physicsBody!, bodyB: follower.physicsBody!, anchorA: self.position, anchorB: follower.position)
            self.limitJoint.maxLength = self.jointLength
            self.scene?.physicsWorld.add(self.limitJoint)
        }
        
        follower.run(followerHideAndMoveSequence) {
            self.run(addJointAction)
        }
        
//        delegate?.didAddSnakePart(count: self.snakeLength)
    }
}
