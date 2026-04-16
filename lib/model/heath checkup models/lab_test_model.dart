import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Lab Test / Package (from GET /diagnostics/packages)
// ---------------------------------------------------------------------------

class LabTest {
  final int id;
  final String name;
  final String? tags;
  final String type;
  final String category;
  final int fastingTime;
  final int tat;

  const LabTest({
    required this.id,
    required this.name,
    this.tags,
    required this.type,
    required this.category,
    required this.fastingTime,
    required this.tat,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tags: json['tags'] as String?,
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      fastingTime: json['fasting_time'] as int? ?? 0,
      tat: json['tat'] as int? ?? 0,
    );
  }

  String get fastingLabel => fastingTime > 0
      ? '$fastingTime hrs Fasting Required'
      : 'No Fasting Required';

  String get tatLabel {
    if (tat <= 0) return '';
    if (tat < 24) return 'Reports in $tat hrs';
    final days = tat ~/ 24;
    return days == 1 ? 'Reports in 1 day' : 'Reports in $days days';
  }
}

// ---------------------------------------------------------------------------
// Vendor + pricing (from POST /diagnostics/packages/pricing)
// ---------------------------------------------------------------------------

class VendorPricing {
  final int id;
  final int parameterCount;
  final double b2cPrice;

  const VendorPricing({
    required this.id,
    required this.parameterCount,
    required this.b2cPrice,
  });

