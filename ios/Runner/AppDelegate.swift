import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private static let configChannel = "com.vgstv.radioapp/config"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: AppDelegate.configChannel,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "getYoutubeChannelId" {
          if let id = Bundle.main.object(forInfoDictionaryKey: "YoutubeChannelId") as? String,
             !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result(id.trimmingCharacters(in: .whitespacesAndNewlines))
          } else {
            result(
              FlutterError(
                code: "MISSING",
                message: "YoutubeChannelId em falta no Info.plist",
                details: nil
              )
            )
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return ok
  }
}
