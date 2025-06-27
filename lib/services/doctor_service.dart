import '../models/doctor_model.dart';

class DoctorService {
  Future<List<Doctor>> fetchDoctors() async {
    // Simulated delay and data
    await Future.delayed(Duration(seconds: 1));
    return [
      Doctor(
        name: "Dr. Sneha Reddy",
        specialization: "Cardiologist",
        imageUrl: "https://i.pravatar.cc/150?img=47",
        isAvailable: true,
      ),
      Doctor(
        name: "Dr. Arjun Mehta",
        specialization: "Dermatologist",
        imageUrl: "https://i.pravatar.cc/150?img=56",
        isAvailable: false,
      ),
      Doctor(
        name: "Dr. Nisha Rao",
        specialization: "Pediatrician",
        imageUrl: "https://i.pravatar.cc/150?img=32",
        isAvailable: true,
      ),
    ];
  }
}
