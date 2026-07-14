import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';
import 'package:kids_transport/features/parent/addresses/logic/address_cubit/address_cubit.dart';
import 'package:kids_transport/features/parent/addresses/logic/address_cubit/address_state.dart';
import 'package:kids_transport/features/parent/addresses/presentation/widgets/add_address_sheet.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';

class AddressSelectionBottomSheet extends StatefulWidget {
  const AddressSelectionBottomSheet({super.key});

  static Future<AddressModel?> show(BuildContext context) {
    return showModalBottomSheet<AddressModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => getIt<AddressCubit>()..loadAddresses(),
        child: const AddressSelectionBottomSheet(),
      ),
    );
  }

  @override
  State<AddressSelectionBottomSheet> createState() =>
      _AddressSelectionBottomSheetState();
}

class _AddressSelectionBottomSheetState
    extends State<AddressSelectionBottomSheet> {
  int? _selectedIndex;

  /// فتح AddAddressSheet لإضافة عنوان جديد
  void _openAddAddress(BuildContext context) {
    final cubit = context.read<AddressCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => AddAddressSheet(
        onSave: (newAddress) async {
          await cubit.addAddress(newAddress);
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AddressActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final List<AddressModel> savedAddresses = switch (state) {
            AddressLoaded s => s.addresses,
            AddressActionLoading s => s.addresses,
            AddressActionSuccess s => s.addresses,
            AddressActionError s => s.addresses,
            _ => const [],
          };

          final bool isFullLoading = state is AddressLoading;
          final bool isActionLoading = state is AddressActionLoading;

          return Container(
            decoration: BoxDecoration(
              color: context.backgroundSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.grey300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'اختر عنوان المنزل',
                          style: AppTextStyles.style(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: isFullLoading || isActionLoading
                              ? null
                              : () => _openAddAddress(context),
                          icon: const Icon(
                            Icons.add_location_alt_rounded,
                            size: 18,
                          ),
                          label: const Text('إضافة عنوان'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // المحتوى الأساسي
                    if (isFullLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state is AddressError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: InkWell(
                          onTap: () =>
                              context.read<AddressCubit>().loadAddresses(),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
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
                        ),
                      )
                    else if (savedAddresses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 48,
                                color: AppColors.grey300,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'لا توجد عناوين محفوظة',
                                style: AppTextStyles.style(
                                  color: AppColors.grey400,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () => _openAddAddress(context),
                                child: const Text('إضافة عنوان جديد'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // قائمة العناوين
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: savedAddresses.length,
                          itemBuilder: (context, index) {
                            final address = savedAddresses[index];
                            final isSelected = _selectedIndex == index;
                            return GestureDetector(
                              onTap: isActionLoading
                                  ? null
                                  : () =>
                                        setState(() => _selectedIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? context.primaryColor.withValues(alpha: 0.08)
                                      : (context.isDarkMode
                                            ? AppColors.darkCard
                                            : AppColors.grey50),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? context.primaryColor
                                        : AppColors.grey200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.home_rounded,
                                      color: isSelected
                                          ? context.primaryColor
                                          : AppColors.grey400,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            address.title,
                                            style: AppTextStyles.style(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? context.primaryColor
                                                  : null,
                                            ),
                                          ),
                                          Text(
                                            'إحداثيات: (${address.lat.toStringAsFixed(4)}, ${address.lng.toStringAsFixed(4)})',
                                            style: AppTextStyles.style(
                                              fontSize: 12,
                                              color: AppColors.grey400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check_circle_rounded,
                                              color: context.primaryColor,
                                              key: const ValueKey('checked'),
                                            )
                                          : Icon(
                                              Icons
                                                  .radio_button_unchecked_rounded,
                                              color: AppColors.grey300,
                                              key: const ValueKey('unchecked'),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // زر التأكيد
                      if (_selectedIndex != null &&
                          _selectedIndex! < savedAddresses.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isActionLoading
                                  ? null
                                  : () => Navigator.pop(
                                      context,
                                      savedAddresses[_selectedIndex!],
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'تأكيد الاختيار',
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                  ],
                ),
                if (isActionLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x33000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
