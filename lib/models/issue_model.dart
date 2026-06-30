class IssueModel {
  final String issueId;
  final String buildingCode;
  final String flatNumber;
  final String tenantId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime? createdAt;

  const IssueModel({
    required this.issueId,
    required this.buildingCode,
    required this.flatNumber,
    required this.tenantId,
    required this.title,
    required this.description,
    required this.status,
    this.priority = 'medium',
    this.createdAt,
  });

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';

  factory IssueModel.fromMap(Map<String, dynamic> map, String issueId) {
    return IssueModel(
      issueId: issueId,
      buildingCode: map['buildingCode'] as String? ?? '',
      flatNumber: map['flatNumber'] as String? ?? '',
      tenantId: map['tenantId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      priority: map['priority'] as String? ?? 'medium',
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buildingCode': buildingCode,
      'flatNumber': flatNumber,
      'tenantId': tenantId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  IssueModel copyWith({
    String? issueId,
    String? buildingCode,
    String? flatNumber,
    String? tenantId,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? createdAt,
  }) {
    return IssueModel(
      issueId: issueId ?? this.issueId,
      buildingCode: buildingCode ?? this.buildingCode,
      flatNumber: flatNumber ?? this.flatNumber,
      tenantId: tenantId ?? this.tenantId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
