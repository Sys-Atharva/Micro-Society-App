class PaymentRequestModel {
  final String id;
  final String buildingCode;
  final String tenantId;
  final String tenantName;
  final String flatId;
  final String flatNumber;
  final int amount;
  final String rentMonth;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime? paidDate;
  final String? ownerNote;
  final String? transactionRef;

  const PaymentRequestModel({
    required this.id,
    required this.buildingCode,
    required this.tenantId,
    required this.tenantName,
    required this.flatId,
    required this.flatNumber,
    required this.amount,
    required this.rentMonth,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.paidDate,
    this.ownerNote,
    this.transactionRef,
  });

  factory PaymentRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentRequestModel(
      id: id,
      buildingCode: map['buildingCode'] as String? ?? '',
      tenantId: map['tenantId'] as String? ?? '',
      tenantName: map['tenantName'] as String? ?? '',
      flatId: map['flatId'] as String? ?? '',
      flatNumber: map['flatNumber'] as String? ?? '',
      amount: map['amount'] as int? ?? 0,
      rentMonth: map['rentMonth'] as String? ?? '',
      dueDate: (map['dueDate'] as dynamic)?.toDate() ?? DateTime.now(),
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      paidDate: (map['paidDate'] as dynamic)?.toDate(),
      ownerNote: map['ownerNote'] as String?,
      transactionRef: map['transactionRef'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buildingCode': buildingCode,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'flatId': flatId,
      'flatNumber': flatNumber,
      'amount': amount,
      'rentMonth': rentMonth,
      'dueDate': dueDate,
      'status': status,
      'createdAt': createdAt,
      'paidDate': paidDate,
      'ownerNote': ownerNote,
      'transactionRef': transactionRef,
    };
  }

  PaymentRequestModel copyWith({
    String? id,
    String? buildingCode,
    String? tenantId,
    String? tenantName,
    String? flatId,
    String? flatNumber,
    int? amount,
    String? rentMonth,
    DateTime? dueDate,
    String? status,
    DateTime? createdAt,
    DateTime? paidDate,
    String? ownerNote,
    String? transactionRef,
  }) {
    return PaymentRequestModel(
      id: id ?? this.id,
      buildingCode: buildingCode ?? this.buildingCode,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      flatId: flatId ?? this.flatId,
      flatNumber: flatNumber ?? this.flatNumber,
      amount: amount ?? this.amount,
      rentMonth: rentMonth ?? this.rentMonth,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidDate: paidDate ?? this.paidDate,
      ownerNote: ownerNote ?? this.ownerNote,
      transactionRef: transactionRef ?? this.transactionRef,
    );
  }
}
