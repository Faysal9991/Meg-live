import 'dart:io';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_text_styles.dart';
import 'package:doyel_live/app/utils/api_client.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum FeedbackCategory {
  general('general', 'General feedback'),
  bug('bug', 'Report a problem'),
  userReport('user_report', 'Report a user or content'),
  childSafety('child_safety', 'Child safety concern');

  const FeedbackCategory(this.value, this.label);
  final String value;
  final String label;
}

/// In-app feedback and abuse reporting. Submissions are sent to the backend
/// so users never have to leave the app.
class FeedbackView extends StatefulWidget {
  const FeedbackView({
    super.key,
    this.initialCategory = FeedbackCategory.general,
    this.reportedUserId,
    this.channelName,
  });

  final FeedbackCategory initialCategory;
  final int? reportedUserId;
  final String? channelName;

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final AuthController _authController = Get.find();
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  late FeedbackCategory _category = widget.initialCategory;
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    String? appVersion;
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    final data = {
      'category': _category.value,
      'message': _messageController.text.trim(),
      if (widget.reportedUserId != null)
        'reported_user_id': widget.reportedUserId,
      if (widget.channelName != null) 'channel_name': widget.channelName,
      'platform': Platform.operatingSystem,
      'app_version': appVersion,
    };

    try {
      final response = await createApiDio().post(
        kFeedbackCreateUrl,
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Token ${_authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
        data: data,
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw Exception('Unexpected status $statusCode');
      }
      if (!mounted) return;
      Get.back();
      Get.snackbar(
        'Thank you',
        'Your submission has been received. Our team will review it.',
        backgroundColor: AppColors.success,
        colorText: AppColors.onLight,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      Get.snackbar(
        'Failed',
        'Could not send right now. Please check your connection and try again.',
        backgroundColor: AppColors.error,
        colorText: AppColors.onLight,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Feedback'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('What is this about?',
                    style: AppTextStyles.sectionTitle),
                const SizedBox(height: 12),
                AppCard(
                  child: RadioGroup<FeedbackCategory>(
                    groupValue: _category,
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                    child: Column(
                      children: [
                        for (final category in FeedbackCategory.values)
                          RadioListTile<FeedbackCategory>(
                            value: category,
                            title: Text(category.label),
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.reportedUserId != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Reporting user ID: ${widget.reportedUserId}',
                    style: AppTextStyles.caption,
                  ),
                ],
                if (_category == FeedbackCategory.childSafety) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Reports about child sexual abuse or exploitation are '
                    'reviewed as a priority and the content is removed and '
                    'reported to the relevant authorities. If a child is in '
                    'immediate danger, contact local emergency services.',
                    style: AppTextStyles.caption,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  minLines: 5,
                  maxLines: 10,
                  maxLength: 2000,
                  decoration: const InputDecoration(
                    labelText: 'Details',
                    hintText: 'Describe the issue or share your feedback',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 10
                      ? 'Please enter at least 10 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
