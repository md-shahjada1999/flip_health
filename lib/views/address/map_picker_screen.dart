import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flip_health/controllers/address%20controllers/add_address_controller.dart';
import 'package:flip_health/core/constants/app_colors.dart';
import 'package:flip_health/core/helpers/responsive_helpers.dart';
import 'package:flip_health/core/services/google%20places/place_prediction.dart';
import 'package:flip_health/core/utils/common_text.dart';
import 'package:flip_health/core/utils/safe_screen_wrapper.dart';
import 'package:flip_health/routes/app_routes.dart';

class MapPickerScreen extends GetView<AddAddressController> {
  const MapPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScreenWrapper(
      resizeToAvoidBottomInset: false,
      bottomSafe: false,
      body: Stack(
        children: [
          // Google Map
          Obx(() => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.selectedLatLng.value,
                  zoom: 16,
                ),
                onMapCreated: controller.onMapCreated,
                onCameraIdle: () {
                  controller.mapController
                      ?.getVisibleRegion()
                      .then((bounds) {
                    final center = LatLng(
                      (bounds.northeast.latitude + bounds.southwest.latitude) /
                          2,
                      (bounds.northeast.longitude +
                              bounds.southwest.longitude) /
                          2,
                    );
                    controller.onCameraIdle(center);
                  });
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              )),

          // Center pin (fixed in the center of the map)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Icon(
                Icons.location_pin,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),

          // Top bar: back button + search
          Column(
            children: [
              _buildTopBar(context),
              // Search results overlay
              Obx(() {
                if (controller.searchResults.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildSearchResults();
              }),
            ],
          ),

          // Current location FAB
          Positioned(
            right: 16,
            bottom: 220,
            child: FloatingActionButton.small(
              heroTag: 'currentLocation',
              backgroundColor: Colors.white,
              onPressed: controller.useCurrentLocation,
              child: Obx(() => controller.isLoadingLocation.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(Icons.my_location, color: AppColors.primary)),
            ),
          ),

          // Bottom address card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.rs, vertical: 12.rs),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.rw,
              height: 40.rh,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.rs),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          SizedBox(width: 12.rw),
          // Search bar
          Expanded(
            child: Container(
              height: 48.rh,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.rs),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchTextController,
                onChanged: controller.onSearchChanged,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.rf,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for area, street name...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.rf,
                    color: AppColors.textQuaternary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textTertiary,
                    size: 20.rs,
                  ),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return GestureDetector(
                        onTap: controller.clearSearch,
                        child: Icon(
                          Icons.close,
                          color: AppColors.textTertiary,
                          size: 18.rs,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.rs, vertical: 14.rs),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.rs),
      constraints: BoxConstraints(maxHeight: 280.rh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.rs),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8.rs),
            itemCount: controller.searchResults.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final prediction = controller.searchResults[index];
              return _SearchResultTile(
                prediction: prediction,
                onTap: () => controller.selectSearchResult(prediction),
              );
            },
          )),
    );
  }

  Widget _buildBottomCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.rs),
          topRight: Radius.circular(24.rs),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeBottomPadding(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.rs, 20.rs, 20.rs, 16.rs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location icon + address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.rw,
                    height: 40.rh,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10.rs),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 22.rs,
                    ),
                  ),
                  SizedBox(width: 12.rw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'Selected Location',
                          fontSize: 12.rf,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 4.rh),
                        Obx(() => controller.isReverseGeocoding.value
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 8.rw),
                                  CommonText(
                                    'Finding address...',
                                    fontSize: 14.rf,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              )
                            : CommonText(
                                controller.currentAddress.value.isEmpty
                                    ? 'Move the map to select a location'
                                    : controller.currentAddress.value,
                                fontSize: 14.rf,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.rh),
              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 52.rh,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.currentAddress.value.isEmpty ||
                              controller.isReverseGeocoding.value
                          ? null
                          : () => Get.toNamed(AppRoutes.addressForm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.textQuaternary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.rs),
                        ),
                      ),
                      child: CommonText(
                        'Confirm Location',
                        fontSize: 16.rf,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final PlacePrediction prediction;
  final VoidCallback onTap;

  const _SearchResultTile({required this.prediction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.rs, vertical: 12.rs),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20.rs,
              color: AppColors.textTertiary,
            ),
            SizedBox(width: 12.rw),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    prediction.mainText,
                    fontSize: 14.rf,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (prediction.secondaryText.isNotEmpty) ...[
                    SizedBox(height: 2.rh),
                    CommonText(
                      prediction.secondaryText,
                      fontSize: 12.rf,
                      color: AppColors.textTertiary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
