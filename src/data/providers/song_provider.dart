import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../repositories/song_repository.dart';
import '../../core/constants/enum_types.dart';

/// 歌曲数据提供者
/// 
/// 为UI层提供歌曲数据，管理歌曲状态
class SongProvider extends ChangeNotifier {
  final SongRepository _repository;
  
  /// 所有歌曲
  List<Song> _songs = [];
  
  /// 当前过滤的歌曲
  List<Song> _filteredSongs = [];
  
  /// 当前搜索结果
  List<Song> _searchResults = [];
  
  /// 当前选中的歌曲
  Song? _selectedSong;
  
  /// 当前选中的类别
  String _selectedCategory = '全部';
  
  /// 当前排序方式
  SortOrder _sortOrder = SortOrder.byName;
  
  /// 是否正在加载
  bool _isLoading = false;
  
  /// 是否正在搜索
  bool _isSearching = false;
  
  /// 搜索查询
  String _searchQuery = '';
  
  /// 所有可用类别
  List<String> _categories = ['全部'];
  
  /// 构造函数
  SongProvider(this._repository) {
    _loadSongs();
    _loadCategories();
  }
  
  /// 获取所有歌曲
  List<Song> get songs => _songs;
  
  /// 获取过滤后的歌曲
  List<Song> get filteredSongs => _filteredSongs;
  
  /// 获取搜索结果
  List<Song> get searchResults => _searchResults;
  
  /// 获取当前选中的歌曲
  Song? get selectedSong => _selectedSong;
  
  /// 获取当前选中的类别
  String get selectedCategory => _selectedCategory;
  
  /// 获取当前排序方式
  SortOrder get sortOrder => _sortOrder;
  
  /// 获取是否正在加载
  bool get isLoading => _isLoading;
  
  /// 获取是否正在搜索
  bool get isSearching => _isSearching;
  
  /// 获取搜索查询
  String get searchQuery => _searchQuery;
  
  /// 获取所有可用类别
  List<String> get categories => _categories;
  
  /// 加载所有歌曲
  Future<void> _loadSongs() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _songs = await _repository.getAllSongs();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading songs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 加载所有类别
  Future<void> _loadCategories() async {
    try {
      _categories = await _repository.getAllCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }
  
  /// 应用过滤器
  void _applyFilters() {
    if (_isSearching && _searchQuery.isNotEmpty) {
      // 如果正在搜索，使用搜索结果
      _filteredSongs = _searchResults;
    } else if (_selectedCategory != '全部') {
      // 如果选择了特定类别，过滤歌曲
      _filteredSongs = _songs.where((song) {
        return song.categories.contains(_selectedCategory);
      }).toList();
    } else {
      // 否则使用所有歌曲
      _filteredSongs = List.from(_songs);
    }
    
    // 应用排序
    _applySorting();
  }
  
  /// 应用排序
  void _applySorting() {
    switch (_sortOrder) {
      case SortOrder.byName:
        _filteredSongs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOrder.byArtist:
        _filteredSongs.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case SortOrder.byAddedDate:
        _filteredSongs.sort((a, b) => b.addedDate.compareTo(a.addedDate));
        break;
      case SortOrder.byPopularity:
        _filteredSongs.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
    }
  }
  
  /// 搜索歌曲
  Future<void> searchSongs(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _isSearching = false;
      _searchResults = [];
      _applyFilters();
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    notifyListeners();
    
    try {
      _searchResults = await _repository.searchSongs(query);
      _applyFilters();
    } catch (e) {
      debugPrint('Error searching songs: $e');
    } finally {
      notifyListeners();
    }
  }
  
  /// 清除搜索
  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _searchResults = [];
    _applyFilters();
    notifyListeners();
  }
  
  /// 选择歌曲
  void selectSong(Song song) {
    _selectedSong = song;
    notifyListeners();
  }
  
  /// 清除选中的歌曲
  void clearSelectedSong() {
    _selectedSong = null;
    notifyListeners();
  }
  
  /// 选择类别
  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }
  
  /// 设置排序方式
  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    _applyFilters();
    notifyListeners();
  }
  
  /// 获取歌曲详情
  Future<Song?> getSongById(String id) async {
    return await _repository.getSongById(id);
  }
  
  /// 更新歌曲下载状态
  Future<void> updateSongDownloadStatus(
    String songId, 
    bool isDownloaded, 
    String? localPath,
    DownloadStatus status,
  ) async {
    await _repository.updateSongDownloadStatus(
      songId, 
      isDownloaded, 
      localPath,
      status,
    );
    
    // 更新本地列表
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index != -1) {
      _songs[index] = _songs[index].copyWith(
        isDownloaded: isDownloaded,
        localPath: localPath,
        downloadStatus: status,
      );
      
      // 如果是当前选中的歌曲，也更新它
      if (_selectedSong?.id == songId) {
        _selectedSong = _songs[index];
      }
      
      _applyFilters();
      notifyListeners();
    }
  }
  
  /// 更新歌曲收藏状态
  Future<void> updateSongFavoriteStatus(String songId, bool isFavorite) async {
    await _repository.updateSongFavoriteStatus(songId, isFavorite);
    
    // 更新本地列表
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index != -1) {
      _songs[index] = _songs[index].copyWith(isFavorite: isFavorite);
      
      // 如果是当前选中的歌曲，也更新它
      if (_selectedSong?.id == songId) {
        _selectedSong = _songs[index];
      }
      
      _applyFilters();
      notifyListeners();
    }
  }
  
  /// 获取收藏的歌曲
  Future<List<Song>> getFavoriteSongs() async {
    return await _repository.getFavoriteSongs();
  }
  
  /// 获取已下载的歌曲
  Future<List<Song>> getDownloadedSongs() async {
    return await _repository.getDownloadedSongs();
  }
  
  /// 按字母获取歌曲
  Future<List<Song>> getSongsByFirstLetter(String letter) async {
    return await _repository.getSongsByFirstLetter(letter);
  }
  
  /// 刷新数据
  Future<void> refresh() async {
    await _loadSongs();
    await _loadCategories();
  }
}
