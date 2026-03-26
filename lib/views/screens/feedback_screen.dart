import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../widgets/zen_glass_card.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _currentStep = 0;

  final List<String> _features = [
    'One tap connect',
    'Multiple servers',
    'Safe connection',
    'Simple & clean UI',
    'Bugs',
    'Ads',
  ];
  final Set<String> _selectedFeatures = {};
  final TextEditingController _descController = TextEditingController();
  final List<XFile> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _improvements = [
    'VPN Connection',
    'Global Server',
    'VPN connection speed',
    'Secure connection',
    'User-friendly UI',
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
    if (_attachments.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Max 10 attachments allowed.'),
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
        final remainingSlots = 10 - _attachments.length;
        _attachments.addAll(selectedImages.take(remainingSlots));
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thank you for your feedback!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.mintTeal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop();
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
                    final labels = ['Details', 'Improve', 'Submit'];
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
                                labels[i],
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
                        ? _buildStep1(theme)
                        : _currentStep == 1
                            ? _buildStep2(theme)
                            : _buildStep3(theme),
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
                          child: const Text('Back'),
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
                          onPressed: _goNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child:
                              Text(_currentStep == 2 ? 'Submit' : 'Next'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Select a feature to provide feedback',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _features.map((feature) {
            final isSelected = _selectedFeatures.contains(feature);
            return FilterChip(
              label: Text(feature),
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
                    _selectedFeatures.add(feature);
                  } else {
                    _selectedFeatures.remove(feature);
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
          decoration: const InputDecoration(
            hintText: 'Detailed description (Optional)',
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Attachments (${_attachments.length}/10)',
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.attach_file_rounded, size: 18),
              label: const Text('Add File'),
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

  Widget _buildStep2(ThemeData theme) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('What could be improved?', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        ..._improvements.map((item) {
          final isSelected = _selectedImprovements.contains(item);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ZenGlassCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderColor: isSelected
                  ? AppColors.mintTeal.withValues(alpha: 0.5)
                  : null,
              child: CheckboxListTile(
                title: Text(item, style: theme.textTheme.bodyLarge),
                value: isSelected,
                activeColor: AppColors.mintTeal,
                checkColor: AppColors.deepNavy,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedImprovements.add(item);
                    } else {
                      _selectedImprovements.remove(item);
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

  Widget _buildStep3(ThemeData theme) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Final Thoughts', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _finalThoughtsController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add any additional thoughts...',
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'We appreciate your feedback and use it to strictly improve our VPN application.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.ash,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
