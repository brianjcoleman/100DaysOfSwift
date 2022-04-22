//
//  GameScene.swift
//  Milestone6
//
//  Created by Brian Coleman on 2022-04-22.
//

import SpriteKit

class GameScene: SKScene {
    var waterBg: SKSpriteNode!
    var waterFg: SKSpriteNode!
    
    var target: SKSpriteNode!
    
    var timeLabel: SKLabelNode!
    var minute = 60 {
        willSet {
            timeLabel.text = "Time: \(newValue)"
        }
    }
    
    var gameOverLabel: SKSpriteNode!
    var isGameOver: Bool = true {
        willSet {
            if newValue {
                newGameLabel.alpha = 1
            } else if !newValue {
                newGameLabel.alpha = 0
            }
        }
    }
    
    var newGameLabel: SKLabelNode!
    
    var gameTimer: Timer?
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var shotsImage: SKSpriteNode!
    var shots = 3 {
        didSet {
            shotsImage.texture = SKTexture(imageNamed: "shots\(shots)")
        }
    }
    
    var reloadLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.size = view.frame.size
        addChild(background)
        
        let curtainBackground = SKSpriteNode(imageNamed: "curtains")
        curtainBackground.position = CGPoint(x: 512, y: 384)
        curtainBackground.size = view.frame.size
        curtainBackground.zPosition = 100
        addChild(curtainBackground)
        
        let grassTrees = SKSpriteNode(imageNamed: "grass-trees")
        grassTrees.position = CGPoint(x: 512, y: 440)
        grassTrees.size.width = view.frame.size.width
        grassTrees.zPosition = 2
        addChild(grassTrees)
        
        waterBg = SKSpriteNode(imageNamed: "water-bg")
        waterBg.position = CGPoint(x: 512, y: 280)
        waterBg.size.width = view.frame.size.width
        waterBg.zPosition = 4
        addChild(waterBg)
        
        waterFg = SKSpriteNode(imageNamed: "water-fg")
        waterFg.position = CGPoint(x: 512, y: 170)
        waterFg.size.width = view.frame.size.width
        waterFg.zPosition = 6
        addChild(waterFg)
        
        timeLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeLabel.position = CGPoint(x: 110, y: 700)
        timeLabel.zPosition = 101
        timeLabel.text = "Time: 60"
        timeLabel.fontSize = 44
        addChild(timeLabel)
        
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.fontColor = .green
        newGameLabel.position = CGPoint(x: 512, y: 700)
        newGameLabel.zPosition = 101
        newGameLabel.fontSize = 44
        newGameLabel.text = "New Game"
        newGameLabel.name = "playGame"
        newGameLabel.alpha = 1
        addChild(newGameLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 1020, y: 700)
        scoreLabel.zPosition = 101
        scoreLabel.fontSize = 44
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        addChild(scoreLabel)
        
        shotsImage = SKSpriteNode(imageNamed: "shots\(shots)")
        shotsImage.position = CGPoint(x: 440, y: 45)
        shotsImage.zPosition = 101
        addChild(shotsImage)
        
        reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel.position = CGPoint(x: 570, y: 35)
        reloadLabel.zPosition = 101
        reloadLabel.fontSize = 22
        reloadLabel.text = "RELOAD!"
        reloadLabel.name = "reload"
        addChild(reloadLabel)
        
        gameOverLabel = SKSpriteNode(imageNamed: "game-over")
        gameOverLabel.zPosition = 101
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.alpha = 0
        addChild(gameOverLabel)
    }
    
    @objc func startGame() {
        createAnimations()
        
        gameOverLabel.alpha = 0
        minute = 60
        shots = 3
        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        minute -= 1
        
        spawnEnemy()
        
        if minute == 0 {
            gameTimer?.invalidate()
            
            isGameOver.toggle()
            
            gameOverLabel.run(SKAction.fadeIn(withDuration: 1.5))
            
            run(SKAction.playSoundFileNamed("gameOver", waitForCompletion: false))
        }
    }
    
    func spawnEnemy() {
        guard !isGameOver else { return }
        
        if Int.random(in: 1...2) == 1 {
            let numLine = Int.random(in: 1...3)
            
            if numLine == 1 {
                createEnemy(y: 290, zPos: 5)
            }
            
            if numLine == 2 {
                createEnemy(y: 400, zPos: 3)
            }
            
            if numLine == 3 {
                createEnemy(y: 510, zPos: 1)
            }
        }
    }
    
    func createEnemy(y: Int, zPos: Int) {
        let randomTarget = Int.random(in: 0...3)
        
        if randomTarget == 0 {
            target = SKSpriteNode(imageNamed: "target0")
        } else if randomTarget == 1 {
            target = SKSpriteNode(imageNamed: "target1")
        } else if randomTarget == 2 {
            target = SKSpriteNode(imageNamed: "target2")
        } else if randomTarget == 3 {
            target = SKSpriteNode(imageNamed: "target3")
        } else {
            target = SKSpriteNode(imageNamed: "target0")
        }
        
        if randomTarget == 0 {
            target.name = "badTarget"
        } else if randomTarget == 3 {
            target.name = "goldTarget"
        } else {
            target.name = "goodTarget"
        }
        
        let moveTargetSlowOnLine = SKAction.moveTo(x: -200, duration: 3)
        let moveTargetFastOnLine = SKAction.moveTo(x: -200, duration: 2)
        
        if randomTarget == 3 {
            target.xScale = 0.7
            target.yScale = 0.7
            target.run(moveTargetFastOnLine)
            target.position = CGPoint(x: 960, y: CGFloat(y - 20))
        } else {
            target.run(moveTargetSlowOnLine)
            target.position = CGPoint(x: 960, y: y)
        }
        
        target.zPosition = CGFloat(zPos)
        
        addChild(target)
    }
    
    func createAnimations() {
        let moveLineForward = SKAction.moveTo(x: 562, duration: 0.8)
        let moveLineBackward = SKAction.moveTo(x: 472, duration: 0.8)
        
        let moveLineForeground = SKAction.sequence([moveLineForward, moveLineBackward])
        let moveLineForegroundForever = SKAction.repeatForever(moveLineForeground)
        waterFg.run(moveLineForegroundForever)
        
        let moveLineBackground = SKAction.sequence([moveLineBackward, moveLineForward])
        let moveLineBackgroundForever = SKAction.repeatForever(moveLineBackground)
        waterBg.run(moveLineBackgroundForever)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(where: { $0.name == "playGame" }) {
            startGame()
            isGameOver.toggle()
            return
        }
        
        if tappedNodes.contains(where: { $0.name == "reload" }) {
            run(SKAction.playSoundFileNamed("reload", waitForCompletion: false))
            shots = 3
        } else {
            if shots > 0 {
                run(SKAction.playSoundFileNamed("shot", waitForCompletion: false))
                shots -= 1
            } else {
                return
            }
        }
        
        for node in tappedNodes {
            if node.name == "badTarget" {
                node.removeAllActions()
                node.run(SKAction.fadeOut(withDuration: 0.3))
                
                if score > 0 {
                    score /= 2
                } else {
                    score -= 5000
                }
                
            } else if node.name == "goodTarget" {
                node.removeAllActions()
                node.run(SKAction.fadeOut(withDuration: 0.3))
                score += 100
            } else if node.name == "goldTarget" {
                node.removeAllActions()
                node.run(SKAction.fadeOut(withDuration: 0.3))
                if score > 0 {
                    score *= 5
                } else {
                    score += 1500
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -100 {
                node.removeFromParent()
            }
        }
    }
}
