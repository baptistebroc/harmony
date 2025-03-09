import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var heartRateLabel: SKLabelNode!
    private var heartSprite: SKSpriteNode!
    private let healthManager = HealthManager()
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        print("✅ GameScene affichée")
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // Ajout du fond d'écran
        let bgTexture = SKTexture(imageNamed: "background")
        let background = SKSpriteNode(texture: bgTexture)
        background.size = self.size
        background.position = CGPoint.zero
        background.zPosition = -1
        addChild(background)

        // Ajout du cœur sous forme de sprite (taille réduite)
        heartSprite = SKSpriteNode(imageNamed: "heart")
        heartSprite.position = CGPoint.zero
        heartSprite.zPosition = 1
        heartSprite.setScale(0.33)  // Taille trois fois plus petite
        addChild(heartSprite)

        // Label affichant le BPM
        heartRateLabel = SKLabelNode(fontNamed: "Arial")
        heartRateLabel.fontSize = 24
        heartRateLabel.fontColor = .white
        heartRateLabel.position = CGPoint(x: 0, y: size.height / 2 - 50)
        heartRateLabel.text = "Fréquence cardiaque : -- BPM"
        heartRateLabel.zPosition = 2
        addChild(heartRateLabel)

        // Lancer la détection du rythme cardiaque
        healthManager.requestAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(updateWorld), name: NSNotification.Name("HeartRateUpdated"), object: nil)
    }

    @objc func updateWorld(notification: Notification) {
        let heartRate = notification.userInfo?["heartRate"] as? Double ?? 80.0
        print("💓 Mise à jour : \(heartRate) BPM")
        heartRateLabel.text = "Fréquence cardiaque : \(Int(heartRate)) BPM"

        // Calage du battement en mode "papoum papoum"
        let beatSpeed = max(0.1, 60.0 / CGFloat(heartRate))  // Temps d'un battement basé sur les BPM
        let pauseTime = beatSpeed * 0.4 // Petite pause après les deux battements

        let papoumAnimation = SKAction.sequence([
            SKAction.scale(to: 0.38, duration: Double(beatSpeed) / 3),  // Papoum 1
            SKAction.scale(to: 0.33, duration: Double(beatSpeed) / 6),
            SKAction.scale(to: 0.36, duration: Double(beatSpeed) / 4),  // Papoum 2
            SKAction.scale(to: 0.33, duration: Double(beatSpeed) / 6),
            SKAction.wait(forDuration: Double(pauseTime))  // Pause entre les cycles
        ])
        
        heartSprite.run(papoumAnimation)

        // Dégradé de couleur : Rose clair (30 BPM) → Rouge foncé (120 BPM)
        let blendFactor = min(1.0, (heartRate - 30) / 90.0)
        
        let red = 1.0 - (0.3 * blendFactor)  // Passe de 1.0 à 0.7
        let green = 0.7 * (1.0 - blendFactor)  // Passe de 0.7 à 0.0
        let blue = 0.8 - (0.8 * blendFactor)  // Passe de 0.8 à 0.0

        let newColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
        let colorizeAction = SKAction.colorize(with: newColor, colorBlendFactor: 1.0, duration: 0.2)
        heartSprite.run(colorizeAction)
    }
}

