class Patient {
  final int? id;
  final String name;
  final String? phone;
  final int? age;
  final String? gender;
  final String? address;
  final String? medicalHistory;
  final String? allergies;

  Patient({
    this.id,
    required this.name,
    this.phone,
    this.age,
    this.gender,
    this.address,
    this.medicalHistory,
    this.allergies,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
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
      name: map['name'],
      phone: map['phone'],
      age: map['age'],
      gender: map['gender'],
      address: map['address'],
      medicalHistory: map['medical_history'],
      allergies: map['allergies'],
    );
  }
}
