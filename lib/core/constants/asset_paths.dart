/// 资源路径常量
/// 
/// 定义应用中使用的所有资源文件路径
class AssetPaths {
  // 私有构造函数，防止实例化
  AssetPaths._();
  
  // 图片资源
  static const String imagesPath = 'assets/images';
  static const String logoPath = '$imagesPath/logo.png';
  static const String backgroundPath = '$imagesPath/background.jpg';
  static const String placeholderCoverPath = '$imagesPath/placeholder_cover.png';
  static const String placeholderArtistPath = '$imagesPath/placeholder_artist.png';
  static const String noResultsPath = '$imagesPath/no_results.png';
  static const String errorPath = '$imagesPath/error.png';
  static const String emptyPlaylistPath = '$imagesPath/empty_playlist.png';
  
  // 图标资源
  static const String iconsPath = 'assets/icons';
  static const String playIconPath = '$iconsPath/play.svg';
  static const String pauseIconPath = '$iconsPath/pause.svg';
  static const String skipNextIconPath = '$iconsPath/skip_next.svg';
  static const String skipPreviousIconPath = '$iconsPath/skip_previous.svg';
  static const String volumeIconPath = '$iconsPath/volume.svg';
  static const String muteIconPath = '$iconsPath/mute.svg';
  static const String karaokeIconPath = '$iconsPath/karaoke.svg';
  static const String downloadIconPath = '$iconsPath/download.svg';
  static const String searchIconPath = '$iconsPath/search.svg';
  static const String settingsIconPath = '$iconsPath/settings.svg';
  static const String favoriteIconPath = '$iconsPath/favorite.svg';
  static const String favoriteBorderIconPath = '$iconsPath/favorite_border.svg';
  static const String playlistAddIconPath = '$iconsPath/playlist_add.svg';
  static const String syncIconPath = '$iconsPath/sync.svg';
  
  // 动画资源
  static const String animationsPath = 'assets/animations';
  static const String loadingAnimationPath = '$animationsPath/loading.json';
  static const String successAnimationPath = '$animationsPath/success.json';
  static const String errorAnimationPath = '$animationsPath/error.json';
  static const String emptyAnimationPath = '$animationsPath/empty.json';
  static const String musicPlayingAnimationPath = '$animationsPath/music_playing.json';
  
  // 音效资源
  static const String soundsPath = 'assets/sounds';
  static const String buttonClickSoundPath = '$soundsPath/button_click.mp3';
  static const String notificationSoundPath = '$soundsPath/notification.mp3';
  static const String successSoundPath = '$soundsPath/success.mp3';
  static const String errorSoundPath = '$soundsPath/error.mp3';
  
  // 字体资源
  static const String fontsPath = 'assets/fonts';
  
  // 测试数据资源
  static const String dataPath = 'assets/data';
  static const String testSongsPath = '$dataPath/test_songs.json';
  static const String testPlaylistsPath = '$dataPath/test_playlists.json';
}
