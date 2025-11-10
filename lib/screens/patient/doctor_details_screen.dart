// 📁 lib/screens/patient/doctor_details_screen.dart
// (النسخة اللي فيها if mounted)

import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../models/user_model.dart';
import '../../services/booking_service.dart';

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
  String? selectedDay;
  bool _isLoading = false;

  void _handleBooking() async {
    if (selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a day first"), backgroundColor: Colors.orange),
      );
      return;
    }
    
    if (_isLoading) return;
    setState(() => _isLoading = true); 

    final fromTime = widget.doctor.workingHours?['from'] ?? "09:00"; 

    final bool success = await _bookingService.createBooking(
      doctorId: widget.doctor.id,
      userId: widget.user.id,
      selectedDay: selectedDay!,
      fromTime: fromTime,
      token: widget.jwt,
    );

    setState(() => _isLoading = false); 

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Booking successful! Day: $selectedDay at $fromTime"),
          backgroundColor: Colors.green,
        ),
      );
      
      // --- (1) 🔥 التعديل هنا ---
      // (لازم نتأكد إن الصفحة لسه موجودة)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) { 
          Navigator.pop(context); 
        }
      });
      // -------------------------

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Failed to create booking. Please try again."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  
  // (دالة الـ build زي ما هي بالظبط متغيرتش)
  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final imageUrl = doctor.imageUrl != null
        ? "http://localhost:1337${doctor.imageUrl}"
        : "https://cdn-icons-png.flaticon.com/512/3774/3774299.png"; 

    final workingDays = doctor.workingDays ?? [];
    final from = doctor.workingHours?['from'] ?? "غير محدد";
    final to = doctor.workingHours?['to'] ?? "غير محدد";

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
                  "مواعيد العمل",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: workingDays.map((day) {
                  final isSelected = selectedDay == day;

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
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: isSelected
                              ? Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      " $from - $to",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                             Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 12),
                                      ),
                                      onPressed: _handleBooking,
                                      icon: const Icon(Icons.calendar_month , color: Colors.white,),
                                      label: _isLoading
                                          ? const CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            )
                                          : const Text(
                                              "احجز الآن",
                                              style: TextStyle(fontSize: 18 , color: Colors.white),
                                            ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}