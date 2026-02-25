/// Screen for adding a new AI IDE account.
///
/// Provides dynamic input fields based on the AI platform
/// (e.g., Session Token for Antigravity, Access Token for Copilot).
/// Validates inputs and saves sensitive data to secure local storage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/platform_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/account_model.dart';
import '../../domain/providers/account_provider.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  final AiPlatform initialPlatform;

  const AddAccountScreen({super.key, required this.initialPlatform});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late AiPlatform _selectedPlatform;
  PlanType _selectedPlan = PlanType.free;

  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _labelController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPlatform = widget.initialPlatform;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final accountId = const Uuid().v4();
      final email = _emailController.text.trim();
      final token = _tokenController.text.trim();
      final label = _labelController.text.trim();

      // 1. Create account metadata
      final account = Account(
        id: accountId,
        platform: _selectedPlatform,
        email: email,
        plan: _selectedPlan,
        displayName: label,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // 2. Prepare sensitive tokens (using keys aligned with AccountModel.sensitiveFields)
      final Map<String, String> tokens = {};
      switch (_selectedPlatform) {
        case AiPlatform.anthropic:
        case AiPlatform.openai:
        case AiPlatform.windsurf:
          tokens['session_token'] = token;
          break;
        case AiPlatform.github:
          tokens['oauth_token'] = token;
          break;
        case AiPlatform.codeium:
        case AiPlatform.cursor:
          tokens['api_key'] = token;
          break;
      }

      // 3. Save to providers (which handles storage + database)
      await ref
          .read(accountsProvider.notifier)
          .addAccount(account: account, tokens: tokens);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${account.email} successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add account: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandColor = _selectedPlatform.brandColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Platform Selector ─────────────────────
                  Text(
                    'AI Platform',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: brandColor.withAlpha(50)),
                    ),
                    child: Column(
                      children: AiPlatform.values.map((p) {
                        final isSelected = _selectedPlatform == p;
                        return ListSelectionTile(
                          platform: p,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedPlatform = p),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Input Fields ─────────────────────────
                  _buildTextField(
                    label: 'Email Address',
                    hint: 'e.g. user@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                    validator: (v) =>
                        v == null || !v.contains('@') ? 'Invalid email' : null,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    label: _getTokenLabel(),
                    hint: _getTokenHint(),
                    controller: _tokenController,
                    icon: Icons.vpn_key_outlined,
                    isPassword: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Token is required' : null,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    label: 'Account Label (Optional)',
                    hint: 'e.g. Personal, Work',
                    controller: _labelController,
                    icon: Icons.label_outline_rounded,
                  ),

                  const SizedBox(height: 32),

                  // ── Plan Selector ────────────────────────
                  Text(
                    'Plan Level',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: PlanType.values.map((plan) {
                      final isSelected = _selectedPlan == plan;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ActionChip(
                            label: Center(
                              child: Text(
                                plan.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                            ),
                            backgroundColor: isSelected ? brandColor : null,
                            side: isSelected ? BorderSide.none : null,
                            onPressed: () =>
                                setState(() => _selectedPlan = plan),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 48),

                  // ── Submit Button ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add ${_selectedPlatform.label} Account',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.accentSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          ),
        ),
      ],
    );
  }

  String _getTokenLabel() {
    switch (_selectedPlatform) {
      case AiPlatform.github:
        return 'GitHub Access Token';
      case AiPlatform.codeium:
        return 'API Key';
      default:
        return 'Session Token / Cookie';
    }
  }

  String _getTokenHint() {
    switch (_selectedPlatform) {
      case AiPlatform.github:
        return 'ghp_...';
      default:
        return 'Paste the token from your IDE settings';
    }
  }
}

class ListSelectionTile extends StatelessWidget {
  final AiPlatform platform;
  final bool isSelected;
  final VoidCallback onTap;

  const ListSelectionTile({
    super.key,
    required this.platform,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? platform.brandColor.withAlpha(20) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              platform.icon,
              color: isSelected ? platform.brandColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              platform.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? platform.brandColor : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: platform.brandColor,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
