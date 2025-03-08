import HealthKit

class HealthManager {
    private let healthStore = HKHealthStore()
    var heartRate: Double = 70.0
    let SIMULATION_MODE = true

    func requestAuthorization() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

        DispatchQueue.main.async {
            self.healthStore.requestAuthorization(toShare: [heartRateType], read: [heartRateType]) { success, error in
                if success {
                    print("✅ Autorisation HealthKit accordée !")
                    self.simulateHeartRate()
                } else {
                    print("❌ Échec de la demande d'autorisation : \(error?.localizedDescription ?? "Erreur inconnue")")
                }
            }
        }
    }

    private func simulateHeartRate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let variation = Double.random(in: -30...40) // Augmentation des variations
            let newHeartRate = max(60, min(150, self.heartRate + variation)) // Augmentation de la plage max
            self.heartRate = newHeartRate
            print("💓 Rythme cardiaque simulé : \(self.heartRate) BPM")
            NotificationCenter.default.post(name: NSNotification.Name("HeartRateUpdated"), object: nil, userInfo: ["heartRate": self.heartRate])
            self.simulateHeartRate()
        }
    }
}
