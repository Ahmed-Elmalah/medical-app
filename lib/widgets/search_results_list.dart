import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../screens/patient/doctor_details_screen.dart';

class SearchResultsList extends StatelessWidget {
  final List<DoctorModel> doctors;

  const SearchResultsList({
    super.key,
    required this.doctors, required String selectedSpecialty, required String selectedHospital,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            "❌ لا يوجد دكاترة بهذا التخصص أو المستشفى",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];

        // 🔗 بناء رابط الصورة
        String imageUrl;
        if (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty) {
          // لو الصورة موجودة نضيف لينك الدومين
          imageUrl = "http://localhost:1337${doctor.imageUrl}";
        } else {
          // صورة افتراضية في حالة عدم وجود صورة
          imageUrl = "https://cdn-icons-png.flaticon.com/512/921/921078.png";
        }

        return TweenAnimationBuilder<double>(
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
                  builder: (_) => DoctorDetailsScreen(doctor: doctor),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 🩺 صورة الطبيب
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // في حالة فشل تحميل الصورة
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

                    // 👨‍⚕️ بيانات الطبيب
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
