import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/home_controller.dart';
import 'pages/home_pages.dart';
import 'pages/profile_pages.dart';
import 'pages/wishlist_pages.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final homeController = Get.find<HomeController>();

  final List<Widget> pages = [
    HomePages(),
    const WishlistPages(),
    ProfilePages(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) => Scaffold(
        body: IndexedStack(
          index: controller.indexPage,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: controller.indexPage,
              onDestinationSelected: controller.changePage,
              backgroundColor: AppColors.surface,
              elevation: 0,
              indicatorColor: AppColors.primary.withValues(alpha: 0.08),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded, color: AppColors.primary),
                  label: 'Store',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.primary),
                  label: 'Wishlist',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
