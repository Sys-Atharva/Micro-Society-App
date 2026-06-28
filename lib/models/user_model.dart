class BankDetails {
  final String bankName;
  final String accountNumber;
  final String ifscCode;

  const BankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
  });

  factory BankDetails.fromMap(Map<String, dynamic> map) {
    return BankDetails(
      bankName: map['bankName'] as String? ?? '',
      accountNumber: map['accountNumber'] as String? ?? '',
      ifscCode: map['ifscCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
    };
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool approved;
  final String? buildingCode;
  final String? flatId;
  final BankDetails bankDetails;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.approved,
    this.buildingCode,
    this.flatId,
    this.bankDetails = const BankDetails(
      bankName: '',
      accountNumber: '',
      ifscCode: '',
    ),
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
      approved: map['approved'] as bool? ?? false,
      buildingCode: map['buildingCode'] as String?,
      flatId: map['flatId'] as String?,
      bankDetails: map['bankDetails'] != null
          ? BankDetails.fromMap(map['bankDetails'] as Map<String, dynamic>)
          : const BankDetails(bankName: '', accountNumber: '', ifscCode: ''),
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'approved': approved,
      'buildingCode': buildingCode,
      'flatId': flatId,
      'bankDetails': bankDetails.toMap(),
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    bool? approved,
    String? buildingCode,
    String? flatId,
    BankDetails? bankDetails,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      approved: approved ?? this.approved,
      buildingCode: buildingCode ?? this.buildingCode,
      flatId: flatId ?? this.flatId,
      bankDetails: bankDetails ?? this.bankDetails,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
