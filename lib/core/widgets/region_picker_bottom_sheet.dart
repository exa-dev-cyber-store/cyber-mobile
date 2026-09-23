import 'package:flutter/material.dart';
import '../../data/models/wilayah_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Helper to format raw uppercase names to Title Case for elegant UI presentation.
String formatWilayahName(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// Displays an Apple-style searchable bottom sheet modal for selecting administrative regions.
Future<WilayahModel?> showRegionPicker(
  BuildContext context, {
  required String title,
  required List<WilayahModel> items,
  String? selectedName,
  bool isLoading = false,
}) {
  return showModalBottomSheet<WilayahModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _RegionPickerSheetContent(
        title: title,
        items: items,
        selectedName: selectedName,
        isLoading: isLoading,
      );
    },
  );
}

class _RegionPickerSheetContent extends StatefulWidget {
  final String title;
  final List<WilayahModel> items;
  final String? selectedName;
  final bool isLoading;

  const _RegionPickerSheetContent({
    required this.title,
    required this.items,
    this.selectedName,
    this.isLoading = false,
  });

  @override
  State<_RegionPickerSheetContent> createState() => _RegionPickerSheetContentState();
}

class _RegionPickerSheetContentState extends State<_RegionPickerSheetContent> {
  final TextEditingController _searchController = TextEditingController();
  List<WilayahModel> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant _RegionPickerSheetContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filterItems(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterItems(_searchController.text);
  }

  void _filterItems(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredItems = widget.items;
      });
      return;
    }

    final lower = query.trim().toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return item.name.toLowerCase().contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppSpacing.roundedPill,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.items.length} options available',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceTertiary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title.toLowerCase()}...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.divider),

          // List or Empty State
          Flexible(
            child: widget.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2.5),
                    ),
                  )
                : _filteredItems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl, horizontal: AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceTertiary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_off_rounded, size: 36, color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No Region Found',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching with a different keyword.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredItems.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 56,
                          endIndent: AppSpacing.xl,
                          color: AppColors.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final isSelected = widget.selectedName != null &&
                              (widget.selectedName!.toLowerCase() == item.name.toLowerCase() ||
                                  widget.selectedName!.toLowerCase() ==
                                      formatWilayahName(item.name).toLowerCase());

                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pop(item);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.accent.withValues(alpha: 0.12)
                                          : AppColors.surfaceTertiary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: isSelected ? AppColors.accent : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      formatWilayahName(item.name),
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: isSelected ? AppColors.accent : AppColors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 20,
                                      color: AppColors.accent,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
