import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CalendarHomeWidgets") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "dev.ahmedzaeem.horizontal_weekly_calendar/home_widgets",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "update":
        guard
          let payload = call.arguments as? [String: Any],
          JSONSerialization.isValidJSONObject(payload),
          let data = try? JSONSerialization.data(withJSONObject: payload),
          let encoded = String(data: data, encoding: .utf8)
        else {
          result(FlutterError(code: "invalid_payload", message: "Expected a calendar widget map.", details: nil))
          return
        }
        UserDefaults(suiteName: CalendarWidgetContract.appGroup)?
          .set(encoded, forKey: CalendarWidgetContract.payloadKey)
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadTimelines(ofKind: CalendarWidgetContract.kind)
        }
        result(true)
      case "refresh":
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadTimelines(ofKind: CalendarWidgetContract.kind)
        }
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

private enum CalendarWidgetContract {
  static let appGroup = "group.com.ahmedzaeem.horizontalWeeklyCalendarExample"
  static let payloadKey = "calendar_widget_payload"
  static let kind = "HorizontalWeeklyCalendarWidget"
}
