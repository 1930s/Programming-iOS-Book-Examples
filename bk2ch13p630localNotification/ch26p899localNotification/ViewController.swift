

import UIKit

class ViewController: UIViewController {
    
    let categoryIdentifier = "coffee"

    @IBAction func doButton(_ sender: Any) {
        self.registerMyNotification()
    }
    
    func registerMyNotification() {
        print("checking for notification permissions")
        if let settings = UIApplication.shared.currentUserNotificationSettings() {
            if let cats = settings.categories {
                for cat in cats {
                    if cat.identifier == self.categoryIdentifier { // we are already registered
                        self.createLocalNotification()
                        return
                    }
                }
            }
        }
        
        let types : UIUserNotificationType = [.alert, .sound]
        // if we want custom actions in our alert, we must create them when we register
        let category = UIMutableUserNotificationCategory()
        category.identifier = self.categoryIdentifier // will need this at notification creation time!
        let action1 = UIMutableUserNotificationAction()
        action1.identifier = "yum"
        action1.title = "Yum" // user will see this
        action1.isDestructive = false // the default, I'm just setting it to call attention to its existence
        action1.activationMode = .foreground // if .Background, app just stays in the background! cool
        // if .Background, should also set authenticationRequired to say what to do from lock screen
        
        let action2 = UIMutableUserNotificationAction()
        var which : Int {return 2} // try 1 and 2
        switch which {
        case 1:
            action2.identifier = "ohno"
            action2.title = "Oh, No!" // user will see this
            action2.isDestructive = false // the default, I'm just setting it to call attention to its existence
            action2.activationMode = .background // if .Background, app just stays in the background! cool
            // if .Background, should also set authenticationRequired to say what to do from lock screen
        case 2:
            action2.identifier = "message"
            action2.title = "Message"
            action2.activationMode = .background
            action2.behavior = .textInput // new in iOS 9!
        default: break
        }
        
        category.setActions([action1, action2], for: .default) // can have 4 for default, 2 for minimal
        let settings = UIUserNotificationSettings(types: types, categories: [category])
        // prepare to proceed to next step
        var ob : NSObjectProtocol! = nil
        ob = NotificationCenter.default.addObserver(forName: "didRegisterUserNotificationSettings" as Notification.Name, object: nil, queue: nil) {
            _ in
            NotificationCenter.default.removeObserver(ob)
            self.createLocalNotification()
        }
        UIApplication.shared.registerUserNotificationSettings(settings)
        // if this app has never requested this registration,
        // it will put up a dialog asking if we can present alerts etc.
        // when the user accepts or refuses,
        // will cause us to receive application:didRegisterUserNotificationSettings:
        // can also check at any time with currentUserNotificationSettings
        
        // unfortunately if the user accepts, the default is banner, not alert :(
        print("end of registerMyNotification")
    }
    
    func createLocalNotification() {
        
        print("creating local notification")
        let ln = UILocalNotification()
        // ln.alertTitle = "Caffeine!" // I see; it's for the Apple Watch
        ln.alertBody = "Time for another cup of coffee!"
        ln.category = self.categoryIdentifier // causes Options button to spring magically to life in alert
        // Options button will offer Open, action buttons, Close
        ln.fireDate = NSDate(timeIntervalSinceNow:15) as Date
        ln.soundName = UILocalNotificationDefaultSoundName
        // ln.repeatInterval = .Minute
        UIApplication.shared.scheduleLocalNotification(ln)
    }
    /*
    If user has denied alerts/sounds, trying to schedule the above notification...
    ...will log in the console for each of those, but no harm done
    */
    
}
