import 'package:flutter/foundation.dart';
import '../../domain/entities/scheme.dart';
import '../../domain/usecases/scheme_usecases.dart';

/// ViewModel for managing schemes
class SchemeViewModel extends ChangeNotifier {
  final SyncSchemes _syncSchemes;
  final GetActiveSchemes _getActiveSchemes;
  
  List<Scheme> _schemes = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  
  SchemeViewModel({
    required SyncSchemes syncSchemes,
    required GetActiveSchemes getActiveSchemes,
  })  : _syncSchemes = syncSchemes,
        _getActiveSchemes = getActiveSchemes;
  
  List<Scheme> get schemes => _schemes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  /// Load schemes from local database
  Future<void> loadSchemes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _schemes = await _getActiveSchemes();
    } catch (e) {
      _errorMessage = 'Failed to load schemes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Sync schemes from remote server
  Future<void> syncSchemes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _syncSchemes();
      _lastSyncTime = DateTime.now();
      await loadSchemes(); // Reload after sync
    } catch (e) {
      _errorMessage = 'Failed to sync schemes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
