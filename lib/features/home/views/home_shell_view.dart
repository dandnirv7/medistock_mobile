import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/home_shell_controller.dart';

/// Persistent host shell. Renders an appbar and Salomon-style
/// bottom nav around an IndexedStack of per-tab root views.
/// Sub-routes pushed from inside a tab (e.g. Category, Supplier,
/// Stok In/Out) are pushed via `Get.toNamed(...)` on the root
/// Navigator, so the back button returns to the tab root with the
/// shell still mounted.
///
/// All tab roots are mounted eagerly (one widget each), so switching
/// tabs is O(1) and does not refire API calls.
class HomeShellView extends GetView<HomeShellController> {
  const HomeShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.currentIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: index,
          children: [
            for (var i = 0; i < controller.tabs.length; i++)
              _TabRootView(tabIndex: i),
          ],
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: index,
          onTap: controller.changeTab,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          itemShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          items: [
            for (final t in controller.tabs)
              SalomonBottomBarItem(
                icon: Icon(t.icon),
                activeIcon: Icon(t.activeIcon),
                title: Text(t.label),
              ),
          ],
        ),
      );
    });
  }
}

/// Mounts the root view for the tab at [tabIndex]. Using a wrapper
/// keeps the IndexedStack children list stable (one child per tab) so
/// switching tabs does not rebuild widget identities and refire
/// fetches. Bindings still fire lazily because each tab's binding
/// resolves when the tab root view is first built — and since the
/// IndexedStack keeps every tab mounted, that happens once per tab
/// per shell mount.
class _TabRootView extends StatelessWidget {
  const _TabRootView({required this.tabIndex});

  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeShellController>();
    return controller.buildTabRoot(tabIndex);
  }
}