  factory VendorPricing.fromJson(Map<String, dynamic> json) {
    return VendorPricing(
      id: json['id'] as int,
      parameterCount: json['parameter_count'] as int? ?? 0,
      b2cPrice: (json['b2c_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class VendorPackage {
  final int id;
  final String name;
  final String? tags;
  final String type;
  final String category;
  final int fastingTime;
  final int tat;
  final VendorPricing? pricing;

  const VendorPackage({
    required this.id,
    required this.name,
    this.tags,
    required this.type,
    required this.category,
    required this.fastingTime,
    required this.tat,
    this.pricing,
  });

  factory VendorPackage.fromJson(Map<String, dynamic> json) {
    return VendorPackage(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tags: json['tags'] as String?,
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      fastingTime: json['fasting_time'] as int? ?? 0,
      tat: json['tat'] as int? ?? 0,
      pricing: json['pricing'] != null
          ? VendorPricing.fromJson(json['pricing'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LabVendor {
  final int id;
  final String name;
  final String code;
  final String? logo;
  final List<VendorPackage> packages;

  const LabVendor({
    required this.id,
    required this.name,
    required this.code,
    this.logo,
    required this.packages,
  });

  factory LabVendor.fromJson(Map<String, dynamic> json) {
    return LabVendor(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      logo: json['logo'] as String?,
      packages: (json['packages'] as List<dynamic>?)
              ?.map((e) => VendorPackage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  double get totalPrice =>
      packages.fold(0.0, (sum, p) => sum + (p.pricing?.b2cPrice ?? 0));
}

// ---------------------------------------------------------------------------
// Slots (from POST /diagnostics/slots)
// ---------------------------------------------------------------------------

class LabSlot {
  final String slotId;
  final String vendorCode;
  final String slotDate;
  final String startTime;
  final String endTime;

  const LabSlot({
    required this.slotId,
    required this.vendorCode,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
  });

  factory LabSlot.fromJson(Map<String, dynamic> json) {
    return LabSlot(
      slotId: json['slot_id']?.toString() ?? '',
      vendorCode: json['vendor_code'] as String? ?? '',
      slotDate: json['slot_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
    );
  }

  String get displayTime => '$startTime - $endTime';
}

class LabSlotsResponse {
  final List<LabSlot> morning;
  final List<LabSlot> afternoon;
  final List<LabSlot> evening;

  const LabSlotsResponse({
    required this.morning,
    required this.afternoon,
    required this.evening,
  });

  factory LabSlotsResponse.fromJson(Map<String, dynamic> json) {
    List<LabSlot> parseSlots(dynamic list) => (list as List<dynamic>?)
            ?.map((e) => LabSlot.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return LabSlotsResponse(
      morning: parseSlots(json['morning']),
      afternoon: parseSlots(json['afternoon']),
      evening: parseSlots(json['evening']),
    );
  }
}

// ---------------------------------------------------------------------------
// Cart (from GET /cart/lab)
// ---------------------------------------------------------------------------

class CartProduct {
  final int id;
  final String name;
  final String category;
  final int tat;
  final int fastingTime;

  const CartProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.tat,
    required this.fastingTime,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      tat: json['tat'] as int? ?? 0,
      fastingTime: json['fasting_time'] as int? ?? 0,
    );
  }
}

class LabCartItem {
  final int id;
  final String productId;
  final int patientId;
  final int qty;
  final String type;
  final String vendorCode;
  final CartProduct? product;
  final double? amount;
  final bool free;

  const LabCartItem({
    required this.id,
    required this.productId,
    required this.patientId,
    required this.qty,
    required this.type,
    required this.vendorCode,
    this.product,
    this.amount,
    required this.free,
  });

  factory LabCartItem.fromJson(Map<String, dynamic> json) {
    return LabCartItem(
      id: json['id'] as int,
      productId: json['product_id']?.toString() ?? '',
      patientId: json['patient_id'] as int? ?? 0,
      qty: json['qty'] as int? ?? 1,
      type: json['type'] as String? ?? '',
      vendorCode: json['vendor_code'] as String? ?? '',
      product: json['product'] != null
          ? CartProduct.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      amount: (json['amount'] as num?)?.toDouble(),
      free: json['free'] == true,
    );
  }
}

class CartWallet {
  final double total;
  final double available;
  final double moduleAvailable;

  const CartWallet({
    required this.total,
    required this.available,
    required this.moduleAvailable,
  });

  factory CartWallet.fromJson(Map<String, dynamic> json) {
    return CartWallet(
      total: (json['total'] as num?)?.toDouble() ?? 0,
      available: (json['available'] as num?)?.toDouble() ?? 0,
      moduleAvailable: (json['module_available'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CartPricing {
  final double? mrp;
  final double? price;
  final double? pendingAmount;
  final bool isPaymentRequired;
  final double collectionFee;
  final CartWallet? wallet;
  final bool mrpStatus;

  const CartPricing({
    this.mrp,
    this.price,
    this.pendingAmount,
    required this.isPaymentRequired,
    required this.collectionFee,
    this.wallet,
    required this.mrpStatus,
  });

  factory CartPricing.fromJson(Map<String, dynamic> json) {
    return CartPricing(
      mrp: (json['mrp'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      pendingAmount: (json['pending_amount'] as num?)?.toDouble(),
      isPaymentRequired: json['isPaymentRequired'] == true,
      collectionFee: (json['collection_fee'] as num?)?.toDouble() ?? 0,
      wallet: json['wallet'] != null
          ? CartWallet.fromJson(json['wallet'] as Map<String, dynamic>)
          : null,
      mrpStatus: json['mrp_status'] == true,
    );
  }
}

class LabCartResponse {
  final List<LabCartItem> items;
  final CartPricing? pricing;

  const LabCartResponse({required this.items, this.pricing});

  factory LabCartResponse.fromJson(Map<String, dynamic> json) {
    return LabCartResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => LabCartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pricing: json['pricing'] != null
          ? CartPricing.fromJson(json['pricing'] as Map<String, dynamic>)
          : null,
    );
  }

  int get itemCount => items.length;
}

// Booking APIs may return numeric fields as JSON strings — avoid `as int` casts.
int _parseBookingInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final p = int.tryParse(v.trim());
    if (p != null) return p;
  }
  return fallback;
}

int? _parseBookingIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

// ---------------------------------------------------------------------------
// Booking Overview / Order (POST /diagnostics/order/booking)
// ---------------------------------------------------------------------------

class BookingAddress {
  final String tag;
  final String displayAddress;
  final String? coordinates;
  final String pincode;
  final String? state;
  final String? id;

  const BookingAddress({
    required this.tag,
    required this.displayAddress,
    this.coordinates,
    required this.pincode,
    this.state,
    this.id,
  });

  factory BookingAddress.fromJson(Map<String, dynamic> json) {
    return BookingAddress(
      tag: json['tag'] as String? ?? '',
      displayAddress: json['display_address'] as String? ?? '',
      coordinates: json['coordinates'] as String?,
      pincode: json['pincode']?.toString() ?? '',
      state: json['state'] as String?,
      id: json['id'] as String?,
    );
  }
}

class BookingItemVendor {
  final int id;
  final String name;
  final String? logo;
  final String code;

  const BookingItemVendor({
    required this.id,
    required this.name,
    this.logo,
    required this.code,
  });

  factory BookingItemVendor.fromJson(Map<String, dynamic> json) {
    return BookingItemVendor(
      id: _parseBookingInt(json['id']),
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      code: json['code'] as String? ?? '',
    );
  }
}

class BookingItemPricing {
  final int id;
  final int parameterCount;
  final double b2cPrice;
  final double offerPrice;
  final double saved;
  final BookingItemVendor? vendor;

  const BookingItemPricing({
    required this.id,
    required this.parameterCount,
    required this.b2cPrice,
    required this.offerPrice,
    required this.saved,
    this.vendor,
  });

  factory BookingItemPricing.fromJson(Map<String, dynamic> json) {
    return BookingItemPricing(
      id: _parseBookingInt(json['id']),
      parameterCount: _parseBookingInt(json['parameter_count']),
      b2cPrice: (json['b2c_price'] as num?)?.toDouble() ?? 0,
      offerPrice: (json['offer_price'] as num?)?.toDouble() ?? 0,
      saved: (json['saved'] as num?)?.toDouble() ?? 0,
      vendor: json['vendor'] != null
          ? BookingItemVendor.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BookingItemUser {
  final int id;
  final String name;
  final String? email;
  final int? phone;
  final String? gender;
  final int? age;

  const BookingItemUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.gender,
    this.age,
  });

  factory BookingItemUser.fromJson(Map<String, dynamic> json) {
    return BookingItemUser(
      id: _parseBookingInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: _parseBookingIntOrNull(json['phone']),
      gender: json['gender'] as String?,
      age: _parseBookingIntOrNull(json['age']),
    );
  }
}

class BookingItem {
  final int id;
  final String name;
  final String type;
  final String category;
  final int fastingTime;
  final int tat;
  final BookingItemPricing? pricing;
  final int qty;
  final BookingItemUser? user;
  final bool free;

  const BookingItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.fastingTime,
    required this.tat,
    this.pricing,
    required this.qty,
    this.user,
    required this.free,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: _parseBookingInt(json['id']),
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      fastingTime: _parseBookingInt(json['fasting_time']),
      tat: _parseBookingInt(json['tat']),
      pricing: json['pricing'] != null
          ? BookingItemPricing.fromJson(json['pricing'] as Map<String, dynamic>)
          : null,
      qty: _parseBookingInt(json['qty'], 1),
      user: json['user'] != null
          ? BookingItemUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      free: json['free'] == true,
    );
  }
}

class BookingOpdWallet {
  final double total;
  final double available;
  final double moduleAvailable;
  final double paidAmount;

  const BookingOpdWallet({
    required this.total,
    required this.available,
    required this.moduleAvailable,
    required this.paidAmount,
  });

  factory BookingOpdWallet.fromJson(Map<String, dynamic> json) {
    return BookingOpdWallet(
      total: (json['total'] as num?)?.toDouble() ?? 0,
      available: (json['available'] as num?)?.toDouble() ?? 0,
      moduleAvailable: (json['module_available'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BookingPricingDetails {
  final double totalGross;
  final double saved;
  final double collectionCharges;
  final double netAmount;
  final BookingOpdWallet? opdWallet;
  final double amountToPay;

  const BookingPricingDetails({
    required this.totalGross,
    required this.saved,
    required this.collectionCharges,
    required this.netAmount,
    this.opdWallet,
    required this.amountToPay,
  });

  factory BookingPricingDetails.fromJson(Map<String, dynamic> json) {
    return BookingPricingDetails(
      totalGross: (json['totalGross'] as num?)?.toDouble() ?? 0,
      saved: (json['saved'] as num?)?.toDouble() ?? 0,
      collectionCharges: (json['collection_charges'] as num?)?.toDouble() ?? 0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0,
      opdWallet: json['opd_wallet'] is Map
          ? BookingOpdWallet.fromJson(json['opd_wallet'] as Map<String, dynamic>)
          : null,
      amountToPay: (json['amount_to_pay'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BookingSlotInfo {
  final String slotId;
  final String vendorCode;
  final String slotDate;
  final String startTime;
  final String endTime;

  const BookingSlotInfo({
    required this.slotId,
    required this.vendorCode,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
  });

  factory BookingSlotInfo.fromJson(Map<String, dynamic> json) {
    return BookingSlotInfo(
      slotId: json['slot_id']?.toString() ?? '',
      vendorCode: json['vendor_code'] as String? ?? '',
      slotDate: json['slot_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
    );
  }

  String get displayTime => '$startTime - $endTime';

  /// e.g. "Tuesday, 15 April 2025" — same pattern as [AhcSlot.formattedScheduleDate].
  String get formattedScheduleDate {
    if (slotDate.isEmpty) return '—';
    try {
      final d = DateTime.parse(slotDate);
      return DateFormat('EEEE, d MMMM y').format(d);
    } catch (_) {
      return slotDate;
    }
  }

  /// e.g. "9:00 AM – 10:00 AM" — same pattern as [AhcSlot.formattedScheduleTimeRange].
  String get formattedScheduleTimeRange {
    final s = _parseBookingSlotClock(startTime);
    final e = _parseBookingSlotClock(endTime);
    if (s != null && e != null) {
      final ds = DateTime(1970, 1, 1, s.$1, s.$2, s.$3);
      final de = DateTime(1970, 1, 1, e.$1, e.$2, e.$3);
      return '${DateFormat.jm().format(ds)} – ${DateFormat.jm().format(de)}';
    }
    return displayTime;
  }
}

(int, int, int)? _parseBookingSlotClock(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  final parts = t.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  var sec = 0;
  if (parts.length > 2) {
    sec = int.tryParse(parts[2].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
  return (h, m, sec);
}

class BookingUser {
  final int userId;
  final String userName;
  final int? userPhone;
  final String? userEmail;

  const BookingUser({
    required this.userId,
    required this.userName,
    this.userPhone,
    this.userEmail,
  });

  factory BookingUser.fromJson(Map<String, dynamic> json) {
    return BookingUser(
      userId: _parseBookingInt(json['user_id']),
      userName: json['user_name'] as String? ?? '',
      userPhone: _parseBookingIntOrNull(json['user_phone']),
      userEmail: json['user_email'] as String?,
    );
  }
}

class BookingOverviewResponse {
  final BookingAddress? address;
  final String alternativePhone;
  final List<BookingItem> items;
  final BookingPricingDetails? pricingDetails;
  final BookingSlotInfo? slot;
  final BookingUser? user;
  final String? invoiceId;

  const BookingOverviewResponse({
    this.address,
    this.alternativePhone = '',
    required this.items,
    this.pricingDetails,
    this.slot,
    this.user,
    this.invoiceId,
  });

  factory BookingOverviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return BookingOverviewResponse(
      address: data['address'] != null
          ? BookingAddress.fromJson(data['address'] as Map<String, dynamic>)
          : null,
      alternativePhone: data['alternative_phone'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pricingDetails: data['pricing_details'] != null
          ? BookingPricingDetails.fromJson(
              data['pricing_details'] as Map<String, dynamic>)
          : null,
      slot: data['slot'] != null
          ? BookingSlotInfo.fromJson(data['slot'] as Map<String, dynamic>)
          : null,
      user: data['user'] != null
          ? BookingUser.fromJson(data['user'] as Map<String, dynamic>)
          : null,
      invoiceId: data['invoice_id']?.toString(),
    );
  }
}

/// Result of `POST /patient/diagnostics/order/booking` (`overview=yes` preview / `overview=no` finalize).
class DiagnosticsBookingApiResult {
  final BookingOverviewResponse overview;
  final bool verify;
  final Map<String, dynamic>? razorpayPayload;
  final bool paymentRequired;

  const DiagnosticsBookingApiResult({
    required this.overview,
    this.verify = false,
    this.razorpayPayload,
    this.paymentRequired = false,
  });

  factory DiagnosticsBookingApiResult.fromJson(Map<String, dynamic> root) {
    return DiagnosticsBookingApiResult(
      overview: BookingOverviewResponse.fromJson(root),
      verify: root['verify'] == true,
      razorpayPayload: root['razorpay_payload'] is Map
          ? Map<String, dynamic>.from(root['razorpay_payload'] as Map)
          : null,
      paymentRequired: root['paymentRequired'] == true ||
          root['isPaymentRequired'] == true,
    );
  }
}
