import HealthKit

class HealthManager {
    private let healthStore = HKHealthStore()
    var heartRate: Double = 30.0
    let SIMULATION_MODE = true
    private var increasing = true

    func requestAuthorization() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!

        DispatchQueue.main.async {
            self.healthStore.requestAuthorization(toShare: [heartRateType], read: [heartRateType]) { success, error in
                if success {
                    print("✅ Autorisation HealthKit accordée !")
                    self.simulateHeartRateCycle()
                } else {
                    print("❌ Échec de la demande d'autorisation : \(error?.localizedDescription ?? "Erreur inconnue")")
                }
            }
        }
    }

    private func simulateHeartRateCycle() {
        let step = 90.0 / 15.0  // Progression sur 30 sec (15 étapes de montée et descente)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.increasing {
                self.heartRate += step
                if self.heartRate >= 120 {
                    self.increasing = false
                }
            } else {
                self.heartRate -= step
                if self.heartRate <= 30 {
                    self.increasing = true
                }
            }

            print("💓 Rythme cardiaque simulé : \(self.heartRate) BPM")
            NotificationCenter.default.post(name: NSNotification.Name("HeartRateUpdated"), object: nil, userInfo: ["heartRate": self.heartRate])
            self.simulateHeartRateCycle()
        }
    }
}

