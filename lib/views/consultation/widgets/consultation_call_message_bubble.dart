import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

/// Chat bubble styled like [HelpTicketDetailScreen] / [_MessageBubble] for doctor–patient chat.
class ConsultationCallMessageBubble extends StatelessWidget {
  const ConsultationCallMessageBubble({
    super.key,
    required this.text,
    required this.isPatient,
    this.timeLabel,
    this.imageUrl,
    this.onAttachmentTap,
    this.attachmentIcon,
  });

  final String text;
  final bool isPatient;
  final String? timeLabel;

  /// When set, shows an image above [text] (for in-call chat attachments).
  final String? imageUrl;

  /// PDF / file open — e.g. [url_launcher].
  final VoidCallback? onAttachmentTap;
  final IconData? attachmentIcon;

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: text.trim().isEmpty ? 0 : 8.rh),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.rs),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl!,
                          width: 200.rw,
                          height: 140.rh,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 200.rw,
                            height: 100.rh,
                            color: isPatient
                                ? Colors.white24
                                : AppColors.backgroundSecondary,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 200.rw,
                            height: 60.rh,
                            color: AppColors.backgroundSecondary,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: isPatient
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (onAttachmentTap != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onAttachmentTap,
                        borderRadius: BorderRadius.circular(8.rs),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.rh),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                attachmentIcon ?? Icons.picture_as_pdf_outlined,
                                size: 22.rs,
                                color: isPatient
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                              SizedBox(width: 8.rw),
                              Flexible(
                                child: CommonText(
                                  text,
                                  fontSize: 13.rf,
                                  color: isPatient
                                      ? Colors.white
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: isPatient
                                        ? Colors.white70
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (text.trim().isNotEmpty)
                    CommonText(
                      text,
                      fontSize: 13.rf,
                      color: isPatient ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                ],
              ),
            ),
            if (timeLabel != null && timeLabel!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 3.rh, left: 4.rw, right: 4.rw),
                child: CommonText(
                  timeLabel!,
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
}
