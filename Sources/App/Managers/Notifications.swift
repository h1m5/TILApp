
import PerfectNotifications

final class PushManager {
    
    let appId = "com.TriKomand.-43Scores"
    let apnsKeyId = "FRWU2X73ZK"
    let teamId = "QZ4VNA3J3V"
    let privateKeyFilePath = "./AuthKey_FRWU2X73ZK.p8"
    
    private init() {
        setup()
    }
    static let shared = PushManager()
    
    func setup() {
        NotificationPusher.addConfigurationAPNS(
            name: appId,
            production: false, // should be false when running pre-release app in debugger
            keyId: apnsKeyId,
            teamId: teamId,
            privateKeyPath: privateKeyFilePath)
        
        NotificationPusher.development = true
    }
    
    func push(to deviceIds:[String], title: String, body: String) {
        let n = NotificationPusher(apnsTopic: appId)
        n.pushAPNS(
            configurationName: appId,
            deviceTokens: deviceIds,
            notificationItems: [.alertTitle(title), .alertBody(body), .sound("default")]) {
                responses in
                print("\(responses)")
        }
    }
    
}
