import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/child_model.dart';
import '../../data/repositories/children_repository.dart';
import 'add_child_step1_screen.dart';

class ChildDataDetailsScreen extends StatefulWidget {
  final ChildModel child;
  const ChildDataDetailsScreen({super.key, required this.child});

  @override
  State<ChildDataDetailsScreen> createState() => _ChildDataDetailsScreenState();
}

class _ChildDataDetailsScreenState extends State<ChildDataDetailsScreen> {
  ChildModel? childDetails;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChildDetails();
  }

  Future<void> _fetchChildDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final repository = context.read<ChildrenRepository>();
      final (result, error) = await repository.getChildDetails(widget.child.id.toString());
      if (mounted) {
        if (error != null) {
          setState(() {
            errorMessage = error;
            isLoading = false;
          });
        } else {
          setState(() {
            childDetails = result;
            isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage = 'حدث خطأ أثناء تحميل تفاصيل الطفل.';
          isLoading = false;
        });
      }
    }
  }

  void _openEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddChildStep1Screen(child: childDetails ?? widget.child),
      ),
    );
    _fetchChildDetails();
  }

  String _getGradeLabel(int level) {
    switch (level) {
      case 1: return 'روضة';
      case 2: return 'ابتدائي';
      case 3: return 'إعدادي';
      case 4: return 'ثانوي';
      default: return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = childDetails ?? widget.child;

    if (isLoading) {
      return Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: const Text('بيانات الطفل'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: const Text('بيانات الطفل'),
          elevation: 0,
        ),
        body: InkWell(
          onTap: _fetchChildDetails,
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
                    errorMessage!,
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
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundSurface,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar مع صورة الطفل ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية متدرجة
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.linearGradient(
                        colors: context.primaryGradient,
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  // صورة الطفل في المنتصف
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeChild.gender == 'male'
                                ? context.maleBlueBg
                                : context.femalePinkBg,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: activeChild.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    activeChild.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: activeChild.gender == 'male'
                                          ? context.genderMaleColor
                                          : context.genderFemaleColor,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person_rounded,
                                  size: 44,
                                  color: activeChild.gender == 'male'
                                      ? context.genderMaleColor
                                      : context.genderFemaleColor,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeChild.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            title: const Text('بيانات الطفل'),
            actions: [
              IconButton(
                onPressed: _openEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'تعديل',
              ),
            ],
          ),

          // ── المحتوى ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── المعلومات الشخصية ──
                  _buildSectionCard(
                    context: context,
                    title: 'المعلومات الشخصية',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildField(
                        label: 'الاسم الكامل',
                        value: activeChild.fullName,
                      ),
                      _buildField(
                        label: 'الجنس',
                        value: activeChild.gender == 'male' ? 'ذكر' : 'أنثى',
                      ),
                      _buildField(
                        label: 'تاريخ الميلاد',
                        value: DateFormat('yyyy/MM/dd').format(activeChild.birthDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── البيانات الأكاديمية ──
                  _buildSectionCard(
                    context: context,
                    title: 'البيانات الأكاديمية',
                    icon: Icons.school_outlined,
                    children: [
                      _buildField(
                        label: 'الصف الدراسي',
                        value: _getGradeLabel(activeChild.gradeLevel),
                      ),
                      _buildField(
                        label: 'المدرسة',
                        value: activeChild.schoolName,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── العنوان ──
                  _buildSectionCard(
                    context: context,
                    title: 'عنوان المنزل',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildField(
                        label: 'العنوان',
                        value: activeChild.addressName,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── الملاحظات الطبية ──
                  if (activeChild.medicalNotes != null && activeChild.medicalNotes!.isNotEmpty)
                    _buildSectionCard(
                      context: context,
                      title: 'الملاحظات الطبية',
                      icon: Icons.medical_services_outlined,
                      children: [
                        Text(
                          activeChild.medicalNotes!,
                          style: AppTextStyles.style(fontSize: 14, color: context.textMuted),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: context.isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(color: AppColors.grey200),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.style(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          ...children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.style(color: AppColors.grey500, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.style(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }
}