import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/utils/print_log.dart';
import 'package:flip_health/data/repositories/help_repository.dart';
import 'package:flip_health/model/support%20models/ticket_message_model.dart';
import 'package:flip_health/model/support%20models/ticket_model.dart';

class HelpController extends GetxController {
  final HelpRepository _repository;

  HelpController({required HelpRepository repository})
      : _repository = repository;

  // --- Ticket list state ---
  final allTickets = <TicketModel>[].obs;
  final openTickets = <TicketModel>[].obs;
  final closedTickets = <TicketModel>[].obs;
  final isOpenSelected = true.obs;
  final isLoading = false.obs;
  final selectedTicket = Rxn<TicketModel>();
  final issueController = TextEditingController();
  final isSubmitting = false.obs;
  final selectedLanguage = Rxn<String>();

  static const List<String> supportedLanguages = [
    'English',
    'Hindi',
    'Telugu',
    'Kannada',
    'Tamil',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Gujarati',
  ];

  // --- Chat / messages state ---
  final messages = <TicketMessageModel>[].obs;
  final messagesLoading = false.obs;
  final isSending = false.obs;
  final isUploading = false.obs;
  int _currentPage = 1;
  bool _hasMoreMessages = true;
  final messageController = TextEditingController();

  List<TicketModel> get currentTickets =>
      isOpenSelected.value ? openTickets : closedTickets;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  void toggleFilter(bool openSelected) {
    isOpenSelected.value = openSelected;
  }

  // ──────────────────── Tickets ────────────────────

  Future<void> loadTickets() async {
    isLoading.value = true;
    try {
      allTickets.value = await _repository.getTickets();
      _splitTickets();
    } catch (e) {
      PrintLog.printLog('HelpController.loadTickets error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTicket(String message) async {
    if (message.trim().isEmpty) return;
    isSubmitting.value = true;

    try {
      final result = await _repository.createTicket(
        message: message,
        language: selectedLanguage.value ?? 'English',
      );
      issueController.clear();
      selectedLanguage.value = null;
      Get.back();
      Get.snackbar(
        'Ticket Raised',
        result['message']?.toString() ??
            'Our support team will get back to you shortly',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      await loadTickets();
      isOpenSelected.value = true;
    } catch (e) {
      PrintLog.printLog('HelpController.createTicket error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void selectTicket(TicketModel ticket) {
    selectedTicket.value = ticket;
    messages.clear();
    _currentPage = 1;
    _hasMoreMessages = true;
  }

  // ──────────────────── Messages / Chat ────────────────────

  Future<void> fetchMessages({int page = 1}) async {
    final ticket = selectedTicket.value;
    if (ticket == null) return;

    if (page == 1) messagesLoading.value = true;

    try {
      final fetched = await _repository.getTicketMessages(
        ticket.id,
        page: page,
      );
      if (page == 1) {
        messages.assignAll(fetched);
      } else {
        messages.addAll(fetched);
      }
      _currentPage = page;
      _hasMoreMessages = fetched.isNotEmpty;

      _syncTicketStatus(fetched);
    } catch (e) {
      PrintLog.printLog('HelpController.fetchMessages error: $e');
    } finally {
      messagesLoading.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (!_hasMoreMessages || messagesLoading.value) return;
    await fetchMessages(page: _currentPage + 1);
  }

  Future<void> sendMessage(String text) async {
    final ticket = selectedTicket.value;
    if (ticket == null || text.trim().isEmpty) return;

    isSending.value = true;
    try {
      final msg = await _repository.sendMessage(ticket.id, text.trim());
      if (msg != null) {
        messages.insert(0, msg);
      }
      messageController.clear();
    } catch (e) {
      PrintLog.printLog('HelpController.sendMessage error: $e');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickAndSendAttachment() async {
    final ticket = selectedTicket.value;
    if (ticket == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.first.path;
    if (filePath == null) return;

    isUploading.value = true;
    try {
      final uploadData = await _repository.uploadFile(filePath);
      if (uploadData == null) {
        Get.snackbar(
          'Upload Failed',
          'Could not upload file',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      final msg = await _repository.sendAttachment(ticket.id, uploadData);
      if (msg != null) {
        messages.insert(0, msg);
      }
    } catch (e) {
      PrintLog.printLog('HelpController.pickAndSendAttachment error: $e');
    } finally {
      isUploading.value = false;
    }
  }

  // ──────────────────── Feedback ────────────────────

  Future<void> submitFeedback(
    String ticketId,
    int rating,
    String? description,
  ) async {
    try {
      await _repository.submitFeedback(
        ticketId: ticketId,
        rating: rating,
        description: description,
      );

      final idx = allTickets.indexWhere((t) => t.id == ticketId);
      if (idx != -1) {
        await loadTickets();
      }

      Get.snackbar(
        'Thank you!',
        'Your feedback has been submitted',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      PrintLog.printLog('HelpController.submitFeedback error: $e');
    }
  }

  // ──────────────────── Helpers ────────────────────

  void _splitTickets() {
    openTickets.assignAll(
      allTickets.where((t) => t.status == 0 || t.status == 1).toList(),
    );
    closedTickets.assignAll(
      allTickets.where((t) => t.status == 2).toList(),
    );
  }

  /// If the messages payload includes ticket-level entries (with status), keep our local ticket in sync.
  void _syncTicketStatus(List<TicketMessageModel> fetched) {
    for (final msg in fetched) {
      if (msg.status != null && msg.canReopen != null) {
        final t = selectedTicket.value;
        if (t != null && t.id == msg.id) {
          selectedTicket.value = TicketModel(
            id: t.id,
            canReopen: msg.canReopen ?? t.canReopen,
            type: t.type,
            subType: t.subType,
            message: t.message,
            userId: t.userId,
            userType: t.userType,
            assignedTo: t.assignedTo,
            assignedBy: t.assignedBy,
            status: msg.status ?? t.status,
            language: t.language,
            priority: t.priority,
            createdAt: t.createdAt,
            updatedAt: t.updatedAt,
            feedback: t.feedback,
          );
        }
      }
    }
  }
}
