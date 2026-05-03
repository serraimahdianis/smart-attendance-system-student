import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<Attendance> _attendances = [];
  bool _isLoading = false;
  String? _error;

  List<Attendance> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final _api = ApiService();

  Future<void> loadAttendance({String? moduleId, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _attendances = await _api.getMyAttendance(
        moduleId: moduleId,
        status: status,
      );
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
