// Tooth status enum
enum ToothStatus {
  healthy,
  decay,
  filled,
  rct, // Root Canal Treatment
  crown,
  bridge,
  implant,
  extracted,
  missing,
  planned,
}

// Extension for tooth status display
extension ToothStatusExtension on ToothStatus {
  String get displayName {
    switch (this) {
      case ToothStatus.healthy:
        return 'Healthy';
      case ToothStatus.decay:
        return 'Decay';
      case ToothStatus.filled:
        return 'Filled';
      case ToothStatus.rct:
        return 'RCT';
      case ToothStatus.crown:
        return 'Crown';
      case ToothStatus.bridge:
        return 'Bridge';
      case ToothStatus.implant:
        return 'Implant';
      case ToothStatus.extracted:
        return 'Extracted';
      case ToothStatus.missing:
        return 'Missing';
      case ToothStatus.planned:
        return 'Planned';
    }
  }

  // Color coding for visual representation
  String get colorCode {
    switch (this) {
      case ToothStatus.healthy:
        return '#4CAF50'; // Green
      case ToothStatus.decay:
        return '#F44336'; // Red
      case ToothStatus.filled:
        return '#2196F3'; // Blue
      case ToothStatus.rct:
        return '#9C27B0'; // Purple
      case ToothStatus.crown:
        return '#FF9800'; // Orange
      case ToothStatus.bridge:
        return '#795548'; // Brown
      case ToothStatus.implant:
        return '#607D8B'; // Blue Grey
      case ToothStatus.extracted:
        return '#000000'; // Black
      case ToothStatus.missing:
        return '#BDBDBD'; // Grey
      case ToothStatus.planned:
        return '#FFC107'; // Amber
    }
  }
}

class ToothTreatment {
  final int? id;
  final int patientId;
  final int toothNumber; // FDI notation: 11-18, 21-28, 31-38, 41-48
  final String procedure;
  final ToothStatus status;
  final String date;
  final String? notes;
  final int? billingId; // Optional link to billing record
  final double? cost;

  ToothTreatment({
    this.id,
    required this.patientId,
    required this.toothNumber,
    required this.procedure,
    required this.status,
    required this.date,
    this.notes,
    this.billingId,
    this.cost,
  });

  // Validate FDI tooth number
  static bool isValidToothNumber(int toothNumber) {
    // FDI notation: 11-18 (upper right), 21-28 (upper left),
    //               31-38 (lower left), 41-48 (lower right)
    final quadrant = toothNumber ~/ 10;
    final position = toothNumber % 10;
    return (quadrant >= 1 && quadrant <= 4) && (position >= 1 && position <= 8);
  }

  // Get tooth quadrant name
  static String getQuadrantName(int toothNumber) {
    final quadrant = toothNumber ~/ 10;
    switch (quadrant) {
      case 1:
        return 'Upper Right';
      case 2:
        return 'Upper Left';
      case 3:
        return 'Lower Left';
      case 4:
        return 'Lower Right';
      default:
        return 'Unknown';
    }
  }

  // Get tooth type
  static String getToothType(int toothNumber) {
    final position = toothNumber % 10;
    if (position >= 1 && position <= 2) return 'Incisor';
    if (position == 3) return 'Canine';
    if (position >= 4 && position <= 5) return 'Premolar';
    if (position >= 6 && position <= 8) return 'Molar';
    return 'Unknown';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'tooth_number': toothNumber,
      'procedure': procedure,
      'status': status.name,
      'date': date,
      'notes': notes,
      'billing_id': billingId,
      'cost': cost,
    };
  }

  factory ToothTreatment.fromMap(Map<String, dynamic> map) {
    return ToothTreatment(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      toothNumber: map['tooth_number'] as int,
      procedure: map['procedure'] as String,
      status: ToothStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ToothStatus.healthy,
      ),
      date: map['date'] as String,
      notes: map['notes'] as String?,
      billingId: map['billing_id'] as int?,
      cost: map['cost'] as double?,
    );
  }

  ToothTreatment copyWith({
    int? id,
    int? patientId,
    int? toothNumber,
    String? procedure,
    ToothStatus? status,
    String? date,
    String? notes,
    int? billingId,
    double? cost,
  }) {
    return ToothTreatment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      toothNumber: toothNumber ?? this.toothNumber,
      procedure: procedure ?? this.procedure,
      status: status ?? this.status,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      billingId: billingId ?? this.billingId,
      cost: cost ?? this.cost,
    );
  }
}

// Common dental procedures
class DentalProcedures {
  static const List<String> common = [
    'Amalgam Filling',
    'Composite Filling',
    'Root Canal Treatment (RCT)',
    'Crown (Cap)',
    'Bridge',
    'Extraction',
    'Scaling',
    'Polishing',
    'Implant',
    'Veneer',
    'Whitening',
    'Fluoride Treatment',
    'Sealant',
    'Denture',
    'Orthodontic Treatment',
    'Other',
  ];
}
