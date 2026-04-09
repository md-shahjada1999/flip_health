import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_app_bar.dart';
import 'package:flip_health/core/utils/common_pdf_viewer.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';
import 'package:flip_health/model/support%20models/ticket_message_model.dart';

class HelpTicketDetailScreen extends StatefulWidget {
  const HelpTicketDetailScreen({super.key});

  @override
  State<HelpTicketDetailScreen> createState() => _HelpTicketDetailScreenState();
}

class _HelpTicketDetailScreenState extends State<HelpTicketDetailScreen> {
  final _scrollController = ScrollController();

  HelpController get _controller => Get.find<HelpController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchMessages();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _controller.loadMoreMessages();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      resizeToAvoidBottomInset: true,
      appBar: CommonAppBar.build(
        title: 'Ticket Details',
        actions: [
          Obx(() {
            final ticket = _controller.selectedTicket.value;
            if (ticket == null) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(right: 16.rw),
              child: _StatusChip(status: ticket.status),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      final isLoading = _controller.messagesLoading.value;
      final msgs = _controller.messages;

      if (isLoading && msgs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (msgs.isEmpty) {
        return Center(
          child: CommonText(
            'No messages yet',
            fontSize: 14.rf,
            color: AppColors.textSecondary,
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: EdgeInsets.symmetric(horizontal: 14.rw, vertical: 10.rh),
        itemCount: msgs.length + (_controller.messagesLoading.value ? 1 : 0),
        itemBuilder: (_, index) {
          if (index == msgs.length) {
            return Padding(
              padding: EdgeInsets.all(16.rs),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _MessageBubble(message: msgs[index]);
        },
      );
    });
  }

  Widget _buildBottomBar() {
    return Obx(() {
      final ticket = _controller.selectedTicket.value;
      if (ticket == null) return const SizedBox.shrink();

      final isClosed = ticket.isClosed;
      final canReopen = ticket.canReopen;

      if (isClosed && !canReopen) {
        return _ClosedBanner(
          ticket: ticket,
          controller: _controller,
        );
      }

      if (isClosed && canReopen) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReopenBanner(controller: _controller),
            _InputBar(controller: _controller),
          ],
        );
      }

      return _InputBar(controller: _controller);
    });
  }
}

// ──────────────────────────────────────────────────────────────
// Status Chip
// ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final int status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      0 => 'Created',
      1 => 'Open',
      2 => 'Closed',
      _ => 'Unknown',
    };
    final color = switch (status) {
      0 => AppColors.info,
      1 => AppColors.success,
      2 => AppColors.textSecondary,
      _ => AppColors.textSecondary,
    };
    final bgColor = switch (status) {
      0 => AppColors.infoLight,
      1 => AppColors.successLight,
      _ => AppColors.backgroundSecondary,
    };

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.rs),
        ),
        child: CommonText(
          label,
          fontSize: 11.rf,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Message Bubble
// ──────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final TicketMessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) return _buildSystemMessage();
    final isPatient = message.isFromPatient;
    return _buildChatBubble(isPatient);
  }

  Widget _buildSystemMessage() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.rh),
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12.rs),
      ),
      child: Column(
        children: [
          CommonText(
            message.displayMessage,
            fontSize: 12.rf,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          if (message.createdAt != null) ...[
            SizedBox(height: 4.rh),
            CommonText(
              _formatTime(message.createdAt!),
              fontSize: 10.rf,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isPatient) {
    return Align(
      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.rw),
        margin: EdgeInsets.only(
          top: 4.rh,
          bottom: 4.rh,
          left: isPatient ? 48.rw : 0,
          right: isPatient ? 0 : 48.rw,
        ),
        child: Column(
          crossAxisAlignment:
              isPatient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isPatient && message.userName != null)
              Padding(
                padding: EdgeInsets.only(left: 4.rw, bottom: 2.rh),
                child: CommonText(
                  message.userName!,
                  fontSize: 10.rf,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.rw,
                vertical: 10.rh,
              ),
              decoration: BoxDecoration(
                color: isPatient ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.rs),
                  topRight: Radius.circular(16.rs),
                  bottomLeft: Radius.circular(isPatient ? 16.rs : 4.rs),
                  bottomRight: Radius.circular(isPatient ? 4.rs : 16.rs),
                ),
                border: isPatient
                    ? null
                    : Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: message.isImage
                  ? _buildImageContent(isPatient)
                  : message.isPdf
                      ? _buildPdfContent(isPatient)
                      : CommonText(
                          message.displayMessage,
                          fontSize: 13.rf,
                          color:
                              isPatient ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
            ),
            if (message.createdAt != null)
              Padding(
                padding: EdgeInsets.only(top: 3.rh, left: 4.rw, right: 4.rw),
                child: CommonText(
                  _formatTime(message.createdAt!),
                  fontSize: 10.rf,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(bool isPatient) {
    final url = message.imagePath;
    return GestureDetector(
      onTap: url != null
          ? () => Get.dialog(
                _FullImageDialog(url: url),
                barrierColor: Colors.black87,
              )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (url != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.rs),
              child: Image.network(
                url,
                width: 180.rw,
                height: 140.rh,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 180.rw,
                  height: 60.rh,
                  decoration: BoxDecoration(
                    color: isPatient
                        ? Colors.white24
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8.rs),
                  ),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color:
                        isPatient ? Colors.white70 : AppColors.textSecondary,
                    size: 28.rs,
                  ),
                ),
              ),
            ),
          SizedBox(height: 4.rh),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attachment_rounded,
                size: 14.rs,
                color: isPatient ? Colors.white70 : AppColors.textSecondary,
              ),
              SizedBox(width: 4.rw),
              Flexible(
                child: CommonText(
                  message.displayMessage,
                  fontSize: 11.rf,
                  color: isPatient ? Colors.white70 : AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPdfContent(bool isPatient) {
    final url = message.fileUrl;
    final title = message.displayMessage;
    return GestureDetector(
      onTap: url != null
          ? () => Get.to(() => CommonPdfViewer(url: url, title: title))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.rs),
            decoration: BoxDecoration(
              color: isPatient ? Colors.white24 : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.rs),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: isPatient ? Colors.white : AppColors.primary,
              size: 26.rs,
            ),
          ),
          SizedBox(width: 10.rw),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  title.isNotEmpty ? title : 'PDF Document',
                  fontSize: 12.rf,
                  fontWeight: FontWeight.w600,
                  color: isPatient ? Colors.white : AppColors.textPrimary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.rh),
                CommonText(
                  'Tap to view',
                  fontSize: 10.rf,
                  color: isPatient ? Colors.white70 : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat('hh:mm a').format(dt);
    if (diff.inDays == 1) return 'Yesterday ${DateFormat('hh:mm a').format(dt)}';
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }
}

// ──────────────────────────────────────────────────────────────
// Full Image Dialog
// ──────────────────────────────────────────────────────────────

class _FullImageDialog extends StatelessWidget {
  final String url;
  const _FullImageDialog({required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.broken_image_outlined,
              color: Colors.white70,
              size: 48.rs,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Input Bar
// ──────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final HelpController controller;
  const _InputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.rw,
        right: 8.rw,
        top: 8.rh,
        bottom: MediaQuery.of(context).padding.bottom + 8.rh,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Obx(() {
            final uploading = controller.isUploading.value;
            return GestureDetector(
              onTap: uploading ? null : controller.pickAndSendAttachment,
              child: Container(
                padding: EdgeInsets.all(8.rs),
                child: uploading
                    ? SizedBox(
                        width: 22.rs,
                        height: 22.rs,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.attach_file_rounded,
                        color: AppColors.textSecondary,
                        size: 22.rs,
                      ),
              ),
            );
          }),
          SizedBox(width: 4.rw),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              style: TextStyle(fontSize: 14.rf),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  fontSize: 13.rf,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.rs),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.rs),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.rs),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.rw,
                  vertical: 10.rh,
                ),
                filled: true,
                fillColor: AppColors.backgroundSecondary,
              ),
            ),
          ),
          SizedBox(width: 6.rw),
          Obx(() {
            final sending = controller.isSending.value;
            return GestureDetector(
              onTap: sending
                  ? null
                  : () {
                      final text = controller.messageController.text;
                      if (text.trim().isNotEmpty) {
                        controller.sendMessage(text);
                      }
                    },
              child: Container(
                padding: EdgeInsets.all(10.rs),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: sending
                    ? SizedBox(
                        width: 20.rs,
                        height: 20.rs,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20.rs,
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Reopen Banner
// ──────────────────────────────────────────────────────────────

class _ReopenBanner extends StatelessWidget {
  final HelpController controller;
  const _ReopenBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 10.rh),
      color: AppColors.warningLight,
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 18.rs),
          SizedBox(width: 8.rw),
          Expanded(
            child: CommonText(
              'This ticket is closed. Send a message to reopen.',
              fontSize: 12.rf,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Closed Banner (no reopen)
// ──────────────────────────────────────────────────────────────

class _ClosedBanner extends StatelessWidget {
  final dynamic ticket;
  final HelpController controller;
  const _ClosedBanner({required this.ticket, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.rw,
        right: 16.rw,
        top: 12.rh,
        bottom: MediaQuery.of(context).padding.bottom + 12.rh,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textSecondary,
            size: 18.rs,
          ),
          SizedBox(width: 8.rw),
          Expanded(
            child: CommonText(
              'This ticket has been closed',
              fontSize: 13.rf,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
