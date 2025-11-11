// 📁 lib/screens/patient/patient_schedule_screen.dart
// (النسخة النهائية اللي فيها "Cancel" شغال)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class PatientScheduleScreen extends StatefulWidget {
  final UserModel user;
  final String jwt;

  const PatientScheduleScreen({Key? key, required this.user, required this.jwt})
    : super(key: key);

  @override
  State<PatientScheduleScreen> createState() => _PatientScheduleScreenState();
}

class _PatientScheduleScreenState extends State<PatientScheduleScreen> {
  final BookingService _bookingService = BookingService();
  late Future<List<BookingModel>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // (دي الدالة اللي بتجيب الحجوزات)
  void _loadBookings() {
    _bookingsFuture = _bookingService.getUserBookings(
      userId: widget.user.id,
      token: widget.jwt,
    );
  }

  // (دالة الوقت زي ما هي)
  String _formatDateTime(DateTime dt) {
    return DateFormat("E, MMM d  •  h:mm a").format(dt);
  }

  // --- (🔥 الدالة الجديدة اللي بتنفذ الإلغاء) ---
  void _handleCancelBooking(BookingModel booking) async {
    // (أولاً: نعرض رسالة تأكيد)
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Cancellation"),
        content: Text(
          "Are you sure you want to cancel your appointment with ${booking.doctor?.name ?? 'this doctor'}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // (لو ضغط "لأ")
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), // (لو ضغط "نعم")
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    // (لو مرجعش "true"، نوقف)
    if (confirmed != true) {
      return;
    }

    // (ثانياً: نعرض دايرة loading)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // (ثالثاً: نكلم الـ API)
    final bool success = await _bookingService.cancelBooking(
      documentId: booking.documentId,
      token: widget.jwt,
    );

    // (رابعاً: نقفل دايرة الـ loading)
    if (!mounted) return;
    Navigator.pop(context); // (بيقفل الـ CircularProgressIndicator)

    // (خامساً: نعرض النتيجة ونحدث القايمة)
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Appointment Canceled"),
          backgroundColor: Colors.green,
        ),
      );
      // (أهم خطوة: نحدث القايمة عشان الحجز يختفي)
      setState(() {
        _loadBookings();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to cancel. Please try again."),
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          // (كل حالات الـ loading والـ error زي ما هي)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                "You have no upcoming appointments 📅",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // (القايمة والديزاين زي ما هما)
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final doctorName = booking.doctor?.name ?? "Unknown Doctor";
              final specialization =
                  booking.doctor?.specialization?.name ?? "General Care";

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  shadowColor: Colors.blue.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              color: Colors.black54,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              specialization,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.black54,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDateTime(booking.date),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Confirmed",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            // --- (🔥 ربطنا الزرار بالدالة الجديدة) ---
                            TextButton.icon(
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              label: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              onPressed: () {
                                _handleCancelBooking(
                                  booking,
                                ); // (بنباصي الحجز اللي عايزين نلغيه)
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}