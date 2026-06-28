class FlatModel {
  final String flatId;
  final String flatNumber;
  final String buildingCode;
  final String status;
  final String? tenantId;
  final String ownerId;

  const FlatModel({
    required this.flatId,
    required this.flatNumber,
    required this.buildingCode,
    required this.status,
    this.tenantId,
    required this.ownerId,
  });

  factory FlatModel.fromMap(Map<String, dynamic> map, String flatId) {
    return FlatModel(
      flatId: flatId,
      flatNumber: map['flatNumber'] as String? ?? '',
      buildingCode: map['buildingCode'] as String? ?? '',
      status: map['status'] as String? ?? 'vacant',
      tenantId: map['tenantId'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flatNumber': flatNumber,
      'buildingCode': buildingCode,
      'status': status,
      'tenantId': tenantId,
      'ownerId': ownerId,
    };
  }

  FlatModel copyWith({
    String? flatId,
    String? flatNumber,
    String? buildingCode,
    String? status,
    String? tenantId,
    String? ownerId,
  }) {
    return FlatModel(
      flatId: flatId ?? this.flatId,
      flatNumber: flatNumber ?? this.flatNumber,
      buildingCode: buildingCode ?? this.buildingCode,
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
