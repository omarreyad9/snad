
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ================= GOVERNORATE MODEL =================

class Governorate {
  final String id;
  final String nameAr;
  final String nameEn;
  final num shippingFee;

  const Governorate({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.shippingFee,
  });

  // للحفاظ على توافق الشاشات التي تستخدم g.name
  String get name => nameEn.isNotEmpty ? nameEn : nameAr;

  factory Governorate.fromMap(Map<String, dynamic> map) {
    return Governorate(
      id: map['id'].toString(),
      nameAr: (map['name_ar'] ?? '').toString(),
      nameEn: (map['name_en'] ?? '').toString(),
      shippingFee: (map['shipping_fee'] as num?) ?? 0,
    );
  }
}

// ================= ADDRESS MODEL =================

class Address {
  final String? id;
  final String fullName;
  final String phone;
  final String city;
  final String area;
  final String street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? governorateId;
  final bool isDefault;

  const Address({
    this.id,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.area,
    required this.street,
    this.building,
    this.floor,
    this.apartment,
    this.governorateId,
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id']?.toString(),
      fullName: (map['full_name'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      area: (map['area'] ?? '').toString(),
      street: (map['street'] ?? '').toString(),
      building: map['building']?.toString(),
      floor: map['floor']?.toString(),
      apartment: map['apartment']?.toString(),
      governorateId: map['governorate_id']?.toString(),
      isDefault: map['is_default'] == true,
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'city': city,
      'area': area,
      'street': street,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'governorate_id': governorateId,
      'is_default': isDefault,
    };
  }
}

// ================= ADDRESS REPOSITORY =================

class AddressRepository {
  static const String _table = 'addresses';

  static const String governoratesTable = 'shipping_governorates';

  static SupabaseClient get _db => Supabase.instance.client;

  static String? get userId => _db.auth.currentUser?.id;

  // ================= FETCH ADDRESSES =================

  static Future<List<Address>> fetch() async {
    final uid = userId;

    if (uid == null) return [];

    final response = await _db
        .from(_table)
        .select(
          'id, user_id, full_name, phone, city, area, street, '
          'building, floor, apartment, governorate_id, is_default',
        )
        .eq('user_id', uid)
        .order('id');

    return (response as List)
        .map(
          (item) => Address.fromMap(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // ================= SAVE ADDRESS =================

  static Future<void> save(Address address) async {
    final uid = userId;

    if (uid == null) {
      throw Exception('Please sign in first.');
    }

    if (address.isDefault) {
      await _db
          .from(_table)
          .update({'is_default': false})
          .eq('user_id', uid);
    }

    final data = address.toMap(uid);

    if (address.id == null) {
      await _db.from(_table).insert(data);
    } else {
      await _db
          .from(_table)
          .update(data)
          .eq('id', address.id!)
          .eq('user_id', uid);
    }
  }

  // ================= SET DEFAULT ADDRESS =================

  static Future<void> setDefault(String id) async {
    final uid = userId;

    if (uid == null) {
      throw Exception('Please sign in first.');
    }

    await _db
        .from(_table)
        .update({'is_default': false})
        .eq('user_id', uid);

    await _db
        .from(_table)
        .update({'is_default': true})
        .eq('id', id)
        .eq('user_id', uid);
  }

  // ================= DELETE ADDRESS =================

  static Future<void> delete(String id) async {
    final uid = userId;

    if (uid == null) {
      throw Exception('Please sign in first.');
    }

    await _db
        .from(_table)
        .delete()
        .eq('id', id)
        .eq('user_id', uid);
  }

  // ================= FETCH GOVERNORATES =================

  static Future<List<Governorate>> governorates() async {
    try {
      final response = await _db
          .from(governoratesTable)
          .select('id, name_ar, name_en, shipping_fee, is_active')
          .eq('is_active', true)
          .order('name_en');

      return (response as List)
          .map(
            (item) => Governorate.fromMap(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Failed to load governorates: $e');
      rethrow;
    }
  }
}
