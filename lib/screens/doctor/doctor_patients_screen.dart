// 📁 lib/screens/doctor/doctor_patients_screen.dart
// (النسخة اللي بتجيب الداتا من الـ API)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // (عشان نظبط التاريخ)
import '../../widgets/patient_card.dart';
import '../../models/doctor_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class DoctorPatientsScreen extends StatefulWidget {
  final DoctorModel doctor;
  final String token;

  const DoctorPatientsScreen({
    Key? key,
    required this.doctor,
    required this.token,
  }) : super(key: key);

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final BookingService _bookingService = BookingService();
  late Future<List<BookingModel>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadDoctorBookings();
  }

  void _loadDoctorBookings() {
    _bookingsFuture = _bookingService.getBookingsForDoctor(
      doctorId: widget.doctor.id,
      token: widget.token,
    );
  }

  // (دالة مساعدة لتنسيق التاريخ)
  String _formatDateTime(DateTime dt) {
    return DateFormat("E, MMM d  •  h:mm a").format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "My Patients",
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _loadDoctorBookings()),
        child: FutureBuilder<List<BookingModel>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            
            // --- 1. حالة الـ Loading ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // --- 2. حالة الـ Error ---
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            // --- 3. حالة النجاح ---
            final bookings = snapshot.data ?? [];

            // (لو مفيش حجوزات)
            if (bookings.isEmpty) {
              return const Center(
                child: Text(
                  "You have no patients yet 👨‍⚕️",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // (لو فيه حجوزات، نعرض القايمة)
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                // (تجهيز الداتا للكارت)
                final patientName = booking.user?.username ?? "Unknown Patient";
                final hospitalName = booking.hospital?.name ?? "N/A";
                final date = _formatDateTime(booking.date);
                
                // (صورة افتراضية)
                final imageUrl = "https://cdn-icons-png.flaticon.com/512/3774/3774299.png";

                return PatientCard(
                  name: patientName,
                  hospital: hospitalName,
                  date: date,
                  imageUrl: imageUrl,
                  onTap: () {
                    // (ممكن نبقى نعمل شاشة تفاصيل المريض هنا)
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}