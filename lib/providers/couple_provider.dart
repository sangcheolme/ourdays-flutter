import 'package:flutter/foundation.dart';

import '../models/couple.dart';
import '../services/couple_service.dart';

class CoupleProvider with ChangeNotifier {
  final CoupleService _coupleService;
  
  Couple? _couple;
  String? _inviteCode;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  CoupleProvider(this._coupleService);
  
  Couple? get couple => _couple;
  String? get inviteCode => _inviteCode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get hasCouple => _couple != null && _couple!.status == CoupleStatus.ACTIVE;
  
  // Update provider state based on authentication
  void update(bool isAuthenticated, String? token) {
    if (isAuthenticated && token != null && !_isInitialized) {
      _fetchCoupleInfo();
    } else if (!isAuthenticated) {
      _couple = null;
      _inviteCode = null;
      _isInitialized = false;
      notifyListeners();
    }
  }
  
  // Fetch couple information
  Future<void> _fetchCoupleInfo() async {
    _setLoading(true);
    
    try {
      final couple = await _coupleService.getCurrentCouple();
      _couple = couple;
      _isInitialized = true;
      _error = null;
    } catch (e) {
      // It's okay if the user doesn't have a couple yet
      _couple = null;
      _isInitialized = true;
      debugPrint('No couple found or error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Create invite code
  Future<bool> createInviteCode(DateTime anniversaryDate) async {
    _setLoading(true);
    
    try {
      final response = await _coupleService.createInvite(anniversaryDate);
      _inviteCode = response['inviteCode'];
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to create invite code: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Accept invite
  Future<bool> acceptInvite(String inviteCode, DateTime anniversaryDate) async {
    _setLoading(true);

    try {
      final couple = await _coupleService.acceptInvite(inviteCode, anniversaryDate);
      _couple = couple;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to accept invite: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update couple
  Future<bool> updateCouple(DateTime anniversaryDate) async {
    _setLoading(true);
    
    try {
      final couple = await _coupleService.updateCouple(anniversaryDate);
      _couple = couple;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to update couple: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete couple
  Future<bool> deleteCouple() async {
    _setLoading(true);
    
    try {
      await _coupleService.deleteCouple();
      _couple = null;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to delete couple: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Refresh couple information
  Future<void> refreshCouple() async {
    await _fetchCoupleInfo();
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Get days since anniversary
  int get daysSinceAnniversary {
    if (_couple == null) return 0;
    return _couple!.daysSinceAnniversary;
  }
  
  // Get days until next anniversary
  int get daysUntilNextAnniversary {
    if (_couple == null) return 0;
    return _couple!.daysUntilNextAnniversary;
  }
  
  // Get next anniversary date
  DateTime? get nextAnniversaryDate {
    if (_couple == null) return null;
    return _couple!.nextAnniversaryDate;
  }
}