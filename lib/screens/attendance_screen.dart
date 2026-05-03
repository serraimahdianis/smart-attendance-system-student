import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Attendance> _history = [];
  bool _loadingHistory = false;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      _history = await ApiService().getMyAttendance(
        status: _selectedStatus,
      );
    } catch (_) {}
    setState(() => _loadingHistory = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ─── Filters ────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    value: _selectedStatus,
                    hint: 'All Status',
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Status')),
                      DropdownMenuItem(value: 'present', child: Text('Present')),
                      DropdownMenuItem(value: 'absent', child: Text('Absent')),
                      DropdownMenuItem(value: 'late', child: Text('Late')),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedStatus = v);
                      _loadHistory();
                    },
                  ),
                ),
              ],
            ),
          ),
          // ─── List ────────────────────────────────────
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history, size: 60, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'No attendance records found',
                              style: GoogleFonts.poppins(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _history.length,
                          itemBuilder: (_, i) => AttendanceTile(attendance: _history[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButton<String?>(
        value: value,
        hint: Text(hint, style: GoogleFonts.poppins(fontSize: 13)),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
      ),
    );
  }
}
