import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _studentId;

  Future<String?> get token async {
    _token ??= await _storage.read(key: AppConstants.tokenKey);
    return _token;
  }

  Future<Map<String, String>> get _headers async {
    final t = await token;
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<void> saveStudentId(String studentId) async {
    _studentId = studentId;
  }

  Future<void> clearToken() async {
    _token = null;
    _studentId = null;
    await _storage.delete(key: AppConstants.tokenKey);
  }

  Future<bool> get isLoggedIn async {
    final t = await token;
    return t != null && t.isNotEmpty;
  }

  // ─── Auth ──────────────────────────────────────
  Future<Map<String, dynamic>> login(String studentId, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['token'] != null) {
      await saveToken(data['token']);
      if (data['student'] != null && data['student']['_id'] != null) {
        await saveStudentId(data['student']['_id']);
      }
      return {'success': true, 'student': data['student']};
    }
    return {'success': false, 'message': data['message'] ?? 'Login failed'};
  }

  Future<void> logout() async {
    await clearToken();
  }

  // ─── Student Profile ───────────────────────────
  Future<Student> getProfile() async {
    final studentId = _studentId;
    if (studentId == null) {
      throw Exception('Student ID not available');
    }
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.profileEndpoint}/$studentId'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      return Student.fromJson(jsonDecode(response.body)['student'] ?? jsonDecode(response.body));
    }
    throw Exception('Failed to load profile');
  }

  // ─── Attendance ────────────────────────────────────────
  Future<List<Attendance>> getMyAttendance({
    String? moduleId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final params = <String, String>{};
    if (moduleId != null) params['moduleId'] = moduleId;
    if (status != null) params['status'] = status;
    if (fromDate != null) params['from'] = fromDate.toIso8601String();
    if (toDate != null) params['to'] = toDate.toIso8601String();

    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.attendanceEndpoint}')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await http.get(uri, headers: await _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['attendances'] ?? data as List;
      return (list as List).map((e) => Attendance.fromJson(e)).toList();
    }
    throw Exception('Failed to load attendance');
  }

  // ─── Sessions ─────────────────────────────────────────
  Future<List<Session>> getMySessions({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;

    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.sessionsEndpoint}')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await http.get(uri, headers: await _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['sessions'] ?? data as List;
      return (list as List).map((e) => Session.fromJson(e)).toList();
    }
    throw Exception('Failed to load sessions');
  }

  Future<Session> getSessionById(String sessionId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.sessionByIdEndpoint}/$sessionId'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body)['session'] ?? jsonDecode(response.body));
    }
    throw Exception('Failed to load session');
  }

  // ─── Modules ──────────────────────────────────────────
  Future<List<Module>> getMyModules(String teacherId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.modulesEndpoint}/$teacherId'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['modules'] ?? data as List;
      return (list as List).map((e) => Module.fromJson(e)).toList();
    }
    throw Exception('Failed to load modules');
  }

  // ─── Attendance Scan ────────────────────────────────
  Future<Map<String, dynamic>> scanAttendance(String qrData) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.attendanceScanEndpoint}'),
      headers: await _headers,
      body: jsonEncode({'qrData': qrData}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'attendance': data['attendance']};
    }
    return {'success': false, 'message': data['message'] ?? 'Scan failed'};
  }
}
