import WebKit

class SubscribeMessage {
    var topic = ""
    var eventValue = ""
    var unsubscribe = false

    struct Keys {
        static var TOPIC = "topic"
        static var UNSUBSCRIBE = "unsubscribe"
        static var EVENTVALUE = "eventValue"
    }

    convenience init(dict: Dictionary<String, Any>) {
        self.init()
        if let topic = dict[Keys.TOPIC] as? String {
            self.topic = topic
        }
        if let unsubscribe = dict[Keys.UNSUBSCRIBE] as? Bool {
            self.unsubscribe = unsubscribe
        }
        if let eventValue = dict[Keys.EVENTVALUE] as? String {
            self.eventValue = eventValue
        }
    }
}

func handleSubscribeTouch(message: WKScriptMessage) {
    _ = parseSubscribeMessage(message: message)
}

func parseSubscribeMessage(message: WKScriptMessage) -> [SubscribeMessage] {
    var subscribeMessages = [SubscribeMessage]()
    if let objStr = message.body as? String {
        let data: Data = objStr.data(using: .utf8)!
        do {
            let jsObj = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))
            if let jsonObjDict = jsObj as? Dictionary<String, Any> {
                subscribeMessages.append(SubscribeMessage(dict: jsonObjDict))
            } else if let jsonArr = jsObj as? [Dictionary<String, Any>] {
                for jsonObj in jsonArr {
                    subscribeMessages.append(SubscribeMessage(dict: jsonObj))
                }
            }
        } catch {
        }
    }
    return subscribeMessages
}

func returnPermissionResult(isGranted: Bool) {
    DispatchQueue.main.async {
        let detail = isGranted ? "granted" : "denied"
        LYYildirimlar.webView.evaluateJavaScript(
            "this.dispatchEvent(new CustomEvent('push-permission-request', { detail: '\(detail)' }))"
        )
    }
}

func returnPermissionState(state: String) {
    DispatchQueue.main.async {
        LYYildirimlar.webView.evaluateJavaScript(
            "this.dispatchEvent(new CustomEvent('push-permission-state', { detail: '\(state)' }))"
        )
    }
}

func handlePushPermission() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .notDetermined:
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
                returnPermissionResult(isGranted: success)
            }
        case .denied:
            returnPermissionResult(isGranted: false)
        case .authorized, .ephemeral, .provisional:
            returnPermissionResult(isGranted: true)
        @unknown default:
            return
        }
    }
}

func handlePushState() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .notDetermined:
            returnPermissionState(state: "notDetermined")
        case .denied:
            returnPermissionState(state: "denied")
        case .authorized:
            returnPermissionState(state: "authorized")
        case .ephemeral:
            returnPermissionState(state: "ephemeral")
        case .provisional:
            returnPermissionState(state: "provisional")
        @unknown default:
            returnPermissionState(state: "unknown")
        }
    }
}

func checkViewAndEvaluate(event: String, detail: String) {
    if !LYYildirimlar.webView.isHidden && !LYYildirimlar.webView.isLoading {
        DispatchQueue.main.async {
            LYYildirimlar.webView.evaluateJavaScript(
                "this.dispatchEvent(new CustomEvent('\(event)', { detail: \(detail) }))"
            )
        }
    } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            checkViewAndEvaluate(event: event, detail: detail)
        }
    }
}

func handleFCMToken() {
    checkViewAndEvaluate(event: "push-token", detail: "''")
}

func sendPushToWebView(userInfo: [AnyHashable: Any]) {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: userInfo)
        guard let json = String(data: jsonData, encoding: .utf8) else { return }
        checkViewAndEvaluate(event: "push-notification", detail: json)
    } catch {
    }
}

func sendPushClickToWebView(userInfo: [AnyHashable: Any]) {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: userInfo)
        guard let json = String(data: jsonData, encoding: .utf8) else { return }
        checkViewAndEvaluate(event: "push-notification-click", detail: json)
    } catch {
    }
}
