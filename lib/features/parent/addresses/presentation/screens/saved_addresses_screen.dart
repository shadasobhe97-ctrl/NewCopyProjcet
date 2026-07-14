import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_bars.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';
import 'package:kids_transport/features/parent/addresses/data/repositories/address_repository.dart';
import 'package:kids_transport/features/parent/addresses/logic/address_cubit/address_cubit.dart';
import 'package:kids_transport/features/parent/addresses/logic/address_cubit/address_state.dart';
import 'package:kids_transport/features/parent/addresses/presentation/widgets/add_address_sheet.dart';
import 'package:kids_transport/features/parent/addresses/presentation/widgets/address_card.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressCubit(
        AddressRepository(
          AddressRemoteDataSource(ApiClient()),
        ),
      )..loadAddresses(),
      child: const _SavedAddressesView(),
    );
  }
}

class _SavedAddressesView extends StatelessWidget {
  const _SavedAddressesView();

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAddSheet(BuildContext context, {AddressModel? address}) {
    final cubit = context.read<AddressCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => AddAddressSheet(
        initialAddress: address,
        onSave: (newAddress) async {
          if (address == null) {
            await cubit.addAddress(newAddress);
          } else {
            await cubit.updateAddress(newAddress);
          }
          // إعادة null تعني النجاح، الـ Cubit يتكفل بإظهار الـ Snack
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddressActionSuccess) {
          _showSnack(context, state.message);
        } else if (state is AddressActionError) {
          _showSnack(context, state.message, isError: true);
        } else if (state is AddressError) {
          _showSnack(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        // استخراج القائمة الحالية من أي حالة تحتوي عليها
        final List<AddressModel> addresses = switch (state) {
          AddressLoaded s => s.addresses,
          AddressActionLoading s => s.addresses,
          AddressActionSuccess s => s.addresses,
          AddressActionError s => s.addresses,
          _ => const [],
        };

        final bool isActionLoading = state is AddressActionLoading;
        final bool isFullLoading = state is AddressLoading;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.scaffoldBackgroundColor,
            appBar: const AppPrimaryAppBar(title: 'إدارة العناوين المحفوظة'),
            body: Column(
              children: [
                Expanded(
                  child: _buildBody(
                    context,
                    state: state,
                    addresses: addresses,
                    isFullLoading: isFullLoading,
                    isActionLoading: isActionLoading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton.icon(
                    onPressed: isActionLoading || isFullLoading
                        ? null
                        : () => _showAddSheet(context),
                    icon: const Icon(
                      Icons.add_location_alt_rounded,
                      color: AppColors.white,
                    ),
                    label: Text(
                      'إضافة عنوان جديد',
                      style: AppTextStyles.style(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required AddressState state,
    required List<AddressModel> addresses,
    required bool isFullLoading,
    required bool isActionLoading,
  }) {
    // تحميل كامل للشاشة
    if (isFullLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // خطأ في التحميل الأولي مع قائمة فارغة
    if (state is AddressError) {
      return InkWell(
        onTap: () => context.read<AddressCubit>().loadAddresses(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.refresh_rounded,
                size: 48,
                color: AppColors.errorLight,
              ),
              const SizedBox(height: 12),
              Text(
                'إعادة المحاولة',
                style: AppTextStyles.style(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorLight,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // قائمة فارغة
    if (addresses.isEmpty) {
      return const EmptyStatePlaceholder(
        icon: Icons.location_off_outlined,
        title: 'لا يوجد عناوين محفوظة حالياً',
      );
    }

    // القائمة (مع Loading overlay عند أي action)
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final addr = addresses[index];
            return AddressCard(
              address: addr.toDisplayMap(),
              isPrimary: addr.isDefault,
              onSetDefault: isActionLoading || isFullLoading
                  ? () {}
                  : () => _showAddSheet(context, address: addr),
              onDelete: isActionLoading || isFullLoading
                  ? () {}
                  : () => _confirmDelete(context, addr),
            );
          },
        ),
        if (isActionLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, AddressModel addr) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف العنوان'),
          content: Text('هل تريد حذف "${addr.title}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AddressCubit>().deleteAddress(addr.id!);
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
