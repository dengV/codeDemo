//  Copyright © 2017 Jingyuan "Knight" Zhang. All rights reserved.


import Foundation
import SpriteKit // iOS Game Developement Engine

class DEFVisibleArea: SKSpriteNode {
    
    // MARK: Properties
    var nodeInScene:SKSpriteNode?
    weak var parentScene: DEFFlipVarD?
    
    
    override func awakeFromNib() {
        
        self.physicsBody = SKPhysicsBody.init(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = Mask.Border
        self.physicsBody?.contactTestBitMask = Mask.Border
        self.physicsBody?.collisionBitMask = 0
        self.zPosition = 300

    }
    
    // MARK: Initializer
    init(sceneName: String?, childNodeName: String?, parentScene: DEFFlipVarD!) {
        
        
        let idealSize = CGSizeMake(parentScene.hostingCell.scenePresentingView.frame.width, parentScene.hostingCell.scenePresentingView.frame.height)
        
        if let theSceneName = sceneName, let theChildNodeName = childNodeName {

            nodeInScene = SKScene(fileNamed: theSceneName)?.childNodeWithName(theChildNodeName) as? SKSpriteNode

        } else {

            nodeInScene = SKScene(fileNamed: "Areas")?.childNodeWithName("flipVisibleArea") as? SKSpriteNode
        }

        super.init(texture: nodeInScene!.texture, color: nodeInScene!.color, size: idealSize)

        self.parentScene = parentScene

        self.physicsBody = SKPhysicsBody.init(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = Mask.Border
        self.physicsBody?.contactTestBitMask = Mask.Border
        self.physicsBody?.collisionBitMask = 0
        self.zPosition = 300
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Methods
    
    func showToFillAtVisibleAreaInParentScene(){
        
        self.physicsBody = SKPhysicsBody.init(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = Mask.Border
        self.physicsBody?.collisionBitMask = Mask.MiddleLine | Mask.SmallBalls

                
        removeFromParent()

        self.size = CGSizeMake((parentScene?.frame.width)!, (parentScene?.frame.height)!)
        self.show(atPosition: CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(parentScene!.frame)))

    }
    
    func show(atPosition positionToShow:CGPoint?) {
        
        self.removeFromParent()
        if let thePosition = positionToShow {
            self.position = thePosition
        }

        parentScene!.addChild(self)
        
    }

    func show(accordingToFrame frame:CGRect?) {
        
        self.removeFromParent()
        
        if let theFrame = frame {
            self.position = CGPointMake(CGRectGetMidX(theFrame), CGRectGetMidY(theFrame))
            self.size = (theFrame.size)
        }

        let fadeInAction = SKAction.fadeInWithDuration(1.0)
        parentScene!.addChild(self)
        self.runAction(fadeInAction)

        
    }
    
    func show(ToTheSideOfTheAligningNode aligningNode:SKSpriteNode, toTheRight toTheRightRatherThanToTheLeft: Bool) {
        
        if toTheRightRatherThanToTheLeft == true {
            
            self.show(accordingToFrame: CGRectMake(CGRectGetMaxX(aligningNode.frame), CGRectGetMinY(parentScene!.frame), CGRectGetMaxX(parentScene!.frame) - CGRectGetMaxX(aligningNode.frame), CGRectGetMaxY(parentScene!.frame)))
            
        } else {
            
            self.show(accordingToFrame: CGRectMake(CGRectGetMinX(parentScene!.frame), CGRectGetMinY(parentScene!.frame), CGRectGetMinX(aligningNode.frame), CGRectGetMaxX(parentScene!.frame)))

        }
    }
    
    
    override func disappear(){
        
        let fadeOutAction = SKAction.fadeOutWithDuration(1.0)
        self.runAction(fadeOutAction, completion: {
            self.removeFromParent()
        })
        
    }
    

    func move(accordingToFrame frame:CGRect?) {
        
        if let theFrame = frame {
            self.position = CGPointMake(CGRectGetMidX(theFrame), CGRectGetMidY(theFrame))
            self.size = (theFrame.size)
        }
        let fadeInAction = SKAction.fadeInWithDuration(1.0)
        self.runAction(fadeInAction)
    }
    
    func move(accordingToTheSideOfTheAligningNode aligningNode:SKSpriteNode, toTheRight toTheRightRatherThanToTheLeft: Bool) {
        
        if toTheRightRatherThanToTheLeft == true {
            
            self.move(accordingToFrame: CGRectMake(CGRectGetMaxX(aligningNode.frame), CGRectGetMinY(aligningNode.frame), CGRectGetMaxX(parentScene!.frame) - CGRectGetMaxX(aligningNode.frame), CGRectGetMaxY(parentScene!.frame)))
            
        } else {
            
            self.move(accordingToFrame: CGRectMake(CGRectGetMinX(parentScene!.frame), CGRectGetMinY(parentScene!.frame), CGRectGetMinX(aligningNode.frame), CGRectGetMaxX(parentScene!.frame)))
        }
    }
    
    
    // MARK: Support Methods
    func replace(PropetiesOfNode targetNode: SKSpriteNode, fromNodeInTheSceneFile nodeInSceneFile: SKSpriteNode) {
        
        // Replace all the necessary properties
        targetNode.size = nodeInSceneFile.size
        targetNode.zPosition = nodeInSceneFile.zPosition
        targetNode.anchorPoint = nodeInSceneFile.anchorPoint
        targetNode.texture = nodeInSceneFile.texture
        targetNode.centerRect = nodeInSceneFile.centerRect
        targetNode.colorBlendFactor = nodeInSceneFile.colorBlendFactor
        targetNode.color = nodeInSceneFile.color
        targetNode.blendMode = nodeInSceneFile.blendMode
        targetNode.lightingBitMask = nodeInSceneFile.lightingBitMask
        targetNode.shadowedBitMask = nodeInSceneFile.shadowedBitMask
        targetNode.shadowCastBitMask = nodeInSceneFile.shadowCastBitMask
        targetNode.normalTexture = nodeInSceneFile.normalTexture
        targetNode.shader = nodeInSceneFile.shader
        targetNode.physicsBody = nodeInSceneFile.physicsBody
        
        
    }
    
    
    
}
