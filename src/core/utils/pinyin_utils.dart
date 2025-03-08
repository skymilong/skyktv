import 'package:lpinyin/lpinyin.dart';

/// 拼音处理工具类
/// 
/// 提供中文转拼音、获取拼音首字母等功能
class PinyinUtils {
  // 私有构造函数，防止实例化
  PinyinUtils._();
  
  /// 将中文字符串转换为拼音
  /// 
  /// [text] 要转换的中文字符串
  /// [separator] 拼音之间的分隔符，默认为空字符串
  /// [format] 拼音格式，默认为小写
  /// 
  /// 返回转换后的拼音字符串
  static String toPinyin(
    String text, {
    String separator = '',
    PinyinFormat format = PinyinFormat.WITHOUT_TONE,
  }) {
    try {
      return PinyinHelper.getPinyin(
        text,
        separator: separator,
        format: format,
      );
    } catch (e) {
      // 如果转换失败，返回原始文本
      return text;
    }
  }
  
  /// 获取字符串中每个汉字的拼音首字母
  /// 
  /// [text] 要处理的字符串
  /// [uppercase] 是否转为大写，默认为true
  /// 
  /// 返回拼音首字母字符串
  static String getFirstLetters(String text, {bool uppercase = true}) {
    try {
      String result = PinyinHelper.getShortPinyin(text);
      return uppercase ? result.toUpperCase() : result;
    } catch (e) {
      // 如果转换失败，尝试获取第一个字符
      if (text.isNotEmpty) {
        String firstChar = text[0];
        // 如果是字母，直接返回
        if (RegExp(r'[a-zA-Z]').hasMatch(firstChar)) {
          return uppercase ? firstChar.toUpperCase() : firstChar.toLowerCase();
        }
        // 如果是数字或其他字符，返回#
        return '#';
      }
      return '#';
    }
  }
  
  /// 获取字符串的排序键（用于按拼音排序）
  /// 
  /// [text] 要处理的字符串
  /// 
  /// 返回用于排序的键
  static String getSortKey(String text) {
    // 先尝试获取拼音
    String pinyin = toPinyin(text, separator: '');
    
    // 如果拼音为空或等于原文本（转换失败），则进行二次处理
    if (pinyin.isEmpty || pinyin == text) {
      // 如果文本以字母开头，使用该字母作为排序键
      if (text.isNotEmpty && RegExp(r'[a-zA-Z]').hasMatch(text[0])) {
        return text[0].toUpperCase();
      }
      // 如果是数字或其他字符，返回Z后面的字符，确保排在最后
      return '{';
    }
    
    return pinyin;
  }
  
  /// 根据拼音首字母对字符串列表进行分组
  /// 
  /// [items] 要分组的字符串列表
  /// [textExtractor] 从列表项中提取文本的函数
  /// 
  /// 返回按拼音首字母分组的Map
  static Map<String, List<T>> groupByFirstLetter<T>(
    List<T> items,
    String Function(T item) textExtractor,
  ) {
    Map<String, List<T>> result = {};
    
    for (T item in items) {
      String text = textExtractor(item);
      String firstLetter = getFirstLetters(text)[0];
      
      // 如果不是字母，归类到#组
      if (!RegExp(r'[A-Z]').hasMatch(firstLetter)) {
        firstLetter = '#';
      }
      
      if (!result.containsKey(firstLetter)) {
        result[firstLetter] = [];
      }
      
      result[firstLetter]!.add(item);
    }
    
    return result;
  }
  
  /// 检查字符串是否包含中文字符
  /// 
  /// [text] 要检查的字符串
  /// 
  /// 返回是否包含中文字符
  static bool containsChinese(String text) {
    return RegExp(r'[\u4e00-\u9fa5]').hasMatch(text);
  }
}
