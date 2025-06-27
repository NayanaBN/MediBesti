import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../services/doctor_service.dart';

class DoctorConnectScreen extends StatefulWidget {
  const DoctorConnectScreen({super.key});

  @override
  State<DoctorConnectScreen> createState() => _DoctorConnectScreenState();
}

class _DoctorConnectScreenState extends State<DoctorConnectScreen> {
  late Future<List<Doctor>> _futureDoctors;

  @override
  void initState() {
    super.initState();
    _futureDoctors = DoctorService().fetchDoctors();
  }

  void _startChat(Doctor doctor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Starting Chat with ${doctor.name}"),
        content: const Text("Chat feature coming soon."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  void _startVideoCall(Doctor doctor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Calling ${doctor.name}"),
        content: const Text("Video call feature coming soon."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connect with Doctors")),
      body: FutureBuilder<List<Doctor>>(
        future: _futureDoctors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load doctors."));
          }
          final doctors = snapshot.data!;
          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(doctor.imageUrl)),
                  title: Text(doctor.name),
                  subtitle: Text(doctor.specialization),
                  trailing: doctor.isAvailable
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.chat), onPressed: () => _startChat(doctor)),
                      IconButton(icon: const Icon(Icons.video_call), onPressed: () => _startVideoCall(doctor)),
                    ],
                  )
                      : const Text("Offline", style: TextStyle(color: Colors.red)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
