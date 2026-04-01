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
  });

  String get maskedAccountNumber {
    if (accountNumber.length >= 4) {
      final hidden = '*' * (accountNumber.length - 4);
      return '$hidden${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber;
  }
}
