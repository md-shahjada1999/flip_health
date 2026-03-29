import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/common_text.dart';

class SortBottomSheet extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  static const List<String> sortOptions = [
    'Relevance',
    'Distance',
    'Experience',
    'Consultation Fees(Low to High)',
    'Consultation Fees(High to Low)',
  ];

  const SortBottomSheet({
    Key? key,
    required this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  static void show({
    required BuildContext context,
    required String selectedOption,
    required ValueChanged<String> onOptionSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SortBottomSheet(
        selectedOption: selectedOption,
        onOptionSelected: onOptionSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.rs)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.rh),
          Container(
            width: 40.rw,
            height: 4.rh,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2.rs),
            ),
          ),
          SizedBox(height: 16.rh),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.rw),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CommonText(
                'Sort List',
                fontSize: 18.rf,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 8.rh),
          ...sortOptions.map((option) => _buildOptionTile(option)),
          SizedBox(height: 16.rh),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String option) {
    final isSelected = option == selectedOption;

    return InkWell(
      onTap: () {
        onOptionSelected(option);
        Get.back();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 14.rh),
        child: Row(
          children: [
            Expanded(
              child: CommonText(
                option,
                fontSize: 14.rf,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            Container(
              width: 22.rs,
              height: 22.rs,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.rs,
                        height: 12.rs,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
