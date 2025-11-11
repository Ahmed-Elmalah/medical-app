// 📁 lib/screens/patient/doctor_details_screen.dart
// (النسخة اللي بتقرأ من الجدول الجديد وبنفس الديزاين)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // (هنحتاجها للوقت)
import '../../models/doctor_model.dart';
import '../../models/user_model.dart';
import '../../services/booking_service.dart';

// (1) 🔥 استدعاء الموديل والسيرفيس الجداد
import '../../models/doctor_schedule_model.dart';
import '../../services/doctor_schedule_service.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final DoctorModel doctor;
  final UserModel user;
  final String jwt;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    required this.user,
    required this.jwt,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen>
    with SingleTickerProviderStateMixin {
      
  final BookingService _bookingService = BookingService();
  
  // (2) 🔥 السيرفيس الجديد
  final DoctorScheduleService _scheduleService = DoctorScheduleService();
  late Future<List<DoctorScheduleModel>> _schedulesFuture;

  // (3) 🔥 دي لسه محتاجينها عشان نعرف أنهي كارد مفتوح
  String? selectedDay; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // (4) 🔥 أول ما الشاشة تفتح، بنجيب المواعيد الجديدة
    _loadSchedules();
  }

  void _loadSchedules() {
    _schedulesFuture = _scheduleService.getSchedules(
      widget.doctor.id,
      widget.jwt, // (بنستخدم توكن المريض العادي عشان يقرأ)
    );
  }

  // (5) 🔥 دالة الحجز اتعدلت عشان تاخد الميعاد كله
// --- (1) 🔥 التعديل هنا ---
  void _handleBooking(DoctorScheduleModel schedule) async {
    if (_isLoading) return;
    
    if (schedule.hospital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Cannot book: Hospital data is missing for this schedule."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final bool success = await _bookingService.createBooking(
      doctorId: widget.doctor.id,
      userId: widget.user.id,
      hospitalId: schedule.hospital!.id,
      scheduleId: schedule.id, // (بعتنا ID الميعاد)
      selectedDay: schedule.day,
      fromTime: schedule.fromTime,
      token: widget.jwt,
    );

    setState(() => _isLoading = false); 

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Booking successful! Day: ${schedule.day}"),
          backgroundColor: Colors.green,
        ),
      );
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) { 
          Navigator.pop(context); 
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to create booking. Please try again."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  // (6) 🔥 دالة مساعدة لتنسيق الوقت
  String _formatTime(String time) {
    try {
      final parsed = DateFormat("HH:mm:ss.SSS").parse(time);
      return DateFormat("h:mm a").format(parsed);
    } catch (e) {
      return time; 
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final imageUrl = doctor.imageUrl != null
        ? "http://localhost:1337${doctor.imageUrl}"
        : "https://cdn-icons-png.flaticon.com/512/3774/3774299.png"; 

    return Scaffold(
      appBar: AppBar(
        title: Text(
          doctor.name,
          style: const TextStyle(fontWeight: FontWeight.bold ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // (صورة الدكتور وبياناته زي ما هي بالظبط)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.network(
                    "https://cdn-icons-png.flaticon.com/512/3774/3774299.png",
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                doctor.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B475E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor.specialization?.name ?? "تخصص غير محدد",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_hospital, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    doctor.hospital?.name ?? "مستشفى غير محددة",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "مواعيد العمل", // (الديزاين زي ما هو)
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- (7) 🔥 التعديل الكبير هنا ---
              // (هنستخدم FutureBuilder عشان نجيب المواعيد الجديدة)
              FutureBuilder<List<DoctorScheduleModel>>(
                future: _schedulesFuture,
                builder: (context, snapshot) {
                  
                  // (حالة التحميل)
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // (حالة لو مفيش مواعيد)
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "This doctor has no available schedules at the moment.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  
                  // (حالة النجاح)
                  final schedules = snapshot.data!;
                  
                  // (هنجيب الأيام المتاحة عشان نحافظ على الديزاين القديم)
                  final uniqueDays = schedules.map((s) => s.day).toSet().toList();

                  // (هنرجع للـ Column القديم عشان نحافظ على الديزاين)
                  return Column(
                    children: uniqueDays.map((day) {
                      final isSelected = selectedDay == day;
                      
                      // (هنجيب المواعيد الخاصة باليوم ده بس)
                      final schedulesForThisDay = schedules.where((s) => s.day == day).toList();

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blueAccent.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDay = isSelected ? null : day;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.blueAccent,
                                  ),
                                ],
                              ),
                            ),
                            
                            // (الكود اللي بيتفتح ويتقفل)
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: isSelected
                                  ? Column(
                                      children: [
                                        const Divider(height: 20),
                                        // (هنلف على المواعيد بتاعة اليوم ده)
                                        ...schedulesForThisDay.map((schedule) {
                                          final from = _formatTime(schedule.fromTime);
                                          final to = _formatTime(schedule.toTime);
                                          final hospital = schedule.hospital?.name ?? "Main Clinic";
                                          
                                          return _buildBookingSlot(schedule, hospital, from, to);
                                        }).toList(),
                                      ],
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (8) 🔥 ويدجت جديد بيعرض الميعاد الواحد وزرار الحجز بتاعه
  Widget _buildBookingSlot(DoctorScheduleModel schedule, String hospital, String from, String to) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xffdfe0f4),
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // (التفاصيل: المستشفى والوقت)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital_outlined, color: Colors.black54, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      hospital,
                      style: const TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined, color: Colors.black54, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "$from - $to",
                      style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // (زرار الحجز)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            // (بنباصي الميعاد كله للدالة)
            onPressed: () => _handleBooking(schedule), 
            child: _isLoading // (بيعرض loading بس على الزرار ده)
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "احجز",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}