import 'package:flutter/material.dart';

class TopDoctorsList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Map<String, String>> doctors;

  const TopDoctorsList({
    Key? key,
    required this.scrollController,
    required this.doctors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Doctors",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.grey),
        SizedBox(
          height: 150,
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doc = doctors[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        doc["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(doc["specialization"]!, style: const TextStyle(color: Colors.black54)),
                      Text(doc["hospital"]!, style: const TextStyle(color: Colors.black38)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
