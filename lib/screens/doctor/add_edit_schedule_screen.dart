// 📁 lib/screens/doctor/add_edit_schedule_screen.dart
// (النسخة الكاملة اللي بتشتغل مع "flat" models)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/doctor_model.dart';
import '../../models/doctor_schedule_model.dart';
import '../../models/hospital_model.dart';
import '../../services/doctor_schedule_service.dart';
import '../../services/hospital_service.dart';

class AddEditScheduleScreen extends StatefulWidget {
  final String token;
  final DoctorModel doctor;
  final DoctorScheduleModel? scheduleToEdit; 

  const AddEditScheduleScreen({
    Key? key,
    required this.token,
    required this.doctor,
    this.scheduleToEdit,
  }) : super(key: key);

  @override
  State<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final DoctorScheduleService _service = DoctorScheduleService();

  String? _selectedDay;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  HospitalModel? _selectedHospital;
  bool _isLoading = false;

  late Future<List<HospitalModel>> _hospitalsFuture;
  
  final List<String> _days = [
    "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"
  ];

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = HospitalService.getHospitals();
    
    if (widget.scheduleToEdit != null) {
      final schedule = widget.scheduleToEdit!;
      _selectedDay = schedule.day;
      _fromTime = _parseTime(schedule.fromTime);
      _toTime = _parseTime(schedule.toTime);
      _selectedHospital = schedule.hospital;
    }
  }

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  String _formatTimeForStrapi(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00.000";
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromTime == null || _toTime == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select start and end times"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'day': _selectedDay,
      'from_time': _formatTimeForStrapi(_fromTime!),
      'to_time': _formatTimeForStrapi(_toTime!),
      'doctor': widget.doctor.id,
      'hospital': _selectedHospital?.id,
    };

    bool success;
    if (widget.scheduleToEdit == null) {
      success = await _service.createSchedule(data, widget.token);
    } else {
      success = await _service.updateSchedule(
        widget.scheduleToEdit!.documentId,
        data, 
        widget.token
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to save schedule"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.scheduleToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Schedule" : "Add New Schedule"),
      ),
      body: FutureBuilder<List<HospitalModel>>(
        future: _hospitalsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final hospitals = snapshot.data!;

          // (الكود ده بيمنع الكراش بتاع الـ Dropdown)
          if (isEditing && _selectedHospital != null) {
            final hospitalIds = hospitals.map((h) => h.id).toList();
            if (!hospitalIds.contains(_selectedHospital!.id)) {
              hospitals.insert(0, _selectedHospital!);
            }
          }
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  decoration: const InputDecoration(labelText: "Day of Week"),
                  items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                  onChanged: (val) => setState(() => _selectedDay = val),
                  validator: (val) => val == null ? "Please select a day" : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<HospitalModel>(
                  value: _selectedHospital,
                  decoration: const InputDecoration(labelText: "Hospital"),
                  items: hospitals
                      .toSet() // (بيمنع التكرار لو المستشفى اتضافت فوق)
                      .map((h) => DropdownMenuItem(value: h, child: Text(h.name)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedHospital = val),
                  validator: (val) => val == null ? "Please select a hospital" : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePickerField(
                        context,
                        "From Time",
                        _fromTime,
                        (newTime) => setState(() => _fromTime = newTime),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildTimePickerField(
                        context,
                        "To Time",
                        _toTime,
                        (newTime) => setState(() => _toTime = newTime),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                      : Text(
                          isEditing ? "Save Changes" : "Add Schedule",
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimePickerField(BuildContext context, String label, TimeOfDay? time, Function(TimeOfDay) onTimeChanged) {
    final text = time != null ? time.format(context) : "Select Time";
    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (newTime != null) {
          onTimeChanged(newTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}