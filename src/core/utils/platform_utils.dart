import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 平台工具类
/// 
/// 提供平台检测、设备信息获取等功能
class PlatformUtils {
  // 私有构造函数，防止实例化
  PlatformUtils._();
  
  /// 设备信息插件实例
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  
  /// 检查当前平台是否为移动平台（Android或iOS）
  /// 
  /// 返回是否为移动平台
  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }
  
  /// 检查当前平台是否为桌面平台（Windows、macOS或Linux）
  /// 
  /// 返回是否为桌面平台
  static bool isDesktop() {
    return !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  }
  
  /// 检查当前平台是否为Android
  /// 
  /// 返回是否为Android平台
  static bool isAndroid() {
    return !kIsWeb && Platform.isAndroid;
  }
  
  /// 检查当前平台是否为iOS
  /// 
  /// 返回是否为iOS平台
  static bool isIOS() {
    return !kIsWeb && Platform.isIOS;
  }
  
  /// 检查当前平台是否为Windows
  /// 
  /// 返回是否为Windows平台
  static bool isWindows() {
    return Platform.isWindows;
  }
  
  /// 检查当前平台是否为macOS
  /// 
  /// 返回是否为macOS平台
  static bool isMacOS() {
    return Platform.isMacOS;
  }
  
  /// 检查当前平台是否为Linux
  /// 
  /// 返回是否为Linux平台
  static bool isLinux() {
    return Platform.isLinux;
  }
  
  /// 检查当前平台是否为Web
  /// 
  /// 返回是否为Web平台
  static bool isWeb() {
    return kIsWeb;
  }
  
  /// 获取Android设备信息
  /// 
  /// 返回Android设备信息
  static Future<AndroidDeviceInfo> getAndroidDeviceInfo() async {
    return await _deviceInfoPlugin.androidInfo;
  }
  
  /// 获取iOS设备信息
  /// 
  /// 返回iOS设备信息
  static Future<IosDeviceInfo> getIOSDeviceInfo() async {
    return await _deviceInfoPlugin.iosInfo;
  }
  
  /// 获取Windows设备信息
  /// 
  /// 返回Windows设备信息
  static Future<WindowsDeviceInfo> getWindowsDeviceInfo() async {
    return await _deviceInfoPlugin.windowsInfo;
  }
  
  /// 获取macOS设备信息
  /// 
  /// 返回macOS设备信息
  static Future<MacOsDeviceInfo> getMacOSDeviceInfo() async {
    return await _deviceInfoPlugin.macOsInfo;
  }
  
  /// 获取Linux设备信息
  /// 
  /// 返回Linux设备信息
  static Future<LinuxDeviceInfo> getLinuxDeviceInfo() async {
    return await _deviceInfoPlugin.linuxInfo;
  }
  
  /// 获取设备信息
  /// 
  /// 返回设备信息Map
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        return {
          'platform': 'web',
          'browserName': webInfo.browserName.toString(),
          'userAgent': webInfo.userAgent ?? 'Unknown',
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await getAndroidDeviceInfo();
        return {
          'platform': 'android',
          'device': androidInfo.device,
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await getIOSDeviceInfo();
        return {
          'platform': 'ios',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await getWindowsDeviceInfo();
        return {
          'platform': 'windows',
          'computerName': windowsInfo.computerName,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
          'buildNumber': windowsInfo.buildNumber,
        };
      } else if (Platform.isMacOS) {
        final macOsInfo = await getMacOSDeviceInfo();
        return {
          'platform': 'macos',
          'computerName': macOsInfo.computerName,
          'hostName': macOsInfo.hostName,
          'arch': macOsInfo.arch,
          'model': macOsInfo.model,
          'osRelease': macOsInfo.osRelease,
        };
      } else if (Platform.isLinux) {
        final linuxInfo = await getLinuxDeviceInfo();
        return {
          'platform': 'linux',
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'id': linuxInfo.id,
        };
      }
      
      return {'platform': 'unknown'};
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {'platform': 'unknown', 'error': e.toString()};
    }
  }
  
  /// 检查Android版本是否低于指定版本
  /// 
  /// [version] 要比较的版本
  /// 
  /// 返回是否低于指定版本
  static Future<bool> isAndroidVersionLowerThan(int version) async {
    if (!isAndroid()) return false;
    
    try {
      final sdkInt = int.parse(Platform.operatingSystemVersion.split('.')[0]);
      return sdkInt < version;
    } catch (e) {
      debugPrint('Error checking Android version: $e');
      return false;
    }
  }
  
  /// 检查是否为Android电视设备
  /// 
  /// 返回是否为Android电视设备
  static Future<bool> isAndroidTV() async {
    if (!Platform.isAndroid) return false;
    
    final androidInfo = await getAndroidDeviceInfo();
    // 通常电视设备的特点是没有触摸屏，并且可能有特定的系统特性
    return !androidInfo.systemFeatures.contains('android.hardware.touchscreen') &&
           (androidInfo.systemFeatures.contains('android.software.leanback') ||
            androidInfo.systemFeatures.contains('android.hardware.type.television'));
  }
  
  /// 获取应用包信息
  /// 
  /// 返回应用包信息
  static Future<PackageInfo> getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }
  
  /// 获取应用版本
  /// 
  /// 返回应用版本字符串
  static Future<String> getAppVersion() async {
    final packageInfo = await getPackageInfo();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }
  
  /// 获取应用ID
  /// 
  /// 返回应用ID
  static Future<String> getAppId() async {
    final packageInfo = await getPackageInfo();
    return packageInfo.packageName;
  }
  
  /// 获取应用名称
  /// 
  /// 返回应用名称
  static Future<String> getAppName() async {
    final packageInfo = await getPackageInfo();
    return packageInfo.appName;
  }
  
  /// 获取平台名称
  static String getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
