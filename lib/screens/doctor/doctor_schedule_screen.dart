// 📁 lib/screens/doctor/doctor_schedule_screen.dart
// (النسخة اللي بتبعت documentId)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/doctor_model.dart';
import '../../models/doctor_schedule_model.dart';
import '../../services/doctor_schedule_service.dart';
import 'add_edit_schedule_screen.dart';

class DoctorScheduleScreen extends StatefulWidget {
  final DoctorModel doctor;
  final String token;

  const DoctorScheduleScreen({
    Key? key,
    required this.doctor,
    required this.token,
  }) : super(key: key);

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  final DoctorScheduleService _scheduleService = DoctorScheduleService();
  late Future<List<DoctorScheduleModel>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    _schedulesFuture = _scheduleService.getSchedules(
      widget.doctor.id,
      widget.token,
    );
  }

  void _navigateToAddEditScreen(DoctorScheduleModel? schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditScheduleScreen(
          token: widget.token,
          doctor: widget.doctor,
          scheduleToEdit: schedule,
        ),
      ),
    ).then((value) {
      // (بنعمل ريفريش بس لو رجع 'true')
      if (value == true) {
        setState(() => _loadSchedules());
      }
    });
  }

  // --- (1) 🔥 التعديل هنا (بقى بيستقبل documentId) ---
  void _handleDelete(DoctorScheduleModel schedule) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this schedule?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Yes, Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // --- (2) 🔥 التعديل هنا (بنبعت الـ documentId) ---
    final bool success = await _scheduleService.deleteSchedule(
      schedule.documentId, // (السترينج)
      schedule.id, // (الرقم)
      widget.token,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Schedule Deleted"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _loadSchedules());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to delete schedule"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "My Schedule",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        actions: [
          FutureBuilder<List<DoctorScheduleModel>>(
            future: _schedulesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError) {
                return IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue,
                    size: 28,
                  ),
                  onPressed: () => _navigateToAddEditScreen(null),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _loadSchedules()),
        child: FutureBuilder<List<DoctorScheduleModel>>(
          future: _schedulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final schedules = snapshot.data ?? [];

            if (schedules.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "You haven't set up your schedule yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Add your available times so patients can start booking appointments.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Set Up Schedule",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _navigateToAddEditScreen(null),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return _buildScheduleCard(schedule);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleCard(DoctorScheduleModel schedule) {
    final from = _formatTime(schedule.fromTime);
    final to = _formatTime(schedule.toTime);
    final hospital = schedule.hospital?.name ?? "No Hospital Selected";

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shadowColor: Colors.blue.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.day.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.local_hospital_outlined,
                    color: Colors.black54,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hospital, // (هنا هيظهر اسم المستشفى)
                    style: const TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    color: Colors.black54,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$from - $to",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    // --- (4) 🔥 التعديل هنا (بنبعت documentId) ---
                    onPressed: () => _handleDelete(schedule),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                    label: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () => _navigateToAddEditScreen(schedule),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String time) {
    try {
      final parsed = DateFormat("HH:mm:ss.SSS").parse(time);
      return DateFormat("h:mm a").format(parsed);
    } catch (e) {
      return time;
    }
  }
}
