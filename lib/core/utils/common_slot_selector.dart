import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

/// Reusable date + time slot selector used across Health Checkup, Lab Test,
/// and Consultation flows.
///
/// All values are plain (non-reactive). Wrap this widget in `Obx` at the
/// call-site so it rebuilds when the underlying Rx state changes.
class CommonSlotSelector extends StatelessWidget {
  final String monthYearLabel;
  final List<Map<String, String>> availableDates;
  final int selectedDateIndex;
  final ValueChanged<int> onDateSelected;
  final String selectedTimeSlot;
  final ValueChanged<String> onTimeSlotSelected;
  final List<Map<String, dynamic>> morningSlots;
  final List<Map<String, dynamic>> afternoonSlots;
  final List<Map<String, dynamic>> eveningSlots;

  /// When `>= 2`, time chips use fixed width so multiple columns fit (e.g. health checkup).
  final int slotsPerRow;

  /// Optional smaller label for dense two-column layout.
  final double? slotTimeFontSize;

  const CommonSlotSelector({
    Key? key,
    required this.monthYearLabel,
    required this.availableDates,
    required this.selectedDateIndex,
    required this.onDateSelected,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
    required this.morningSlots,
    required this.afternoonSlots,
    this.eveningSlots = const <Map<String, dynamic>>[],
    this.slotsPerRow = 1,
    this.slotTimeFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimeHeader(),
        SizedBox(height: 24.rh),
        _buildDateSelection(),
        SizedBox(height: 24.rh),
        if (morningSlots.isNotEmpty) ...[
        _buildTimeSlotSection(
          AppString.kMorning,
          Icons.wb_sunny_outlined,
          morningSlots,
        ),
        ],
           if (afternoonSlots.isNotEmpty) ...[
        SizedBox(height: 24.rh),
        _buildTimeSlotSection(
          AppString.kAfternoon,
          Icons.wb_twilight_outlined,
          afternoonSlots,
        ),
        ],
        if (eveningSlots.isNotEmpty) ...[
          SizedBox(height: 24.rh),
          _buildTimeSlotSection(
            'Evening',
            Icons.wb_twilight_outlined,
            eveningSlots,
          ),
        ],
      ],
    );
  }

  Widget _buildDateTimeHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppColors.primary, size: 20.rs),
          SizedBox(width: 8.rw),
          CommonText(
            AppString.kChooseDateAndTime,
            fontSize: 13.rf,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          const Spacer(),
          CommonText(
            monthYearLabel,
            fontSize: 13.rf,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return SizedBox(
      height: 60.rh,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.rw),
        itemCount: availableDates.length,
        itemBuilder: (context, index) {
          final date = availableDates[index];
          final isSelected = selectedDateIndex == index;

          return FadeInRight(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: 50 * index),
            child: GestureDetector(
              onTap: () => onDateSelected(index),
              child: Container(
                width: 60.rw,
                margin: EdgeInsets.only(right: 12.rw),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12.rs),
                  border: Border.all(
                    color: isSelected ? Colors.black : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonText(
                      date['day']!,
                      fontSize: 20.rf,
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? Colors.white : AppColors.textPrimary,
                      height: 1.3,
                    ),
                    SizedBox(height: 4.rh),
                    CommonText(
                      date['weekday']!,
                      fontSize: 11.rf,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotSection(
    String title,
    IconData icon,
    List<Map<String, dynamic>> slots,
  ) {
    if (slots.isEmpty) return const SizedBox.shrink();

    final fs = slotTimeFontSize ?? 12.rf;
    final dense = slotsPerRow >= 2;
    final hPad = dense ? 10.rw : 18.rw;
    final vPad = dense ? 6.rh : 8.rh;

    Widget slotChip(Map<String, dynamic> slot) {
      final isSelected = selectedTimeSlot == slot['time'];
      final isDisabled = slot['isDisabled'] ?? false;
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: isDisabled ? null : () => onTimeSlotSelected(slot['time']),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.black
                  : isDisabled
                      ? AppColors.backgroundTertiary
                      : Colors.white,
              borderRadius: BorderRadius.circular(25.rs),
              border: Border.all(
                color: isSelected ? Colors.black : AppColors.borderLight,
              ),
            ),
            child: CommonText(
              '${slot['time']}',
              fontSize: fs,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              color: isSelected
                  ? Colors.white
                  : isDisabled
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18.rs),
              SizedBox(width: 8.rw),
              CommonText(
                title,
                fontSize: 12.rf,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ],
          ),
          SizedBox(height: 12.rh),
          if (dense)
            LayoutBuilder(
              builder: (context, constraints) {
                final n = slotsPerRow.clamp(2, 8);
                final gap = 10.rw;
                final w =
                    (constraints.maxWidth - gap * (n - 1)) / n;
                return Wrap(
                  spacing: gap,
                  runSpacing: 10.rh,
                  children: slots
                      .map(
                        (slot) => SizedBox(
                          width: w,
                          child: Center(child: slotChip(slot)),
                        ),
                      )
                      .toList(),
                );
              },
            )
          else
            Wrap(
              spacing: 12.rw,
              runSpacing: 12.rh,
              children: slots.map(slotChip).toList(),
            ),
        ],
      ),
    );
  }
}
