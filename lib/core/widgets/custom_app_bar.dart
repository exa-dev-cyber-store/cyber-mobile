import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? bottom;
  final double bottomHeight;
  final bool showBottomBorder;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.bottomHeight = 0,
    this.showBottomBorder = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + bottomHeight + (showBottomBorder ? 1.0 : 0.0));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: showBottomBorder
            ? const Border(bottom: BorderSide(color: AppColors.border, width: 1))
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight + bottomHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: NavigationToolbar(
                  leading: showBackButton
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          color: AppColors.textPrimary,
                          onPressed: onBackPressed ?? () => Get.back(),
                        )
                      : null,
                  middle: Text(
                    title,
                    style: AppTextStyles.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: actions != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        )
                      : null,
                  centerMiddle: true,
                ),
              ),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}
