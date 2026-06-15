import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../conversations/presentation/widgets/conversation_sidebar.dart';

/// App shell — sidebar + main content area for all routes.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  bool _sidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    if (isCompact) {
      return GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: Drawer(
            backgroundColor: AppColors.of(context).sidebar,
            child: ConversationSidebar(expanded: true),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            title: const Text(AppConstants.appName),
          ),
          body: widget.child,
        ),
      );
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              width: _sidebarExpanded
                  ? AppConstants.sidebarWidth
                  : AppConstants.sidebarWidthCompact,
              child: ConversationSidebar(
                expanded: _sidebarExpanded,
                onToggle: () =>
                    setState(() => _sidebarExpanded = !_sidebarExpanded),
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }
}
