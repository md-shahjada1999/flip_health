import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flip_health/core/constants/string_define.dart';
import 'package:flip_health/core/services/api%20services/api_controller.dart';
import 'package:flip_health/core/services/secure%20storage/secure_storage.dart';
import 'package:flip_health/controllers/help%20controllers/help_controller.dart';
import 'package:flip_health/data/repositories/help_repository.dart';
import 'package:flip_health/views/help/help_screen.dart';
import 'package:flip_health/controllers/mental%20wellness%20controllers/mental_wellness_controller.dart';
import 'package:flip_health/routes/app_routes.dart';

class SearchAction {
  final String title;
  final String subtitle;
  final String iconPath;
  final String category;
  final List<String> keywords;
  final VoidCallback onTap;

  const SearchAction({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.category,
    required this.keywords,
    required this.onTap,
  });
}

class SearchResult {
  final SearchAction action;
  final double score;
  const SearchResult({required this.action, required this.score});
}

class AppSearchController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final query = ''.obs;
  final results = <SearchResult>[].obs;
  final recentSearches = <String>[].obs;
  final isSearchFocused = false.obs;
  final isListening = false.obs;

  static const String _recentSearchesKey = 'recent_searches';
  late final List<SearchAction> _searchIndex;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;

  @override
  void onInit() {
    super.onInit();
    _buildIndex();
    _loadRecents();
    _initSpeech();
    debounce(query, (_) => _performSearch(), time: const Duration(milliseconds: 200));
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (_) => _stopListening(),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening.value = false;
        }
      },
    );
  }

  void toggleVoiceSearch() {
    if (isListening.value) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    if (!_speechAvailable) {
      Get.snackbar(
        'Unavailable',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isListening.value = true;
    isSearchFocused.value = true;

    _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords;
        textController.text = text;
        textController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
        query.value = text;
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  void _stopListening() {
    _speech.stop();
    isListening.value = false;
  }

  void _loadRecents() {
    final saved = AppSecureStorage.getStringListValueFromSharedPref(
      variableName: _recentSearchesKey,
    );
    if (saved != null && saved.isNotEmpty) {
      recentSearches.assignAll(saved);
    }
  }

  void _saveRecents() {
    AppSecureStorage.addStringListValueToSharedPref(
      variableName: _recentSearchesKey,
      variableValue: recentSearches.toList(),
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void onQueryChanged(String value) {
    query.value = value;
  }

  void onFocusChanged(bool focused) {
    isSearchFocused.value = focused;
  }

  void clearSearch() {
    textController.clear();
    query.value = '';
    results.clear();
  }

  void onResultTapped(SearchResult result) {
    final q = query.value.trim();
    if (q.isNotEmpty && !recentSearches.contains(q)) {
      recentSearches.insert(0, q);
      if (recentSearches.length > 8) recentSearches.removeLast();
      _saveRecents();
    }
    clearSearch();
    isSearchFocused.value = false;
    FocusManager.instance.primaryFocus?.unfocus();
    result.action.onTap();
  }

  void onRecentTapped(String recent) {
    textController.text = recent;
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: recent.length),
    );
    query.value = recent;
  }

  void removeRecent(String recent) {
    recentSearches.remove(recent);
    _saveRecents();
  }

  void clearAllRecents() {
    recentSearches.clear();
    _saveRecents();
  }

  void _performSearch() {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) {
      results.clear();
      return;
    }

    final scored = <SearchResult>[];
    for (final action in _searchIndex) {
      final s = _score(q, action);
      if (s > 0) {
        scored.add(SearchResult(action: action, score: s));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    results.assignAll(scored.take(8));
  }

  double _score(String q, SearchAction action) {
    double best = 0;

    for (final kw in action.keywords) {
      final kwLower = kw.toLowerCase();
      if (kwLower == q) return 1.0;
      if (kwLower.startsWith(q)) best = max(best, 0.85);
      if (kwLower.contains(q)) best = max(best, 0.6);
    }

    final titleLower = action.title.toLowerCase();
    if (titleLower == q) best = max(best, 0.95);
    if (titleLower.startsWith(q)) best = max(best, 0.8);
    if (titleLower.contains(q)) best = max(best, 0.55);

    final subtitleLower = action.subtitle.toLowerCase();
    if (subtitleLower.contains(q)) best = max(best, 0.3);

    return best;
  }

  void _ensureHelpControllerRegistered() {
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }
    if (!Get.isRegistered<HelpRepository>()) {
      Get.lazyPut<HelpRepository>(() => HelpRepository(apiService: Get.find()));
    }
    if (!Get.isRegistered<HelpController>()) {
      Get.lazyPut<HelpController>(() => HelpController(repository: Get.find()));
    }
  }

  void _buildIndex() {
    _searchIndex = [
      // Consultation
      SearchAction(
        title: 'Book Consultation',
        subtitle: 'Consult with a doctor at hospital or virtually',
        iconPath: AppString.kIconConsultation,
        category: 'Services',
        keywords: ['consultation', 'doctor', 'consult', 'physician', 'opd', 'hospital', 'virtual', 'appointment'],
        onTap: () => Get.toNamed(AppRoutes.consultation),
      ),

      // Diagnostics - Health Checkups
      SearchAction(
        title: 'Health Checkups',
        subtitle: 'Book free health checkups',
        iconPath: AppString.kIconDiagnostics,
        category: 'Services',
        keywords: ['health checkup', 'checkup', 'diagnostics', 'annual checkup', 'full body', 'screening'],
        onTap: () => Get.toNamed(AppRoutes.healthCheckups),
      ),

      // Diagnostics - Lab Tests
      SearchAction(
        title: 'Lab Tests',
        subtitle: 'Book diagnostic lab tests',
        iconPath: AppString.kIconDiagnostics,
        category: 'Services',
        keywords: ['lab test', 'lab', 'blood test', 'cbc', 'thyroid', 'sugar', 'cholesterol', 'urine', 'diagnostics'],
        onTap: () => Get.toNamed(AppRoutes.labTests),
      ),

      // Pharmacy
      SearchAction(
        title: 'Order Medicines',
        subtitle: 'Get medicines delivered to your door',
        iconPath: AppString.kIconPrescribedPharmacy,
        category: 'Services',
        keywords: ['pharmacy', 'medicine', 'tablet', 'drug', 'capsule', 'syrup', 'paracetamol', 'order medicine', 'prescription'],
        onTap: () => Get.toNamed(AppRoutes.pharmacy),
      ),

      // Dental
      SearchAction(
        title: 'Dental Services',
        subtitle: 'Book dental checkup or treatment',
        iconPath: AppString.kIconDental,
        category: 'Services',
        keywords: ['dental', 'dentist', 'teeth', 'tooth', 'cavity', 'cleaning', 'braces', 'root canal', 'oral'],
        onTap: () => Get.toNamed(AppRoutes.dental),
      ),

      // Vision
      SearchAction(
        title: 'Vision Services',
        subtitle: 'Eye checkup or glasses/lens',
        iconPath: AppString.kIconVision,
        category: 'Services',
        keywords: ['vision', 'eye', 'glasses', 'lens', 'contact lens', 'optician', 'lenskart', 'spectacles', 'sight'],
        onTap: () => Get.toNamed(AppRoutes.vision),
      ),

      // Vaccine
      SearchAction(
        title: 'Vaccination',
        subtitle: 'Book vaccination appointments',
        iconPath: AppString.kIconVaccination,
        category: 'Services',
        keywords: ['vaccine', 'vaccination', 'immunization', 'flu', 'hepatitis', 'covid', 'shot', 'booster'],
        onTap: () => Get.toNamed(AppRoutes.vaccine),
      ),

      // Gym
      SearchAction(
        title: 'Gym Membership',
        subtitle: 'Explore gym membership plans',
        iconPath: AppString.kIconGymFitness,
        category: 'Services',
        keywords: ['gym', 'fitness', 'workout', 'cult', 'membership', 'exercise', 'training', 'cult fit'],
        onTap: () => Get.toNamed(AppRoutes.gym),
      ),

      // Mental Wellness
      SearchAction(
        title: 'Mental Wellness',
        subtitle: 'Counselling and wellness sessions',
        iconPath: AppString.kIconMentalWellness,
        category: 'Services',
        keywords: ['mental', 'wellness', 'counselling', 'therapy', 'stress', 'anxiety', 'depression', 'psychologist', 'mental health'],
        onTap: () => Get.toNamed(
          AppRoutes.mentalWellness,
          arguments: {'from': MentalWellnessController.kFromWellness},
        ),
      ),

      // Nutrition
      SearchAction(
        title: 'Nutrition',
        subtitle: 'Diet consultation and nutrition plans',
        iconPath: AppString.kIconNutrition,
        category: 'Health',
        keywords: ['nutrition', 'diet', 'dietician', 'weight loss', 'meal plan', 'calories', 'protein', 'food'],
        onTap: () => Get.toNamed(
          AppRoutes.mentalWellness,
          arguments: {'from': MentalWellnessController.kFromNutritionist},
        ),
      ),

      // Wallet
      SearchAction(
        title: 'OPD Wallet',
        subtitle: 'Check balance, transactions & recharge',
        iconPath: AppString.kIconCalendar,
        category: 'Account',
        keywords: ['wallet', 'balance', 'recharge', 'opd', 'payment', 'money', 'transaction', 'pay'],
        onTap: () => Get.toNamed(AppRoutes.wallet),
      ),

      // Claims
      SearchAction(
        title: 'OPD Claims',
        subtitle: 'Submit and track your claims',
        iconPath: AppString.kIconClaims,
        category: 'Account',
        keywords: ['claim', 'claims', 'reimbursement', 'opd claim', 'submit claim', 'insurance'],
        onTap: () => Get.toNamed(AppRoutes.claims),
      ),

      // Bank Details
      SearchAction(
        title: 'Bank Details',
        subtitle: 'Manage your bank accounts',
        iconPath: AppString.kIconBankDetails,
        category: 'Account',
        keywords: ['bank', 'bank details', 'account', 'ifsc', 'upi', 'bank account'],
        onTap: () => Get.toNamed(AppRoutes.bankDetails),
      ),

      // Orders
      SearchAction(
        title: 'My Orders',
        subtitle: 'Track and manage your orders',
        iconPath: AppString.kIconOrdersServices,
        category: 'Account',
        keywords: ['orders', 'order', 'track', 'order status', 'my orders', 'delivery'],
        onTap: () => Get.toNamed(AppRoutes.orders),
      ),

      // Health Score
      SearchAction(
        title: 'Health Score',
        subtitle: 'Check your BMI and health score',
        iconPath: AppString.kIconDiagnostics,
        category: 'Health',
        keywords: ['health score', 'bmi', 'body mass index', 'weight', 'height', 'fitness score'],
        onTap: () => Get.toNamed(AppRoutes.healthScore),
      ),

      // Help & Support
      SearchAction(
        title: 'Help & Support',
        subtitle: 'Raise tickets and get help',
        iconPath: AppString.kIconSupport,
        category: 'Support',
        keywords: ['help', 'support', 'ticket', 'issue', 'complaint', 'contact', 'problem', 'query'],
        onTap: () {
          _ensureHelpControllerRegistered();
          Get.to(() => const HelpScreen());
        },
      ),

      // FAQ
      SearchAction(
        title: 'FAQ',
        subtitle: 'Frequently asked questions',
        iconPath: AppString.kIconFAQ,
        category: 'Support',
        keywords: ['faq', 'frequently asked', 'question', 'how to', 'guide'],
        onTap: () {
          _ensureHelpControllerRegistered();
          Get.to(() => const HelpScreen());
        },
      ),

      // Chronic Management
      SearchAction(
        title: 'Chronic Care',
        subtitle: 'Manage chronic conditions',
        iconPath: AppString.kIconChronicManagement,
        category: 'Services',
        keywords: ['chronic', 'diabetes', 'bp', 'blood pressure', 'hypertension', 'sugar', 'chronic care', 'management'],
        onTap: () => Get.toNamed(AppRoutes.allServices),
      ),

      // Address
      SearchAction(
        title: 'Add Address',
        subtitle: 'Add or manage delivery addresses',
        iconPath: AppString.kIconAddressBook,
        category: 'Account',
        keywords: ['address', 'delivery address', 'location', 'add address', 'pincode'],
        onTap: () => Get.toNamed(AppRoutes.addAddress),
      ),
    ];
  }
}
