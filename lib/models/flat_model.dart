class FlatModel {
  final String flatId;
  final String flatNumber;
  final String buildingCode;
  final String? buildingWing;
  final String? flatFloor;
  final String status;
  final String? tenantId;
  final String ownerId;
  final int? rentAmount;
  final int rentDueDay;
  final DateTime? rentStartDate;

  const FlatModel({
    required this.flatId,
    required this.flatNumber,
    required this.buildingCode,
    this.buildingWing,
    this.flatFloor,
    required this.status,
    this.tenantId,
    required this.ownerId,
    this.rentAmount,
    this.rentDueDay = 5,
    this.rentStartDate,
  });

  factory FlatModel.fromMap(Map<String, dynamic> map, String flatId) {
    return FlatModel(
      flatId: flatId,
      flatNumber: map['flatNumber'] as String? ?? '',
      buildingCode: map['buildingCode'] as String? ?? '',
      buildingWing: map['buildingWing'] as String?,
      flatFloor: map['flatFloor'] as String?,
      status: map['status'] as String? ?? 'vacant',
      tenantId: map['tenantId'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      rentAmount: map['rentAmount'] as int?,
      rentDueDay: map['rentDueDay'] as int? ?? 5,
      rentStartDate: (map['rentStartDate'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flatNumber': flatNumber,
      'buildingCode': buildingCode,
      'buildingWing': buildingWing,
      'flatFloor': flatFloor,
      'status': status,
      'tenantId': tenantId,
      'ownerId': ownerId,
      'rentAmount': rentAmount,
      'rentDueDay': rentDueDay,
      'rentStartDate': rentStartDate,
    };
  }

  FlatModel copyWith({
    String? flatId,
    String? flatNumber,
    String? buildingCode,
    String? buildingWing,
    String? flatFloor,
    String? status,
    String? tenantId,
    String? ownerId,
    int? rentAmount,
    int? rentDueDay,
    DateTime? rentStartDate,
  }) {
    return FlatModel(
      flatId: flatId ?? this.flatId,
      flatNumber: flatNumber ?? this.flatNumber,
      buildingCode: buildingCode ?? this.buildingCode,
      buildingWing: buildingWing ?? this.buildingWing,
      flatFloor: flatFloor ?? this.flatFloor,
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
      ownerId: ownerId ?? this.ownerId,
      rentAmount: rentAmount ?? this.rentAmount,
      rentDueDay: rentDueDay ?? this.rentDueDay,
      rentStartDate: rentStartDate ?? this.rentStartDate,
    );
  }
}
