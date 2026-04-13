import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/custom_toast.dart';
import 'package:flip_health/data/repositories/consultation_order_repository.dart';

/// Same fields as patient_app `videocall_review_popup` (overall + audio/video tech rating).
Future<void> showConsultationCallFeedbackDialog({
  required BuildContext context,
  required String appointmentId,
  required ConsultationOrderRepository repository,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ConsultationCallFeedbackDialog(
      appointmentId: appointmentId,
      repository: repository,
    ),
  );
}

class _ConsultationCallFeedbackDialog extends StatefulWidget {
  const _ConsultationCallFeedbackDialog({
    required this.appointmentId,
    required this.repository,
  });

  final String appointmentId;
  final ConsultationOrderRepository repository;

  @override
  State<_ConsultationCallFeedbackDialog> createState() =>
      _ConsultationCallFeedbackDialogState();
}

class _ConsultationCallFeedbackDialogState
    extends State<_ConsultationCallFeedbackDialog> {
  int _overall = 0;
  int _tech = 0;
  final _notes = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_overall < 1 || _tech < 1) {
      ToastCustom.showSnackBar(
        subtitle: 'Please rate your overall and audio/video experience',
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.repository.submitAppointmentCallFeedback(
        appointmentId: widget.appointmentId,
        rating: _overall,
        techRating: _tech,
        description: _notes.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ToastCustom.showSnackBar(
          subtitle: 'Thank you for your feedback',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastCustom.showSnackBar(subtitle: e.toString());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _starRow(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          label,
          fontSize: 13.rf,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: 8.rh),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final n = i + 1;
            final selected = value >= n;
            return IconButton(
              onPressed: () => onChanged(n),
              icon: Icon(
                selected ? Icons.star_rounded : Icons.star_outline_rounded,
                color: selected ? Colors.amber : AppColors.textSecondary,
                size: 32.rs,
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.rs),
      ),
      title: CommonText(
        'Rate your consultation',
        fontSize: 18.rf,
        fontWeight: FontWeight.w700,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommonText(
              'How was your overall experience?',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
            _starRow('Overall', _overall, (n) => setState(() => _overall = n)),
            SizedBox(height: 16.rh),
            CommonText(
              'How was the audio and video quality?',
              fontSize: 12.rf,
              color: AppColors.textSecondary,
            ),
            _starRow('Audio / video', _tech, (n) => setState(() => _tech = n)),
            SizedBox(height: 12.rh),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Additional comments (optional)',
                filled: true,
                fillColor: AppColors.backgroundSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.rs),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Skip'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
