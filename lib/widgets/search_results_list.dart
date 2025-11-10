// 📁 lib/widgets/search_results_list.dart

import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../models/user_model.dart'; // (1) 🔥 استدعاء موديل اليوزر
import '../screens/patient/doctor_details_screen.dart';

class SearchResultsList extends StatelessWidget {
  final List<DoctorModel> doctors;
  final UserModel user; // (2) 🔥 ضفنا اليوزر
  final String jwt;    // (3) 🔥 ضفنا التوكن

  const SearchResultsList({
    super.key,
    required this.doctors,
    required String selectedSpecialty,
    required String selectedHospital,
    required this.user, // (4) 🔥 ضفناهم للـ constructor
    required this.jwt,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      // ... (زي ما هو)
    }

    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        // ... (بناء الـ imageUrl زي ما هو)
        String imageUrl;
        if (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty) {
          imageUrl = "http://localhost:1337${doctor.imageUrl}";
        } else {
          imageUrl = "https://cdn-icons-png.flaticon.com/512/921/921078.png";
        }

        return TweenAnimationBuilder<double>(
          // ... (زي ما هو)
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 80)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorDetailsScreen(
                    doctor: doctor,
                    user: user, // (5) 🔥 مررنا اليوزر
                    jwt: jwt,   // (6) 🔥 مررنا التوكن
                  ),
                ),
              );
            },
            child: Card(
              // ... (باقي الكارد زي ما هو بالظبط)
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            "https://cdn-icons-png.flaticon.com/512/921/921078.png",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor.specialization?.name ?? "غير محدد",
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.local_hospital,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.hospital?.name ?? "غير محدد",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}