import 'package:flutter/material.dart';

class ClaimModel {
  final String id;
  final String userName;
  final String userPhone;
  final int status;
  final double claimAmount;
  final double approvedAmount;
  final String createdAt;
  final String? serviceType;
  final List<ClaimBill> bills;

  /// From list API when present — detail may refresh this.
  final bool canDispute;

  ClaimModel({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.status,
    required this.claimAmount,
    this.approvedAmount = 0,
    required this.createdAt,
    this.serviceType,
    this.bills = const [],
    this.canDispute = false,
  });

  /// Parses one row from `GET /patient/reimbursement?page=…` (`data[]`).
  factory ClaimModel.fromApiMap(Map<String, dynamic> m) {
    final user = m['user'];
    String userName = '--';
    String userPhone = '';
    if (user is Map) {
      final um = Map<String, dynamic>.from(user);
      userName = um['name']?.toString() ?? '--';
      userPhone = um['phone']?.toString() ?? '';
    }
    final id = m['id']?.toString() ?? '';
    final status =
        int.tryParse(m['reimbursement_status']?.toString() ?? '') ?? 0;
    double readAmount(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    final claimAmount = readAmount(m['claim_amount']);
    final approvedAmount = readAmount(m['approved_amount']);
    final createdRaw =
        m['createdAt']?.toString() ?? m['created_at']?.toString() ?? '';
    final createdAt = createdRaw.isNotEmpty ? createdRaw.split('T').first : '';

    String? serviceType;
    final st = m['service_types'];
    if (st is List && st.isNotEmpty) {
      final first = st.first;
      if (first is Map) {
        final fm = Map<String, dynamic>.from(first);
        final v = fm['value']?.toString();
        final k = fm['key']?.toString() ?? '';
        serviceType = (v != null && v.isNotEmpty)
            ? v
            : k.replaceAll(RegExp('_'), ' ');
      }
    }

    final canDispute = m['can_dispute'] == true || m['can_dispute'] == 1;

    return ClaimModel(
      id: id,
      userName: userName,
      userPhone: userPhone,
      status: status,
      claimAmount: claimAmount,
      approvedAmount: approvedAmount,
      createdAt: createdAt.isNotEmpty ? createdAt : createdRaw,
      serviceType: serviceType,
      bills: const [],
      canDispute: canDispute,
    );
  }
}

class ClaimBill {
  final String billNumber;
  final String billDate;
  final double billAmount;
  final String clinicName;
  final String clinicAddress;
  final String doctorName;
  final String doctorRegistration;
  final List<String> attachments;
  final List<Map<String, dynamic>> imageFiles;

  ClaimBill({
    required this.billNumber,
    required this.billDate,
    required this.billAmount,
    required this.clinicName,
    this.clinicAddress = '',
    this.doctorName = '',
    this.doctorRegistration = '',
    this.attachments = const [],
    this.imageFiles = const [],
  });
}

class ClaimStatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  const ClaimStatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });

  static ClaimStatusConfig fromStatus(int status) {
    switch (status) {
      case 0:
        return ClaimStatusConfig(label: 'Submitted', color: Color(0xFF2196F3), icon: Icons.upload_file_outlined);
      case 1:
        return ClaimStatusConfig(label: 'Settled', color: Color(0xFF43A047), icon: Icons.check_circle_outline);
      case 2:
        return ClaimStatusConfig(label: 'Denied', color: Color(0xFFD32F2F), icon: Icons.cancel_outlined);
      case 3:
        return ClaimStatusConfig(label: 'Action Required', color: Color(0xFFE53935), icon: Icons.warning_amber_outlined);
      case 4:
        return ClaimStatusConfig(label: 'In Review', color: Color(0xFFFF9800), icon: Icons.hourglass_empty_outlined);
      case 5:
        return ClaimStatusConfig(label: 'Approved', color: Color(0xFF4CAF50), icon: Icons.thumb_up_outlined);
      case 6:
        return ClaimStatusConfig(label: 'Waiting Approval', color: Color(0xFF9C27B0), icon: Icons.schedule_outlined);
      case 7:
        return ClaimStatusConfig(label: 'Disputed', color: Color(0xFFFF5722), icon: Icons.gavel_outlined);
      case 8:
        return ClaimStatusConfig(label: 'Pending Disbursement', color: Color(0xFF00BCD4), icon: Icons.account_balance_wallet_outlined);
      default:
        return ClaimStatusConfig(label: 'All', color: Color(0xFF607D8B), icon: Icons.list_alt_rounded);
    }
  }
}
