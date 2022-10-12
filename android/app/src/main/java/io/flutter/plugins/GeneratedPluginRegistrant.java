package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.github.contactlutforrahman.flutter_qr_bar_scanner.FlutterQrBarScannerPlugin;
import com.github.rmtmckenzie.nativedeviceorientation.NativeDeviceOrientationPlugin;
import io.flutter.plugins.urllauncher.UrlLauncherPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterQrBarScannerPlugin.registerWith(registry.registrarFor("com.github.contactlutforrahman.flutter_qr_bar_scanner.FlutterQrBarScannerPlugin"));
    NativeDeviceOrientationPlugin.registerWith(registry.registrarFor("com.github.rmtmckenzie.nativedeviceorientation.NativeDeviceOrientationPlugin"));
    UrlLauncherPlugin.registerWith(registry.registrarFor("io.flutter.plugins.urllauncher.UrlLauncherPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
