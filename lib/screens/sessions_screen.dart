import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'session_detail_screen.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Session> _upcoming = [];
  List<Session> _completed = [];
  bool _loadingUpcoming = false;
  bool _loadingCompleted = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadUpcoming();
    _loadCompleted();
  }

  Future<void> _loadUpcoming() async {
    setState(() => _loadingUpcoming = true);
    try {
      _upcoming = await ApiService().getMySessions(status: 'planned');
    } catch (_) {}
    setState(() => _loadingUpcoming = false);
  }

  Future<void> _loadCompleted() async {
    setState(() => _loadingCompleted = true);
    try {
      _completed = await ApiService().getMySessions(status: 'closed');
    } catch (_) {}
    setState(() => _loadingCompleted = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(_upcoming, _loadingUpcoming, _loadUpcoming, isUpcoming: true),
          _buildList(_completed, _loadingCompleted, _loadCompleted, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildList(
    List<Session> sessions,
    bool loading,
    Future<void> Function() onRefresh, {
    required bool isUpcoming,
  }) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              isUpcoming ? 'No upcoming sessions' : 'No completed sessions',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (_, i) {
          final s = sessions[i];
          return _SessionListCard(
            session: s,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SessionDetailScreen(session: s),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SessionListCard extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;
  const _SessionListCard({required this.session, required this.onTap});

  Color get _typeColor {
    switch (session.type) {
      case 'cours': return AppColors.primary;
      case 'td': return AppColors.secondary;
      case 'tp': return AppColors.warning;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    session.typeLabel,
                    style: GoogleFonts.poppins(
                      color: _typeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.moduleName ?? 'Module',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (session.teacherName != null)
                    Text(
                      session.teacherName!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        session.formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${session.startTime} - ${session.endTime}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (session.room != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.room_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          session.room!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                StatusBadge(status: session.status),
                if (session.isActive) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
