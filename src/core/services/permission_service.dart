import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/platform_utils.dart';

/// 权限服务
/// 
/// 管理应用所需的各种权限
class PermissionService {
  // 单例实例
  static final PermissionService _instance = PermissionService._internal();
  
  // 工厂构造函数
  factory PermissionService() => _instance;
  
  // 私有构造函数
  PermissionService._internal();
  
  /// 请求存储权限
  /// 
  /// 返回是否获得权限
  Future<bool> requestStoragePermission() async {
    // 在Web平台上不需要存储权限
    if (kIsWeb) return true;
    
    // 在iOS上不需要显式请求存储权限
    if (PlatformUtils.isIOS()) return true;
    
    // 在Android上请求存储权限
    if (PlatformUtils.isAndroid()) {
      // 对于Android 13及以上，需要请求特定的媒体权限
      if (await PlatformUtils.isAndroidVersionLowerThan(33)) {
        // Android 12及以下，请求传统存储权限
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        // Android 13+，请求特定媒体权限
        final audio = await Permission.audio.request();
        return audio.isGranted;
      }
    }
    
    // 在桌面平台上通常不需要显式权限
    return true;
  }
  
  /// 检查存储权限状态
  /// 
  /// 返回权限状态
  Future<PermissionStatus> checkStoragePermission() async {
    if (kIsWeb) return PermissionStatus.granted;
    if (PlatformUtils.isIOS()) return PermissionStatus.granted;
    
    if (PlatformUtils.isAndroid()) {
      if (await PlatformUtils.isAndroidVersionLowerThan(33)) {
        return await Permission.storage.status;
      } else {
        return await Permission.audio.status;
      }
    }
    
    return PermissionStatus.granted;
  }
  
  /// 请求麦克风权限（用于录音功能）
  /// 
  /// 返回是否获得权限
  Future<bool> requestMicrophonePermission() async {
    if (kIsWeb) {
      // Web平台上，权限请求会在使用时由浏览器处理
      return true;
    }
    
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  /// 检查麦克风权限状态
  /// 
  /// 返回权限状态
  Future<PermissionStatus> checkMicrophonePermission() async {
    return await Permission.microphone.status;
  }
  
  /// 请求通知权限
  /// 
  /// 返回是否获得权限
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  
  /// 检查通知权限状态
  /// 
  /// 返回权限状态
  Future<PermissionStatus> checkNotificationPermission() async {
    return await Permission.notification.status;
  }
  
  /// 打开应用设置
  /// 
  /// 返回是否成功打开设置
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
  
  /// 检查是否需要显示权限说明
  /// 
  /// [permission] 权限类型
  /// 
  /// 返回是否需要显示说明
  Future<bool> shouldShowRequestRationale(Permission permission) async {
    if (kIsWeb) return false;
    if (PlatformUtils.isIOS()) return false;
    
    if (PlatformUtils.isAndroid()) {
      return await permission.shouldShowRequestRationale;
    }
    
    return false;
  }
  
  /// 请求多个权限
  /// 
  /// [permissions] 权限列表
  /// 
  /// 返回每个权限的状态映射表
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions
  ) async {
    return await permissions.request();
  }
}
