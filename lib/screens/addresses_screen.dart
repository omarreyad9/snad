
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/address.dart';
import '../theme/app_theme.dart';
import 'address_form_screen.dart';

/// Lists the signed-in user's saved addresses.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _items = [];
  Map<String, String> _gov = {};

  bool _loading = true;
  String? _error;

  bool get _signedIn => AddressRepository.userId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_signedIn) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await AddressRepository.fetch();
      final govs = await AddressRepository.governorates();

      if (!mounted) return;

      setState(() {
        _items = items;
        _gov = {for (final g in govs) g.id: g.name};
        _loading = false;
      });
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not load your addresses.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _openForm([Address? address]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(
          address: address,
          isFirst: _items.isEmpty,
        ),
      ),
    );

    if (saved == true) {
      _load();
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      await _load();
    } on PostgrestException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('$e');
    }
  }

  void _toast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmDelete(Address a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('Remove the address in ${a.city}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true && a.id != null) {
      _run(() => AddressRepository.delete(a.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mc.frame,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
                'My addresses',
                style: TextStyle(
                  fontFamily: MuseTheme.serif,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: context.mc.textStrong,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Your delivery details for checkout.',
                style: TextStyle(
                  fontSize: 11,
                  color: context.mc.textMuted,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(child: _body()),

              if (_signedIn)
                GestureDetector(
                  onTap: () => _openForm(),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: context.mc.primaryButton,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 17,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add new address',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (!_signedIn) {
      return Center(
        child: Text(
          'Sign in to manage your addresses.',
          style: TextStyle(
            fontSize: 12,
            color: context.mc.textMuted,
          ),
        ),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: TextStyle(
                fontSize: 11,
                color: context.mc.error,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _load,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No saved addresses yet.',
          style: TextStyle(
            fontSize: 12,
            color: context.mc.textMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _card(_items[i]),
    );
  }

  Widget _card(Address a) {
    final govName = a.governorateId != null
        ? _gov[a.governorateId]
        : null;

    final place = [
      if (govName != null && govName.isNotEmpty) govName,
      a.city,
      a.area,
      a.street,
      if (a.building != null && a.building!.isNotEmpty)
        'Building ${a.building}',
      if (a.floor != null && a.floor!.isNotEmpty)
        'Floor ${a.floor}',
      if (a.apartment != null && a.apartment!.isNotEmpty)
        'Apartment ${a.apartment}',
    ].where((e) => e.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.mc.inputFill,
        border: Border.all(color: context.mc.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Delivery address',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.mc.textStrong,
                      ),
                    ),

                    if (a.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.mc.brand,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  a.fullName,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.mc.textStrong,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  a.phone,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.mc.textMid,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  place,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: context.mc.textMid,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 18,
              color: context.mc.textMuted,
            ),
            onSelected: (v) {
              if (v == 'edit') {
                _openForm(a);
              }

              if (v == 'default' && a.id != null) {
                _run(() => AddressRepository.setDefault(a.id!));
              }

              if (v == 'delete') {
                _confirmDelete(a);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              if (!a.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Text('Set as default'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
