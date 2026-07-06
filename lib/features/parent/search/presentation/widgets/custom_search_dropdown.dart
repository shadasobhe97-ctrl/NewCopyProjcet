import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class CustomSearchDropdown extends StatefulWidget {
  final String hintText;
  final List<Map<String, String>> items;
  final Function(Map<String, String>) onSelected;
  final Map<String, String>? initialSelection;

  const CustomSearchDropdown({
    super.key,
    required this.hintText,
    required this.items,
    required this.onSelected,
    this.initialSelection,
  });

  @override
  State<CustomSearchDropdown> createState() => _CustomSearchDropdownState();
}

class _CustomSearchDropdownState extends State<CustomSearchDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, String>> _filteredItems = [];
  bool _isDropdownOpen = false;
  Map<String, String>? _selectedItem;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;

    // تهيئة القيمة الأولية في حالة التعديل
    if (widget.initialSelection != null) {
      _selectedItem = widget.initialSelection;
      _controller.text = widget.initialSelection!['name'] ?? '';
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isDropdownOpen) {
        setState(() => _isDropdownOpen = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterList(String query) {
    setState(() {
      _filteredItems = query.isEmpty
          ? widget.items
          : widget.items
                .where(
                  (item) =>
                      item['name']!.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      _isDropdownOpen = true;
    });
  }

  void _selectItem(Map<String, String> item) {
    setState(() {
      _selectedItem = item;
      _controller.text = item['name']!;
      _isDropdownOpen = false;
    });
    _focusNode.unfocus();
    widget.onSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // حقل البحث
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onTap: () {
            setState(() {
              _isDropdownOpen = true;
              _filteredItems = widget.items;
            });
          },
          onChanged: _filterList,
          decoration: AppTheme.inputDecoration(context, 
            hintText: widget.hintText,
            hintStyle: AppTextStyles.style(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primaryLight,
            ),
            suffixIcon: _selectedItem != null
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedItem = null;
                        _controller.clear();
                        _filteredItems = widget.items;
                        _isDropdownOpen = false;
                      });
                    },
                  )
                : Icon(
                    _isDropdownOpen
                        ? Icons.arrow_drop_up_rounded
                        : Icons.arrow_drop_down_rounded,
                    color: AppColors.textMuted,
                  ),
          ),
        ),

        // قائمة النتائج
        if (_isDropdownOpen && _filteredItems.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            margin: const EdgeInsets.only(top: 4),
            decoration: AppTheme.boxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: AppTheme.radius(14),
              boxShadow: [
                AppTheme.boxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: AppTheme.border(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: AppTheme.radius(14),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _filteredItems.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: AppColors.grey.withValues(alpha: 0.1)),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = _selectedItem?['id'] == item['id'];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      item['name']!,
                      style: AppTextStyles.style(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? AppColors.primaryLight : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primaryLight,
                            size: 18,
                          )
                        : null,
                    onTap: () => _selectItem(item),
                  );
                },
              ),
            ),
          ),

        // رسالة "لا نتائج"
        if (_isDropdownOpen && _filteredItems.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.boxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.white,
              borderRadius: AppTheme.radius(14),
              border: AppTheme.border(color: AppColors.grey.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                "لا توجد نتائج مطابقة",
                style: AppTextStyles.style(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }
}
