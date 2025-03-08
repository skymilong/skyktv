import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/services/storage_service.dart';
import 'core/services/permission_service.dart';
import 'core/services/download_service.dart';
import 'core/services/player_service.dart';
import 'core/services/song_service.dart';
import 'core/services/playlist_service.dart';
import 'core/services/video_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  final storageService = StorageService();
  await storageService.init();
  
  final permissionService = PermissionService();
  final downloadService = DownloadService();
  final playerService = PlayerService();
  final songService = SongService();
  final playlistService = PlaylistService();
  final videoService = VideoService();

  // 错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => storageService),
        Provider<PermissionService>(create: (_) => permissionService),
        Provider<DownloadService>(create: (_) => downloadService),
        ChangeNotifierProvider<PlayerService>(create: (_) => playerService),
        ChangeNotifierProvider<SongService>(create: (_) => songService),
        ChangeNotifierProvider<PlaylistService>(create: (_) => playlistService),
        ChangeNotifierProvider<VideoService>(create: (_) => videoService),
      ],
      child: const KTVApp(),
    ),
  );
}
