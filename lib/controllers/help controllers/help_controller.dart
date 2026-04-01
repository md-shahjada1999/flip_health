import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/data/repositories/help_repository.dart';

class SupportTicket {
  final String id;
  final String message;
  final String status; // 'open' or 'closed'
  final DateTime createdAt;
  String? feedback;
  int? rating;

  SupportTicket({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    this.feedback,
    this.rating,
  });
}

class HelpController extends GetxController {
  final HelpRepository _repository;

  HelpController({required HelpRepository repository})
      : _repository = repository;

  final allTickets = <SupportTicket>[].obs;
  final openTickets = <SupportTicket>[].obs;
  final closedTickets = <SupportTicket>[].obs;
  final isOpenSelected = true.obs;
  final selectedTicket = Rxn<SupportTicket>();
  final issueController = TextEditingController();
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTickets();
  }

  @override
  void onClose() {
    issueController.dispose();
    super.onClose();
  }

  void toggleFilter(bool openSelected) {
    isOpenSelected.value = openSelected;
  }

  List<SupportTicket> get currentTickets =>
      isOpenSelected.value ? openTickets : closedTickets;

  Future<void> _loadTickets() async {
    allTickets.value = await _repository.getTickets();
    _splitTickets();
  }

  Future<void> createTicket(String message) async {
    if (message.trim().isEmpty) return;
    isSubmitting.value = true;

    try {
      final ticket = await _repository.createTicket(message: message);
      allTickets.insert(0, ticket);
      _splitTickets();
      isOpenSelected.value = true;
      issueController.clear();
      Get.back();
      Get.snackbar(
        'Ticket Raised',
        'Our support team will get back to you within 24 hours',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitFeedback(String ticketId, int rating, String? feedback) async {
    final idx = allTickets.indexWhere((t) => t.id == ticketId);
    if (idx == -1) return;

    await _repository.submitFeedback(
      ticketId: ticketId,
      rating: rating,
      feedback: feedback,
    );

    allTickets[idx].rating = rating;
    allTickets[idx].feedback = feedback ?? 'Rated $rating/5';
    allTickets.refresh();
    _splitTickets();
    Get.snackbar(
      'Thank you!',
      'Your feedback has been submitted',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void selectTicket(SupportTicket ticket) {
    selectedTicket.value = ticket;
  }

  void _splitTickets() {
    openTickets.assignAll(
      allTickets.where((t) => t.status == 'open').toList(),
    );
    closedTickets.assignAll(
      allTickets.where((t) => t.status == 'closed').toList(),
    );
  }
}
