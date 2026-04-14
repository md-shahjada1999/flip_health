import 'package:flutter/material.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/api%20services/api_urls.dart';
import 'package:flip_health/core/services/app_exception.dart';
import 'package:flip_health/controllers/gym%20controllers/gym_controller.dart';
import 'package:flip_health/model/gym%20models/gym_membership_invoice_model.dart';

class GymRepository {
  final ApiService apiService;
  GymRepository({required this.apiService});

  Future<List<MembershipPlan>> getMembershipPlans() async {
    try {
      // TODO: Replace with actual API call
      return [
        MembershipPlan(
          id: 'elite_12',
          tier: 'ELITE',
          type: 'Cult',
          months: 12,
          originalPrice: 15000,
          discountedPrice: 11000,
          tierColor: const Color(0xFFFFC85A),
          backgroundImage: 'assets/png/cult_elite_mem_banner.png',
          benefits: [
            'Yoga',
            'HRX Workout',
            'Cardio',
            'Strength Training',
            'Kick Boxing',
            'Zumba',
          ],
        ),
        MembershipPlan(
          id: 'elite_9',
          tier: 'ELITE',
          type: 'Cult',
          months: 9,
          originalPrice: 12000,
          discountedPrice: 9000,
          tierColor: const Color(0xffFF7E5A),
          backgroundImage: 'assets/png/cult_elite_mem_banner.png',
          benefits: [
            'Yoga',
            'HRX Workout',
            'Cardio',
            'Strength Training',
            'Kick Boxing',
          ],
        ),
        MembershipPlan(
          id: 'pro_6',
          tier: 'PRO',
          type: 'Cult',
          months: 6,
          originalPrice: 10000,
          discountedPrice: 6000,
          tierColor: const Color(0xFF05A3FF),
          backgroundImage: 'assets/png/cult_pro_mem_banner.png',
          benefits: ['Yoga', 'HRX Workout', 'Cardio', 'Strength Training'],
        ),
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<String>> getCities() async {
    try {
      // TODO: Replace with actual API call
      return [
        'Hyderabad',
        'Bangalore',
        'Mumbai',
        'Delhi NCR',
        'Chennai',
        'Pune',
      ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<List<GymCenter>> getCenters({required String city}) async {
    try {
      // TODO: Replace with actual API call
      final centersMap = <String, List<GymCenter>>{
        'Hyderabad': [
          const GymCenter(
            id: 'h1',
            name: 'Cult.fit Jubilee Hills',
            address: 'Road No. 36, Jubilee Hills',
            city: 'Hyderabad',
            distance: '2.3',
          ),
          const GymCenter(
            id: 'h2',
            name: 'Cult.fit Madhapur',
            address: 'Hitec City Main Road',
            city: 'Hyderabad',
            distance: '4.1',
          ),
          const GymCenter(
            id: 'h3',
            name: 'Cult.fit Gachibowli',
            address: 'Financial District',
            city: 'Hyderabad',
            distance: '6.5',
          ),
        ],
        'Bangalore': [
          const GymCenter(
            id: 'b1',
            name: 'Cult.fit Koramangala',
            address: '80 Feet Road, Koramangala',
            city: 'Bangalore',
            distance: '1.8',
          ),
          const GymCenter(
            id: 'b2',
            name: 'Cult.fit Indiranagar',
            address: '100 Feet Road, Indiranagar',
            city: 'Bangalore',
            distance: '3.2',
          ),
          const GymCenter(
            id: 'b3',
            name: 'Cult.fit HSR Layout',
            address: 'Sector 6, HSR Layout',
            city: 'Bangalore',
            distance: '5.0',
          ),
        ],
        'Mumbai': [
          const GymCenter(
            id: 'm1',
            name: 'Cult.fit Andheri',
            address: 'Lokhandwala, Andheri West',
            city: 'Mumbai',
            distance: '2.0',
          ),
          const GymCenter(
            id: 'm2',
            name: 'Cult.fit Bandra',
            address: 'Hill Road, Bandra West',
            city: 'Mumbai',
            distance: '4.5',
          ),
        ],
      };
      return centersMap[city] ??
          [
            GymCenter(
              id: 'g1',
              name: 'Cult.fit $city Central',
              address: 'Main Road, $city',
              city: city,
              distance: '3.0',
            ),
            GymCenter(
              id: 'g2',
              name: 'Cult.fit $city East',
              address: 'East Zone, $city',
              city: city,
              distance: '5.5',
            ),
          ];
    } catch (e) {
      throw AppException(message: e.toString());
    }
  }

  Future<GymMembershipInvoice> getInvoiceDetail(String id) async {
    try {
      final response = await apiService.get(ApiUrl.invoiceById(id));
      final root = response.data;
      if (root is! Map) {
        throw AppException(message: 'Invalid invoice response');
      }
      final map = Map<String, dynamic>.from(root);
      final status = map['status'];
      final ok =
          status == true ||
          status == 1 ||
          status?.toString().toLowerCase() == 'true' ||
          status?.toString() == '1' ||
          (status == null && map['data'] is Map);
      if (!ok) {
        throw AppException(
          message:
              map['message']?.toString() ?? 'Failed to load gym membership',
        );
      }
      final data = map['data'];
      if (data is! Map) {
        throw AppException(message: 'Invalid gym membership data');
      }
      return GymMembershipInvoice.fromJson(Map<String, dynamic>.from(data));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Could not load gym membership details: $e');
    }
  }

  /// Uses same endpoint as patient_app (`/gym/payment_verify`) for both pre-payment
  /// confirmation (`invoice_id`) and Razorpay verification (`payment_id` + `invoice_id`).
  Future<Map<String, dynamic>> confirmGymMembershipPayment(
    Map<String, dynamic> body,
  ) async {
    final response = await apiService.post(
      ApiUrl.GYM_OPTIN_PAYMENT_VERIFY,
      data: body,
    );
    final raw = response.data;
    if (raw is! Map) return {};
    return Map<String, dynamic>.from(raw);
  }
}
