import SpriteKit
import GameplayKit
import HealthKit

class GameScene: SKScene {
    
    private var heartRateLabel: SKLabelNode!
    private var heartSprite: SKSpriteNode!
    private let healthManager = HealthManager()
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        print("✅ GameScene a bien été affichée")
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // Ajout du fond d'écran
        let bgTexture = SKTexture(imageNamed: "background")
        let background = SKSpriteNode(texture: bgTexture)
        background.size = self.size
        background.position = CGPoint.zero
        background.zPosition = -1
        addChild(background)

        // Ajout du cœur sous forme de sprite
        heartSprite = SKSpriteNode(imageNamed: "heart")  // Assurez-vous d'avoir "heart.png" dans Assets.xcassets
        heartSprite.position = CGPoint.zero
        heartSprite.zPosition = 1
        heartSprite.setScale(1.0)  // Taille initiale
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

        // Animation du battement du cœur
        let scaleFactor = CGFloat(1.0 + (heartRate - 60) / 50.0)  // Plus le BPM est haut, plus le cœur s’agrandit
        let beatSpeed = max(0.1, 1.5 - CGFloat((heartRate - 60) / 80.0))  // Ajustement de la vitesse des battements
        let beatAnimation = SKAction.sequence([
            SKAction.scale(to: scaleFactor, duration: Double(beatSpeed) / 2),
            SKAction.scale(to: 1.0, duration: Double(beatSpeed) / 2)
        ])
        heartSprite.run(beatAnimation)

        // Dégradé de couleur du vert au rouge
        let colorBlendFactor = min(1.0, (heartRate - 60) / 80.0)
        let newColor = UIColor(
            red: min(1, colorBlendFactor * 1.5),
            green: max(0, 1.5 - colorBlendFactor * 2),
            blue: max(0, 0.5 - abs(colorBlendFactor - 0.5)),
            alpha: 1.0
        )
        let colorizeAction = SKAction.colorize(with: newColor, colorBlendFactor: 1.0, duration: 0.2)
        heartSprite.run(colorizeAction)
    }
}
