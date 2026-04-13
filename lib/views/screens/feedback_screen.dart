import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_localizations.dart';
import '../../main.dart';
import '../../services/feedback_service.dart';
import '../../theme/app_colors.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/zen_glass_card.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _currentStep = 0;

  final List<String> _featureKeys = [
    'one_tap_connect',
    'multiple_servers_option',
    'safe_connection',
    'simple_clean_ui',
    'bugs',
    'ads',
  ];
  final Set<String> _selectedFeatures = {};
  final TextEditingController _descController = TextEditingController();
  final List<XFile> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _improvementKeys = [
    'vpn_connection',
    'global_server',
    'vpn_connection_speed',
    'secure_connection',
    'user_friendly_ui',
  ];
  final Set<String> _selectedImprovements = {};

  final TextEditingController _finalThoughtsController =
      TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _finalThoughtsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final l10n = AppLocalizations.of(context);
    final maxFiles = AppSession.of(context).appConfig?.maxAttachmentsPerFeedback ?? 2;
    if (_attachments.length >= maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.get('max_attachments').replaceAll('{max}', '$maxFiles')),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        final remainingSlots = maxFiles - _attachments.length;
        _attachments.addAll(selectedImages.take(remainingSlots));
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final l10n = AppLocalizations.of(context);
    final deviceId = AppSession.maybeOf(context)?.deviceId;

    final service = FeedbackService();
    final success = await service.submitFeedback(
      deviceId: deviceId,
      selectedFeatures: _selectedFeatures.toList(),
      description: _descController.text.trim(),
      selectedImprovements: _selectedImprovements.toList(),
      finalThoughts: _finalThoughtsController.text.trim(),
      attachments: _attachments,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.get('feedback_thank_you')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.mintTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit feedback. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _goNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitFeedback();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.primaryBlue, AppColors.deepNavy]
                : [AppColors.pureWhite, AppColors.iceWhite],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.get('feedback'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Row(
                  children: List.generate(3, (i) {
                    final labelKeys = ['details', 'improve', 'submit'];
                    final isActive = i <= _currentStep;
                    final isCurrent = i == _currentStep;
                    return Expanded(
                      child: Row(
                        children: [
                          if (i > 0)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isActive
                                    ? AppColors.mintTeal
                                    : AppColors.ash.withValues(alpha: 0.2),
                              ),
                            ),
                          Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrent
                                      ? AppColors.mintTeal
                                      : isActive
                                          ? AppColors.mintTeal
                                              .withValues(alpha: 0.2)
                                          : AppColors.ash
                                              .withValues(alpha: 0.1),
                                ),
                                child: Center(
                                  child: isActive && !isCurrent
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: AppColors.mintTeal,
                                        )
                                      : Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isCurrent
                                                ? AppColors.deepNavy
                                                : AppColors.ash,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.get(labelKeys[i]),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isCurrent
                                      ? theme.colorScheme.onSurface
                                      : AppColors.ash,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 0
                        ? _buildStep1(theme, l10n)
                        : _currentStep == 1
                            ? _buildStep2(theme, l10n)
                            : _buildStep3(theme, l10n),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _goBack,
                          child: Text(l10n.get('back')),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [AppColors.mintTeal, Color(0xFF4AC4AD)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.mintTeal.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _goNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.deepNavy,
                                  ),
                                )
                              : Text(
                                  _currentStep == 2
                                      ? l10n.get('submit')
                                      : l10n.get('next')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, AppLocalizations l10n) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.get('select_feature_feedback'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _featureKeys.map((key) {
            final label = l10n.get(key);
            final isSelected = _selectedFeatures.contains(key);
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: AppColors.mintTeal.withValues(alpha: 0.15),
              checkmarkColor: AppColors.mintTeal,
              side: BorderSide(
                color: isSelected
                    ? AppColors.mintTeal
                    : AppColors.ash.withValues(alpha: 0.2),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFeatures.add(key);
                  } else {
                    _selectedFeatures.remove(key);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _descController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.get('detailed_description'),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              l10n
                  .get('attachments_label')
                  .replaceAll('{count}', '${_attachments.length}')
                  .replaceAll('{max}', '${AppSession.of(context).appConfig?.maxAttachmentsPerFeedback ?? 2}'),
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.attach_file_rounded, size: 18),
              label: Text(l10n.get('add_file')),
            ),
          ],
        ),
        if (_attachments.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _attachments.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.ash.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.ash.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.image_rounded,
                          color: AppColors.ash,
                        ),
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: GestureDetector(
                          onTap: () => _removeAttachment(index),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.ember,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: AppColors.snow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme, AppLocalizations l10n) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(l10n.get('what_could_be_improved'),
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        ..._improvementKeys.map((key) {
          final label = l10n.get(key);
          final isSelected = _selectedImprovements.contains(key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ZenGlassCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderColor: isSelected
                  ? AppColors.mintTeal.withValues(alpha: 0.5)
                  : null,
              child: CheckboxListTile(
                title: Text(label, style: theme.textTheme.bodyLarge),
                value: isSelected,
                activeColor: AppColors.mintTeal,
                checkColor: AppColors.deepNavy,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedImprovements.add(key);
                    } else {
                      _selectedImprovements.remove(key);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStep3(ThemeData theme, AppLocalizations l10n) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(l10n.get('final_thoughts'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _finalThoughtsController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: l10n.get('additional_thoughts'),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.get('feedback_closing'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.ash,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
