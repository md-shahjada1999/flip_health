import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flip_health/controllers/address%20controllers/address_controller.dart';
import 'package:flip_health/controllers/dashboard%20controllers/dashboard_controller.dart';
import 'package:flip_health/controllers/search%20controllers/search_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/utils/address_selection_sheet.dart';
import 'package:flip_health/routes/app_routes.dart';
import 'package:flip_health/views/dashboard/widgets/dash_board_searchbar.dart';
import 'package:flip_health/views/dashboard/widgets/dashboard_banner.dart';
import 'package:flip_health/views/dashboard/widgets/dashboard_header.dart';
import 'package:flip_health/views/dashboard/widgets/search_overlay.dart';
import 'package:flip_health/views/dashboard/widgets/service_grid.dart';
import 'package:flip_health/views/dashboard/widgets/view_more_button.dart';

class DashboardHomeScreen extends StatefulWidget {
  DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final DashboardController _dashboardController =
      Get.find<DashboardController>();
  final AddressController _addressController = Get.find<AddressController>();
  late final AppSearchController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AppSearchController>()) {
      Get.put(AppSearchController());
    }
    _searchController = Get.find<AppSearchController>();

    _searchFocusNode.addListener(() {
      _searchController.onFocusChanged(_searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      builder: (context, screenType) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: GestureDetector(
            onTap: () {
              _searchFocusNode.unfocus();
              _searchController.onFocusChanged(false);
            },
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                Obx(() => DashboardHeader(
                      address: _addressController.displayAddress,
                      onAddressPressed: () {
                        AddressSelectionSheet.show(context);
                      },
                      onCalendarPressed: () {
                        Get.toNamed(AppRoutes.wallet);
                      },
                      onProfilePressed: () {
                        Get.toNamed(AppRoutes.profile);
                      },
                    )),
                RSizedBox.vertical(20),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          Obx(() => DashboardSearchBar(
                            controller: _searchController.textController,
                            focusNode: _searchFocusNode,
                            onChanged: _searchController.onQueryChanged,
                            isListening: _searchController.isListening.value,
                            onClear: () {
                              _searchController.clearSearch();
                              _searchFocusNode.unfocus();
                              _searchController.onFocusChanged(false);
                            },
                            onVoicePressed: _searchController.toggleVoiceSearch,
                          )),
                          RSizedBox.vertical(12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ServicesGrid(
                                      services: _dashboardController.services),
                                  RSizedBox.vertical(16),
                                  ViewMoreButton(
                                    onPressed: () {
                                      Get.toNamed(AppRoutes.allServices);
                                    },
                                  ),
                                  RSizedBox.vertical(24),
                                  NutritionBanner(onJoinPressed: () {}),
                                  RSizedBox.vertical(24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 54.rh,
                        left: 0,
                        right: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: SearchOverlay(controller: _searchController),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
