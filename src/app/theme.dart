import 'package:flutter/material.dart';

/// 应用亮色主题
final ThemeData appTheme = ThemeData(
  // 主色调
  primarySwatch: Colors.blue,
  primaryColor: const Color(0xFF2196F3),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2196F3),
    brightness: Brightness.light,
  ),
  
  // 文本主题
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFF212121),
    ),
    displayMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF212121),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFF424242),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF616161),
    ),
  ),
  
  // 按钮主题
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  
  // 卡片主题
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
  ),
  
  // 输入框主题
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  
  // 应用栏主题
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Color(0xFF2196F3),
    foregroundColor: Colors.white,
  ),
  
  // 底部导航栏主题
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFF2196F3),
    unselectedItemColor: Color(0xFF9E9E9E),
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),
  
  // 分割线主题
  dividerTheme: const DividerThemeData(
    space: 1,
    thickness: 1,
    color: Color(0xFFEEEEEE),
  ),
  
  // 使用Material 3
  useMaterial3: true,
);

/// 应用暗色主题
final ThemeData appDarkTheme = ThemeData(
  // 主色调
  primarySwatch: Colors.blue,
  primaryColor: const Color(0xFF2196F3),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2196F3),
    brightness: Brightness.dark,
  ),
  
  // 暗色背景
  scaffoldBackgroundColor: const Color(0xFF121212),
  
  // 文本主题
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Color(0xFFEEEEEE),
    ),
    displayMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFFEEEEEE),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFFBDBDBD),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF9E9E9E),
    ),
  ),
  
  // 按钮主题
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  
  // 卡片主题
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    clipBehavior: Clip.antiAlias,
    color: const Color(0xFF1E1E1E),
  ),
  
  // 输入框主题
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2C2C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  
  // 应用栏主题
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Color(0xFF1A1A1A),
    foregroundColor: Colors.white,
  ),
  
  // 底部导航栏主题
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1A1A1A),
    selectedItemColor: Color(0xFF2196F3),
    unselectedItemColor: Color(0xFF9E9E9E),
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),
  
  // 分割线主题
  dividerTheme: const DividerThemeData(
    space: 1,
    thickness: 1,
    color: Color(0xFF2C2C2C),
  ),
  
  // 使用Material 3
  useMaterial3: true,
);
