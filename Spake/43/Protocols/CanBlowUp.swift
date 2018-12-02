//
//  CanBlowUpProtocol.swift
//  43
//
//  Created by Jaakko Kenttä on 02/12/2018.
//  Copyright © 2018 Jaakko Kenttä. All rights reserved.
//

import SpriteKit

protocol CanBlowUp: class {
    func blowUp()
}
extension CanBlowUp where Self : SKSpriteNode {
    func blowUp() {
        
        let scaleUpAction = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDownAction = SKAction.scale(to: 0.01, duration: 0.2)
        
        var points = [CGPoint]()
        let circleRadius: CGFloat = 30
        let pointCount = 50
        let angle = 2*π / CGFloat(pointCount)
        for i in 0 ... pointCount {
            let x = position.x + circleRadius * cos(CGFloat(i) * angle)
            let y = position.x + circleRadius * sin(CGFloat(i) * angle)
            points.append(CGPoint(x: x, y: y))
        }
        
        var vectorPoints = [CGPoint]()
        let vectorRadius = circleRadius + 300
        for i in 0 ... pointCount {
            let x = position.x + vectorRadius * cos(CGFloat(i) * angle)
            let y = position.x + vectorRadius * sin(CGFloat(i) * angle)
            vectorPoints.append(CGPoint(x: x, y: y))
        }
        
        run(SKAction.sequence([scaleUpAction, scaleDownAction])) {
            
            for i in 0 ... pointCount {
                let shape = SKShapeNode(circleOfRadius: 10)
                shape.fillColor = UIColor.yellow
                //
                shape.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.width / CGFloat(2.0))
                shape.physicsBody?.categoryBitMask = PhysicsCategory.EnemyBullet
                shape.physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.SnakeNode
                shape.physicsBody?.contactTestBitMask = PhysicsCategory.Head | PhysicsCategory.SnakeNode
                shape.position = self.convert(points[i], to: self.scene!)
                
                self.scene!.addChild(shape)
                
                let waitAction = SKAction.wait(forDuration: 5)
                let removeAction = SKAction.removeFromParent()
                shape.run(SKAction.sequence([waitAction, removeAction]))
                
                let vectorPoint = vectorPoints[i]
                let dx = shape.position.x - vectorPoint.x
                let dy = shape.position.x - vectorPoint.y
                let vector = CGVector(dx: dx * 10, dy: dy * 10)
                //                shape.physicsBody?.applyImpulse(vector)
                shape.physicsBody!.applyForce(vector)
            }
        }
    }
}
