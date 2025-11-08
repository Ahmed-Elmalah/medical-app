import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen>
    with SingleTickerProviderStateMixin {
  String? selectedDay;

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    final imageUrl = doctor.imageUrl != null
        ? "http://localhost:1337${doctor.imageUrl}"
        : "https://cdn-icons-png.flaticon.com/512/3774/3774299.png"; // صورة افتراضية

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
              // الصورة
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

              // اسم الدكتور و التخصص
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

              // المستشفى
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

              // العنوان الفرعي للمواعيد
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

              // قائمة الأيام (كروت منفصلة)
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
                              selectedDay =
                                  isSelected ? null : day; // التبديل بين الأيام
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
                        // ظهور الوقت والزرار بانيميشن ناعم
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
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "تم حجز موعد يوم $day بنجاح ✅"),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.calendar_month , color: Colors.white,),
                                      label: const Text(
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
