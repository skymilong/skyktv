import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

/// KTV应用主类
/// 
/// 定义应用的主题、路由和初始设置
class KTVApp extends StatelessWidget {
  const KTVApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KTV点歌系统',
      theme: appTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system, // 使用系统主题模式
      initialRoute: AppRoutes.main,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false, // 移除调试标签
    );

  }
}
