
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/address.dart';
import '../theme/app_theme.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? address;
  final bool isFirst;

  const AddressFormScreen({
    super.key,
    this.address,
    this.isFirst = false,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late final _name = TextEditingController(
    text: widget.address?.fullName,
  );

  late final _phone = TextEditingController(
    text: widget.address?.phone,
  );

  late final _city = TextEditingController(
    text: widget.address?.city,
  );

  late final _area = TextEditingController(
    text: widget.address?.area,
  );

  late final _street = TextEditingController(
    text: widget.address?.street,
  );

  late final _building = TextEditingController(
    text: widget.address?.building ?? '',
  );

  late final _floor = TextEditingController(
    text: widget.address?.floor ?? '',
  );

  late final _apartment = TextEditingController(
    text: widget.address?.apartment ?? '',
  );

  late bool _isDefault =
      widget.address?.isDefault ?? widget.isFirst;

  String? _governorateId;
  List<Governorate> _governorates = [];

  String? _error;
  bool _saving = false;
  bool _loadingGovernorates = true;

  @override
  void initState() {
    super.initState();

    _governorateId = widget.address?.governorateId;

    AddressRepository.governorates().then((list) {
      if (!mounted) return;

      setState(() {
        _governorates = list;
        _loadingGovernorates = false;

        if (!list.any((g) => g.id == _governorateId)) {
          _governorateId = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _area.dispose();
    _street.dispose();
    _building.dispose();
    _floor.dispose();
    _apartment.dispose();

    super.dispose();
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) {
      return 'Please enter the recipient name.';
    }

    final phone = _phone.text.replaceAll(RegExp(r'[\s-]'), '');

    if (!RegExp(r'^01[0125]\d{8}$').hasMatch(phone)) {
      return 'Please enter a valid Egyptian mobile number.';
    }

    if (_city.text.trim().isEmpty) {
      return 'Please enter the city.';
    }

    if (_area.text.trim().isEmpty) {
      return 'Please enter the area.';
    }

    if (_street.text.trim().isEmpty) {
      return 'Please enter the street.';
    }

    return null;
  }

  Future<void> _save() async {
    if (_saving) return;

    final problem = _validate();

    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      await AddressRepository.save(
        Address(
          id: widget.address?.id,
          fullName: _name.text.trim(),
          phone: _phone.text.replaceAll(RegExp(r'[\s-]'), ''),
          city: _city.text.trim(),
          area: _area.text.trim(),
          street: _street.text.trim(),
          building: _building.text.trim().isEmpty
              ? null
              : _building.text.trim(),
          floor: _floor.text.trim().isEmpty
              ? null
              : _floor.text.trim(),
          apartment: _apartment.text.trim().isEmpty
              ? null
              : _apartment.text.trim(),
          governorateId: _governorateId,
          isDefault: _isDefault,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = '$e');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.address != null;

    return Scaffold(
      backgroundColor: context.mc.frame,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 17,
                      color: context.mc.textMuted,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.mc.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                editing ? 'Edit address' : 'New address',
                style: TextStyle(
                  fontFamily: MuseTheme.serif,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: context.mc.textStrong,
                ),
              ),

              const SizedBox(height: 22),

              _AField(
                label: 'Recipient name',
                controller: _name,
                hint: 'Full name',
              ),

              _AField(
                label: 'Phone',
                controller: _phone,
                hint: '01012345678',
                keyboardType: TextInputType.phone,
              ),

              Text(
                'Governorate',
                style: TextStyle(
                  fontSize: 10,
                  color: context.mc.textMid,
                ),
              ),

              const SizedBox(height: 7),

              if (_loadingGovernorates)
                const LinearProgressIndicator()
              else if (_governorates.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _governorateId,
                  isExpanded: true,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.mc.textStrong,
                  ),
                  decoration: _decoration(
                    context,
                    'Choose governorate',
                  ),
                  items: _governorates
                      .map(
                        (g) => DropdownMenuItem(
                          value: g.id,
                          child: Text(g.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _governorateId = v);
                  },
                )
              else
                Text(
                  'Governorates could not be loaded.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.mc.error,
                  ),
                ),

              const SizedBox(height: 17),

              _AField(
                label: 'City',
                controller: _city,
                hint: 'City',
              ),

              _AField(
                label: 'Area',
                controller: _area,
                hint: 'Area / District',
              ),

              _AField(
                label: 'Street',
                controller: _street,
                hint: 'Street name',
              ),

              _AField(
                label: 'Building',
                controller: _building,
                hint: 'Building number (optional)',
              ),

              Row(
                children: [
                  Expanded(
                    child: _AField(
                      label: 'Floor',
                      controller: _floor,
                      hint: 'Floor',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AField(
                      label: 'Apartment',
                      controller: _apartment,
                      hint: 'Apartment',
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Set as default address',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.mc.textMid,
                      ),
                    ),
                  ),
                  Switch(
                    value: _isDefault,
                    activeColor: context.mc.brand,
                    onChanged: (v) {
                      setState(() => _isDefault = v);
                    },
                  ),
                ],
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      fontSize: 10,
                      color: context.mc.error,
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: context.mc.primaryButton.copyWith(
                    color: _saving
                        ? context.mc.brand.withOpacity(0.65)
                        : context.mc.brand,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _saving
                        ? 'Saving...'
                        : editing
                            ? 'Save changes'
                            : 'Save address',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _decoration(
  BuildContext context,
  String hint,
) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 12,
        color: context.mc.textFaint,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      constraints: const BoxConstraints(minHeight: 43),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.mc.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.mc.brandSoft),
      ),
      filled: true,
      fillColor: context.mc.inputFill,
    );

class _AField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _AField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: context.mc.textMid,
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 12,
              color: context.mc.textStrong,
            ),
            decoration: _decoration(context, hint),
          ),
        ],
      ),
    );
  }
}
