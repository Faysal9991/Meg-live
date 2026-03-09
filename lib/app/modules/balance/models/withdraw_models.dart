import 'package:doyel_live/app/utils/model_parsers.dart';

class WithdrawRequestItem {
  const WithdrawRequestItem({
    required this.id,
    required this.paymentMethod,
    required this.paymentMethodName,
    required this.accountType,
    required this.amount,
    required this.receivedAmount,
    required this.receiverNumber,
    required this.feedback,
    required this.isPending,
    required this.isAccepted,
    required this.isDeclined,
    required this.requestedDatetime,
  });

  final int id;
  final Map<String, dynamic> paymentMethod;
  final String paymentMethodName;
  final String? accountType;
  final double amount;
  final double receivedAmount;
  final String receiverNumber;
  final String? feedback;
  final bool isPending;
  final bool isAccepted;
  final bool isDeclined;
  final DateTime? requestedDatetime;

  factory WithdrawRequestItem.fromJson(Map<String, dynamic> json) {
    return WithdrawRequestItem(
      id: intFromDynamic(json['id']),
      paymentMethod: mapFromDynamic(json['payment_method']),
      paymentMethodName: firstStringFromKeys(json, const [
        'payment_method_name',
        'name',
      ]),
      accountType: nullableStringFromDynamic(json['account_type']),
      amount: doubleFromDynamic(json['amount']),
      receivedAmount: doubleFromDynamic(json['received_amount']),
      receiverNumber: (json['receiver_number'] ?? '').toString(),
      feedback: nullableStringFromDynamic(json['feedback']),
      isPending: boolFromDynamic(json['is_pending']),
      isAccepted: boolFromDynamic(json['is_accepted']),
      isDeclined: boolFromDynamic(json['is_declined']),
      requestedDatetime: dateTimeFromDynamic(json['requested_datetime']),
    );
  }
}

class WithdrawRequestCreateRequest {
  const WithdrawRequestCreateRequest({
    required this.withdrawPackageId,
    required this.paymentMethodId,
    required this.receiverNumber,
    this.accountType,
  });

  final int withdrawPackageId;
  final int paymentMethodId;
  final String receiverNumber;
  final String? accountType;

  Map<String, dynamic> toJson() {
    return {
      'withdraw_package_id': withdrawPackageId.toString(),
      'payment_method_id': paymentMethodId.toString(),
      'receiver_number': receiverNumber,
      'account_type': accountType,
    };
  }
}

class WithdrawPackageOption {
  const WithdrawPackageOption({
    required this.id,
    required this.label,
    required this.raw,
  });

  final int id;
  final String label;
  final Map<String, dynamic> raw;

  factory WithdrawPackageOption.fromJson(Map<String, dynamic> json) {
    final diamonds = json.containsKey('diamonds')
        ? intFromDynamic(json['diamonds'])
        : null;
    final price = nullableStringFromDynamic(json['price']);
    final fallbackLabel = <String>[
      if (diamonds != null) '$diamonds Diamonds',
      if (price != null) '$price BDT',
    ].join(' • ');
    return WithdrawPackageOption(
      id: intFromDynamic(json['id']),
      label: firstStringFromKeys(
        json,
        const ['title', 'name', 'label', 'package_name'],
        defaultValue: fallbackLabel.isEmpty
            ? 'Package #${intFromDynamic(json['id'])}'
            : fallbackLabel,
      ),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.id,
    required this.name,
    required this.requiresAccountType,
    required this.raw,
  });

  final int id;
  final String name;
  final bool requiresAccountType;
  final Map<String, dynamic> raw;

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) {
    final accountTypes = json['account_types'];
    return PaymentMethodOption(
      id: intFromDynamic(json['id']),
      name: firstStringFromKeys(json, const [
        'name',
        'title',
        'payment_method_name',
        'label',
      ], defaultValue: 'Method #${intFromDynamic(json['id'])}'),
      requiresAccountType: _hasAccountTypes(accountTypes),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static bool _hasAccountTypes(dynamic accountTypes) {
    if (accountTypes == null) {
      return false;
    }
    if (accountTypes is List) {
      for (final dynamic accountType in accountTypes) {
        if (nullableStringFromDynamic(accountType) != null) {
          return true;
        }
      }
      return false;
    }
    if (accountTypes is Map) {
      return accountTypes.isNotEmpty;
    }
    return nullableStringFromDynamic(accountTypes) != null;
  }
}
