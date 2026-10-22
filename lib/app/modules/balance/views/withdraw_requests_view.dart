import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/modules/balance/controllers/balance_controller.dart';
import 'package:doyel_live/app/modules/balance/models/withdraw_models.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WithdrawRequestsView extends StatefulWidget {
  const WithdrawRequestsView({super.key});

  @override
  State<WithdrawRequestsView> createState() => _WithdrawRequestsViewState();
}

class _WithdrawRequestsViewState extends State<WithdrawRequestsView>
    with SingleTickerProviderStateMixin {
  late final BalanceController _balanceController;
  late final TabController _tabController;
  late final TextEditingController _receiverNumberController;
  late final TextEditingController _accountTypeController;

  int? _selectedWithdrawPackageId;
  int? _selectedPaymentMethodId;

  @override
  void initState() {
    super.initState();
    _balanceController = Get.isRegistered<BalanceController>()
        ? Get.find<BalanceController>()
        : Get.put(BalanceController());
    _tabController = TabController(length: 2, vsync: this);
    _receiverNumberController = TextEditingController();
    _accountTypeController = TextEditingController();
    _balanceController.loadWithdrawRequests();
    _balanceController.loadWithdrawOptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _receiverNumberController.dispose();
    _accountTypeController.dispose();
    super.dispose();
  }

  PaymentMethodOption? get _selectedPaymentMethod {
    for (final option in _balanceController.paymentMethods) {
      if (option.id == _selectedPaymentMethodId) {
        return option;
      }
    }
    return null;
  }

  bool get _showAccountTypeField {
    return _selectedPaymentMethod?.requiresAccountType ?? false;
  }

  Future<void> _submitWithdrawRequest() async {
    if (_selectedWithdrawPackageId == null ||
        _selectedPaymentMethodId == null) {
      rShowSnackBar(
        context: context,
        title: 'Please choose a package and payment method.',
        color: AppColors.warning,
        durationInSeconds: 2,
      );
      return;
    }
    if (_receiverNumberController.text.trim().isEmpty) {
      rShowSnackBar(
        context: context,
        title: 'Receiver number is required.',
        color: AppColors.warning,
        durationInSeconds: 2,
      );
      return;
    }
    if (_showAccountTypeField && _accountTypeController.text.trim().isEmpty) {
      rShowSnackBar(
        context: context,
        title: 'Account type is required for this payment method.',
        color: AppColors.warning,
        durationInSeconds: 2,
      );
      return;
    }

    final statusCode = await _balanceController.createWithdrawRequest(
      request: WithdrawRequestCreateRequest(
        withdrawPackageId: _selectedWithdrawPackageId!,
        paymentMethodId: _selectedPaymentMethodId!,
        receiverNumber: _receiverNumberController.text.trim(),
        accountType: _showAccountTypeField
            ? _accountTypeController.text.trim()
            : null,
      ),
    );

    if (!mounted) {
      return;
    }

    switch (statusCode) {
      case 200:
      case 201:
        _receiverNumberController.clear();
        _accountTypeController.clear();
        setState(() {
          _selectedWithdrawPackageId = null;
          _selectedPaymentMethodId = null;
        });
        _tabController.animateTo(0);
        rShowSnackBar(
          context: context,
          title: 'Withdraw request submitted successfully.',
          color: AppColors.success,
          durationInSeconds: 2,
        );
        break;
      case 203:
        rShowSnackBar(
          context: context,
          title:
              'Withdraw request could not be created. Please review your balance and package.',
          color: AppColors.error,
          durationInSeconds: 3,
        );
        break;
      case 204:
        rShowSnackBar(
          context: context,
          title: 'Withdraw request is not allowed right now.',
          color: AppColors.error,
          durationInSeconds: 3,
        );
        break;
      default:
        rShowSnackBar(
          context: context,
          title: 'Something is wrong. Please try again.',
          color: AppColors.error,
          durationInSeconds: 2,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          title: const Text('Withdraw Requests'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.pinkLight,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.72,
            ),
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.history), text: 'Requests'),
              Tab(icon: Icon(Icons.add_card), text: 'Create'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildRequestList(), _buildCreateForm()],
        ),
      ),
    );
  }

  Widget _buildRequestList() {
    return Obx(() {
      if (_balanceController.loadingWithdrawRequests.value &&
          _balanceController.withdrawRequests.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_balanceController.withdrawRequests.isEmpty) {
        return const Center(child: Text('No withdraw requests yet.'));
      }
      return RefreshIndicator(
        onRefresh: _balanceController.loadWithdrawRequests,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _balanceController.withdrawRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _balanceController.withdrawRequests[index];
            return AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.paymentMethodName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _buildStatusChip(item),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Receiver: ${item.receiverNumber}'),
                    if (item.accountType != null)
                      Text('Account Type: ${item.accountType}'),
                    Text('Amount: ${item.amount}'),
                    Text('Received: ${item.receivedAmount}'),
                    if (item.requestedDatetime != null)
                      Text(
                        'Requested: ${DateFormat.yMMMEd().add_jm().format(item.requestedDatetime!.toLocal())}',
                      ),
                    if (item.feedback != null && item.feedback!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Feedback: ${item.feedback}'),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCreateForm() {
    return Obx(() {
      final loading = _balanceController.loadingWithdrawOptions.value;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (loading && _balanceController.withdrawPackages.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(),
            ),
          DropdownButtonFormField<int>(
            value: _selectedWithdrawPackageId,
            items: _balanceController.withdrawPackages
                .map(
                  (option) => DropdownMenuItem<int>(
                    value: option.id,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedWithdrawPackageId = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Withdraw Package',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedPaymentMethodId,
            items: _balanceController.paymentMethods
                .map(
                  (option) => DropdownMenuItem<int>(
                    value: option.id,
                    child: Text(option.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethodId = value;
                if (!_showAccountTypeField) {
                  _accountTypeController.clear();
                }
              });
            },
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          AppInsetSurface(
            child: TextField(
              controller: _receiverNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Receiver Number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_showAccountTypeField) ...[
            const SizedBox(height: 16),
            AppInsetSurface(
              child: DropdownMenu<String>(
                controller: _accountTypeController,
                enableFilter: true,
                requestFocusOnTap: true,
                expandedInsets: EdgeInsets.zero,
                label: const Text('Account Type'),
                hintText: 'Select or enter account type',
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                ),
                dropdownMenuEntries: _selectedPaymentMethod!.accountTypes
                    .map(
                      (type) =>
                          DropdownMenuEntry<String>(value: type, label: type),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Obx(
            () => rPrimaryElevatedButton(
              onPressed: _balanceController.creatingWithdrawRequest.value
                  ? () {}
                  : _submitWithdrawRequest,
              primaryColor: _balanceController.creatingWithdrawRequest.value
                  ? AppColors.disabledBackground
                  : AppColors.primary,
              buttonText: _balanceController.creatingWithdrawRequest.value
                  ? 'Submitting...'
                  : 'Submit Request',
              fontSize: 16.0,
              borderRadius: AppRadius.button,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatusChip(WithdrawRequestItem item) {
    Color color;
    String label;

    if (item.isAccepted) {
      color = AppColors.success;
      label = 'Accepted';
    } else if (item.isDeclined) {
      color = AppColors.error;
      label = 'Declined';
    } else {
      color = AppColors.warning;
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
