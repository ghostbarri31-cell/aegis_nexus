import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/domain/models/user_model.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  bool _editing = false;
  bool _saving = false;
  String? _loadedUserId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadUserIntoForm(UserModel user) {
    if (_editing || _loadedUserId == user.id) return;
    _nameController.text = user.displayName;
    _emailController.text = user.email;
    _bioController.text = user.bio;
    _loadedUserId = user.id;
  }

  Future<void> _save(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await auth.updateProfile(
      displayName: _nameController.text,
      email: _emailController.text,
      bio: _bioController.text,
    );
    if (mounted) {
      setState(() {
        _saving = false;
        _editing = !ok;
        if (ok) _loadedUserId = null;
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
      } else if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final user = auth.user;
    if (user == null) {
      return SafeArea(
        child: Center(
          child: Text(
            'No profile loaded',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    _loadUserIntoForm(user);

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
                      'Profil',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    if (!_editing)
                      TextButton.icon(
                        onPressed: () => setState(() => _editing = true),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                GlassContainer(
                  padding: const EdgeInsets.all(28),
                  borderRadius: 24,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _Avatar(initials: user.initials),
                        const SizedBox(height: 20),
                        if (_editing) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Display name'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bioController,
                            decoration: const InputDecoration(labelText: 'Bio'),
                            maxLines: 3,
                          ),
                        ] else ...[
                          Text(
                            user.displayName.isNotEmpty ? user.displayName : 'User',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.of(context).textSecondary,
                                ),
                          ),
                          if (user.bio.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              user.bio,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.of(context).textMuted,
                                  ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 12),
                        Chip(
                          label: Text(user.role.toUpperCase()),
                          backgroundColor: AppColors.of(context).glassFill,
                          side: BorderSide(color: AppColors.of(context).glassBorder),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        _InfoRow(label: 'User ID', value: user.id),
                        _InfoRow(
                          label: 'Session',
                          value: auth.isRemoteSession ? 'API (JWT)' : 'Local',
                        ),
                        const SizedBox(height: 16),
                        if (_editing)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _saving
                                      ? null
                                      : () {
                                          setState(() {
                                            _editing = false;
                                            _loadedUserId = null;
                                          });
                                          _loadUserIntoForm(user);
                                        },
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _saving ? null : () => _save(auth),
                                  child: _saving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Save'),
                                ),
                              ),
                            ],
                          )
                        else ...[
                          if (auth.isRemoteSession)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Signed in to API',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppColors.success,
                                    ),
                              ),
                            ),
                          FilledButton.icon(
                            onPressed: () => context.push(AppRouter.auth),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Sign in to API'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => auth.signOut(),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Sign out'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ).animate().fadeIn().scale(
                      begin: const Offset(0.98, 0.98),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.accentGradient,
        boxShadow: [BoxShadow(color: AppColors.accentGlow, blurRadius: 24)],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: colors.textMuted)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(color: colors.textSecondary)),
        ),
      ],
    );
  }
}
