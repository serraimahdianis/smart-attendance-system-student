// ─── Student Model ───────────────────────────────────────────────
class Student {
  final String id;
  final String fullName;
  final String email;
  final String studentId;
  final String rfidCode;
  final String qrCode;
  final String? faceImage;
  final String group;
  final String year;
  final String speciality;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.rfidCode,
    required this.qrCode,
    this.faceImage,
    required this.group,
    required this.year,
    required this.speciality,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      studentId: json['studentId'] ?? '',
      rfidCode: json['rfidCode'] ?? '',
      qrCode: json['qrCode'] ?? '',
      faceImage: json['faceImage'],
      group: json['group'] ?? '',
      year: json['year'] ?? '',
      speciality: json['speciality'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'fullName': fullName,
    'email': email,
    'studentId': studentId,
    'rfidCode': rfidCode,
    'qrCode': qrCode,
    'faceImage': faceImage,
    'group': group,
    'year': year,
    'speciality': speciality,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ─── Module Model ────────────────────────────────────────────────
class Module {
  final String id;
  final String name;
  final String teacherId;
  final String? teacherName;
  final String year;
  final DateTime createdAt;

  Module({
    required this.id,
    required this.name,
    required this.teacherId,
    this.teacherName,
    required this.year,
    required this.createdAt,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      teacherId: json['teacherId'] is Map ? json['teacherId']['_id'] : json['teacherId'] ?? '',
      teacherName: json['teacherId'] is Map ? json['teacherId']['fullName'] : null,
      year: json['year'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ─── Session Model ────────────────────────────────────────────────
class Session {
  final String id;
  final String? scheduleId;
  final String teacherId;
  final String? teacherName;
  final String moduleId;
  final String? moduleName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String type; // cours | td | tp
  final String group;
  final String status; // planned | active | closed
  final bool isReplacement;
  final String? reasonForReplacement;
  final String? room;

  Session({
    required this.id,
    this.scheduleId,
    required this.teacherId,
    this.teacherName,
    required this.moduleId,
    this.moduleName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.group,
    required this.status,
    required this.isReplacement,
    this.reasonForReplacement,
    this.room,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['_id'] ?? '',
      scheduleId: json['scheduleId'],
      teacherId: json['teacherId'] is Map ? json['teacherId']['_id'] : json['teacherId'] ?? '',
      teacherName: json['teacherId'] is Map ? json['teacherId']['fullName'] : null,
      moduleId: json['moduleId'] is Map ? json['moduleId']['_id'] : json['moduleId'] ?? '',
      moduleName: json['moduleId'] is Map ? json['moduleId']['name'] : null,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      type: json['type'] ?? 'cours',
      group: json['group'] ?? '',
      status: json['status'] ?? 'planned',
      isReplacement: json['isReplacement'] ?? false,
      reasonForReplacement: json['reasonForReplacement'],
      room: json['room'],
    );
  }

  bool get isActive => status == 'active';
  bool get isUpcoming => status == 'planned';
  bool get isClosed => status == 'closed';
  
  String get typeLabel => type.toUpperCase();
  
  String get formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ─── Attendance Model ─────────────────────────────────────────────
class Attendance {
  final String id;
  final String sessionId;
  final Session? session;
  final String studentId;
  final String status; // present | late | absent
  final DateTime scanTime;

  Attendance({
    required this.id,
    required this.sessionId,
    this.session,
    required this.studentId,
    required this.status,
    required this.scanTime,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['_id'] ?? '',
      sessionId: json['sessionId'] is Map ? json['sessionId']['_id'] : json['sessionId'] ?? '',
      session: json['sessionId'] is Map ? Session.fromJson(json['sessionId']) : null,
      studentId: json['studentId'] is Map ? json['studentId']['_id'] : json['studentId'] ?? '',
      status: json['status'] ?? 'absent',
      scanTime: DateTime.tryParse(json['scanTime'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isPresent => status == 'present';
  bool get isLate => status == 'late';
  bool get isAbsent => status == 'absent';
}

// ─── Module Attendance Stats ───────────────────────────────────────
class ModuleAttendanceStats {
  final Module module;
  final int totalSessions;
  final int present;
  final int absent;
  final int late;
  final bool isExcluded;
  final double attendanceRate;

  ModuleAttendanceStats({
    required this.module,
    required this.totalSessions,
    required this.present,
    required this.absent,
    required this.late,
    required this.isExcluded,
    required this.attendanceRate,
  });

  factory ModuleAttendanceStats.fromJson(Map<String, dynamic> json) {
    return ModuleAttendanceStats(
      module: Module.fromJson(json['module']),
      totalSessions: json['totalSessions'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      late: json['late'] ?? 0,
      isExcluded: json['isExcluded'] ?? false,
      attendanceRate: (json['attendanceRate'] ?? 0).toDouble(),
    );
  }
}

// ─── Dashboard Data ────────────────────────────────────────────────
class DashboardData {
  final double attendanceRate;
  final int totalPresent;
  final int totalAbsent;
  final int totalLate;
  final int totalSessions;
  final Session? nextSession;
  final List<ModuleAttendanceStats> moduleStats;
  final List<Map<String, dynamic>> weeklyData;

  DashboardData({
    required this.attendanceRate,
    required this.totalPresent,
    required this.totalAbsent,
    required this.totalLate,
    required this.totalSessions,
    this.nextSession,
    required this.moduleStats,
    required this.weeklyData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      attendanceRate: (json['attendanceRate'] ?? 0).toDouble(),
      totalPresent: json['totalPresent'] ?? 0,
      totalAbsent: json['totalAbsent'] ?? 0,
      totalLate: json['totalLate'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      nextSession: json['nextSession'] != null ? Session.fromJson(json['nextSession']) : null,
      moduleStats: (json['moduleStats'] as List? ?? [])
          .map((e) => ModuleAttendanceStats.fromJson(e))
          .toList(),
      weeklyData: List<Map<String, dynamic>>.from(json['weeklyData'] ?? []),
    );
  }
}

// ─── Notification Model ────────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
