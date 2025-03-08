import 'package:flutter/material.dart';
import '../features/main_screen/screens/main_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/song_library/screens/song_detail_screen.dart';
import '../features/song_library/screens/song_library_screen.dart';
import '../features/player/screens/player_screen.dart';
import '../features/search/screens/search_screen.dart';

/// 应用路由管理
/// 
/// 定义应用的所有路由和导航逻辑
class AppRoutes {
  // 路由名称常量
  static const String main = '/';
  static const String settings = '/settings';
  static const String songLibrary = '/song-library';
  static const String songDetail = '/song-detail';
  static const String player = '/player';
  static const String search = '/search';

  // 路由生成器
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case songLibrary:
        return MaterialPageRoute(builder: (_) => const SongLibraryScreen());
      case songDetail:
        final songId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SongDetailScreen(songId: songId),
        );
      case player:
        final songId = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => PlayerScreen(initialSongId: songId),
        );
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      default:
        // 未知路由返回错误页面
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('找不到路由: ${routeSettings.name}'),
            ),
          ),
        );
    }
  }

  // 导航到设置页面
  static Future<void> navigateToSettings(BuildContext context) {
    return Navigator.pushNamed(context, settings);
  }

  // 导航到歌曲详情页面
  static Future<void> navigateToSongDetail(BuildContext context, String songId) {
    return Navigator.pushNamed(
      context,
      songDetail,
      arguments: songId,
    );
  }

  // 导航到播放器页面
  static Future<void> navigateToPlayer(BuildContext context, {String? songId}) {
    return Navigator.pushNamed(
      context,
      player,
      arguments: songId,
    );
  }

  // 导航到搜索页面
  static Future<void> navigateToSearch(BuildContext context) {
    return Navigator.pushNamed(context, search);
  }
}
