import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<Attendance> _history = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;

  List<Attendance> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;

  final _api = ApiService();

  Future<void> loadHistory({String? status, bool silent = false}) async {
    _selectedStatus = status;
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _history = await _api.getMyAttendance(status: _selectedStatus);
      _error = null;
    } catch (e) {
      _error = 'Failed to load attendance history';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatus(String? status) {
    if (_selectedStatus == status) return;
    loadHistory(status: status);
  }

  Future<void> refresh() => loadHistory(status: _selectedStatus, silent: true);
}
