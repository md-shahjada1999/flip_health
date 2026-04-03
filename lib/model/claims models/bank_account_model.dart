class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String branch;
  final String holderName;
  final int verifyStatus; // 0=pending, 1=verified, 2=rejected
  final String? verifyReason;
  final String? chequeImagePath;
  /// Attachment id from `cheque_attachment.id` — required when updating without re-uploading.
  final String? chequeAttachmentId;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branch,
    required this.holderName,
    this.verifyStatus = 0,
    this.verifyReason,
    this.chequeImagePath,
    this.chequeAttachmentId,
  });

  /// Parses one item from `GET /patient/bank_details` (`data` array), aligned with patient_app bank list.
  factory BankAccount.fromJson(Map<String, dynamic> json) {
    final attachment = json['cheque_attachment'];
    String? chequePath;
    String? chequeId;
    if (attachment is Map) {
      final p = attachment['path'];
      if (p != null) chequePath = p.toString();
      final aid = attachment['id'];
      if (aid != null) chequeId = aid.toString();
    }

    int verify = 0;
    final vs = json['verify_status'];
    if (vs is int) {
      verify = vs;
    } else if (vs is num) {
      verify = vs.toInt();
    } else {
      verify = int.tryParse(vs?.toString() ?? '') ?? 0;
    }

    return BankAccount(
      id: (json['id'] ?? '').toString(),
      bankName: (json['bank_name'] ?? '').toString(),
      accountNumber: (json['account_number'] ?? '').toString(),
      ifscCode: (json['ifsc_code'] ?? '').toString(),
      branch: (json['branch'] ?? '').toString(),
      holderName: (json['account_holder_name'] ?? '').toString(),
      verifyStatus: verify,
      verifyReason: json['verify_reason']?.toString(),
      chequeImagePath: chequePath,
      chequeAttachmentId: chequeId,
    );
  }

  /// Whether the user may open the full edit form (patient_app: only rejected banks).
  static bool canEditBankDetails(int verifyStatus) => verifyStatus == 2;

  String get maskedAccountNumber {
    if (accountNumber.length >= 4) {
      final hidden = '*' * (accountNumber.length - 4);
      return '$hidden${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber;
  }
}
