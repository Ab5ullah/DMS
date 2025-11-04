class Patient {
  final int? id;
  final String? patientId; // Auto-generated ID like PAT-001
  final String name;
  final String? phone;
  final String? cnic; // Pakistani CNIC number
  final int? age;
  final String? gender;
  final String? address;
  final String? medicalHistory;
  final String? allergies;

  Patient({
    this.id,
    this.patientId,
    required this.name,
    this.phone,
    this.cnic,
    this.age,
    this.gender,
    this.address,
    this.medicalHistory,
    this.allergies,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'name': name,
      'phone': phone,
      'cnic': cnic,
      'age': age,
      'gender': gender,
      'address': address,
      'medical_history': medicalHistory,
      'allergies': allergies,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      patientId: map['patient_id'],
      name: map['name'],
      phone: map['phone'],
      cnic: map['cnic'],
      age: map['age'],
      gender: map['gender'],
      address: map['address'],
      medicalHistory: map['medical_history'],
      allergies: map['allergies'],
    );
  }
}
