import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../domain/models/app_settings.dart';
import 'providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (settings.isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final s = settings.settings;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go(AppRouter.home),
                    ),
                    Text(
                      'Paramètres',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ).animate().fadeIn(),
                const SizedBox(height: 24),
                _Section(
                  title: 'Appearance',
                  children: [
                    _SwitchTile(
                      title: 'Dark theme',
                      subtitle: 'Use the premium dark interface',
                      value: s.darkTheme,
                      onChanged: settings.setDarkTheme,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'Preferences',
                  children: [
                    _SwitchTile(
                      title: 'Notifications',
                      subtitle: 'Conversation and system alerts',
                      value: s.notifications,
                      onChanged: settings.setNotifications,
                    ),
                    _SwitchTile(
                      title: 'Usage analytics',
                      subtitle: 'Share anonymous usage to improve routing',
                      value: s.analytics,
                      onChanged: settings.setAnalytics,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Language'),
                      subtitle: Text(s.language),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _pickLanguage(context, s.language, settings),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Voice locale'),
                      subtitle: Text(s.voiceLocale),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _pickVoiceLocale(context, s.voiceLocale, settings),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _Section(
                  title: 'API',
                  children: [
                    _SwitchTile(
                      title: 'Sync with API',
                      subtitle: 'Use backend for auth and conversations when signed in',
                      value: s.syncWithApi,
                      onChanged: settings.setSyncWithApi,
                    ),
                    _ApiUrlField(
                      initialValue: s.apiBaseUrl,
                      onSaved: settings.setApiBaseUrl,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.of(context).textMuted,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickLanguage(
    BuildContext context,
    String current,
    SettingsProvider provider,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.of(context).surfaceElevated,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppSettings.supportedLanguages
              .map(
                (lang) => ListTile(
                  title: Text(lang),
                  trailing: lang == current ? const Icon(Icons.check, color: AppColors.accent) : null,
                  onTap: () => Navigator.pop(ctx, lang),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null && context.mounted) {
      await provider.setLanguage(selected);
    }
  }

  Future<void> _pickVoiceLocale(
    BuildContext context,
    String current,
    SettingsProvider provider,
  ) async {
    const locales = [
      ('en_US', 'English (US)'),
      ('en_GB', 'English (UK)'),
      ('fr_FR', 'Français'),
      ('es_ES', 'Español'),
      ('de_DE', 'Deutsch'),
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.of(context).surfaceElevated,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: locales
              .map(
                (e) => ListTile(
                  title: Text(e.$2),
                  subtitle: Text(e.$1),
                  trailing: e.$1 == current ? const Icon(Icons.check, color: AppColors.accent) : null,
                  onTap: () => Navigator.pop(ctx, e.$1),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null && context.mounted) {
      await provider.setVoiceLocale(selected);
    }
  }
}

class _ApiUrlField extends StatefulWidget {
  const _ApiUrlField({required this.initialValue, required this.onSaved});

  final String initialValue;
  final Future<void> Function(String) onSaved;

  @override
  State<_ApiUrlField> createState() => _ApiUrlFieldState();
}

class _ApiUrlFieldState extends State<_ApiUrlField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _ApiUrlField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'API base URL',
            hintText: 'http://localhost:3000/api/v1',
          ),
          onSubmitted: widget.onSaved,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => widget.onSaved(_controller.text.trim()),
            child: const Text('Save endpoint'),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.of(context).textMuted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.of(context).textMuted)),
      value: value,
      activeTrackColor: AppColors.accent,
      onChanged: (v) => onChanged(v),
    );
  }
}
