// 📁 lib/widgets/doctor_card_widget.dart
import 'package:flutter/material.dart';
import '../models/doctor_model.dart';

/// 🧩 ويدجت واحدة مسئولة عن عرض كارد الدكتور في أي مكان في التطبيق
/// بنستخدمها في نتائج البحث أو القوائم زي Top Doctors
class DoctorCardWidget extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback? onTap; // عشان نقدر نضيف أكشن لما المستخدم يضغط على الكارد (اختياري)

  const DoctorCardWidget({
    Key? key,
    required this.doctor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 🧍‍♂️ أيقونة الدكتور
              const Icon(
                Icons.person_pin_circle_rounded,
                color: Colors.blueAccent,
                size: 42,
              ),
              const SizedBox(width: 16),

              // 🩺 اسم الدكتور والمستشفى
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👨‍⚕️ اسم الدكتور
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // 🏥 المستشفى
                    Text(
                      doctor.hospital?.name ?? "Unknown Hospital",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // 💉 التخصص
                    if (doctor.specialization?.name != null)
                      Text(
                        doctor.specialization!.name,
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),

              // ➡️ سهم صغير في اليمين
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
