import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/balance/controllers/balance_controller.dart';
import 'package:doyel_live/app/modules/balance/models/withdraw_models.dart';

class TestAuthController extends AuthController {
  @override
  void initialize() {}
}

Profile buildTestProfile({
  int uid = 999,
  String fullName = 'Test User',
  String phone = '01700000000',
}) {
  final profile = Profile();
  profile.user = ProfileUser()
    ..uid = uid
    ..phone = phone;
  profile.full_name = fullName;
  profile.profile_image = null;
  profile.photo_url = null;
  profile.diamonds = 1000;
  profile.followers = <dynamic>[];
  profile.blocks = <dynamic>[];
  profile.level = <String, dynamic>{'level': 1};
  profile.vvip_or_vip_preference = <String, dynamic>{};
  profile.is_agent = false;
  profile.is_reseller = false;
  profile.is_host = false;
  profile.is_moderator = false;
  profile.login_type = 'password_login';
  return profile;
}

class TestBalanceController extends BalanceController {
  TestBalanceController() : super();

  int createStatusCode = 201;

  @override
  Future<void> loadWithdrawRequests() async {}

  @override
  Future<void> loadWithdrawOptions() async {}

  @override
  Future<int> createWithdrawRequest({
    required WithdrawRequestCreateRequest request,
  }) async {
    return createStatusCode;
  }
}
