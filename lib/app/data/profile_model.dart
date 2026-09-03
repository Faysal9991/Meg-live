import 'dart:convert';

import 'package:doyel_live/app/data/entry_effect_model.dart';

class Profile {
  int? id, loves, diamonds, gift_diamonds;
  ProfileUser? user;
  List<dynamic>? followers, blocks;
  // # 'iso_code','iso3_code','phone_code','country_name'

  String? login_type,
      uid,
      full_name,
      email,
      slug,
      profile_image,
      photo_url,
      phone_code,
      be_reseller_datetime,
      be_moderator_datetime,
      registered_date,
      updated_date;

  bool? is_locked_diamonds, is_reseller, is_moderator, is_agent, is_host;

  dynamic level, vvip_or_vip_preference;
  EntryEffect? entryEffect;

  Profile();
  Profile.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      diamonds = json['diamonds'] ?? 0,
      gift_diamonds = json['gift_diamonds'] ?? 0,
      loves = json['loves'] ?? 0,
      level = json['level'],
      vvip_or_vip_preference = _parseVvipOrVipPreference(
        json['vvip_or_vip_preference'],
      ),
      entryEffect = _parseEntryEffect(json),
      user = json['user'] is Map<String, dynamic>
          ? ProfileUser.fromJson(json['user'])
          : null,
      followers = json['followers'] ?? <dynamic>[],
      blocks = json['blocks'] ?? <dynamic>[],
      full_name = json['full_name'],
      login_type = json['login_type'],
      uid = json['uid'],
      email = json['email'],
      slug = json['slug'],
      profile_image = json['profile_image'],
      photo_url = json['photo_url'],
      phone_code = json['phone_code'],
      is_locked_diamonds = json['is_locked_diamonds'] ?? false,
      is_reseller = json['is_reseller'] ?? false,
      is_moderator = json['is_moderator'] ?? false,
      is_agent = json['is_agent'] ?? false,
      is_host = json['is_host'] ?? false,
      be_reseller_datetime = json['be_reseller_datetime'],
      be_moderator_datetime = json['be_moderator_datetime'],
      registered_date = json['registered_date'],
      updated_date = json['updated_date'];

  static dynamic _parseVvipOrVipPreference(dynamic value) {
    if (value == null || value == '') {
      return <String, dynamic>{};
    }
    if (value is String) {
      try {
        return jsonDecode(value);
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return value;
  }

  static EntryEffect? _parseEntryEffect(Map<String, dynamic> json) {
    final directEntryEffect = EntryEffect.fromDynamic(json['entry_effect']);
    if (directEntryEffect != null) {
      return directEntryEffect;
    }

    final preference = _parseVvipOrVipPreference(
      json['vvip_or_vip_preference'],
    );
    if (preference is Map) {
      return EntryEffect.fromDynamic(preference['entry_effect']);
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'diamonds': diamonds,
    'gift_diamonds': gift_diamonds,
    'loves': loves,
    'user': user?.toJson(),
    'level': level,
    'vvip_or_vip_preference': jsonEncode(vvip_or_vip_preference),
    'entry_effect': entryEffect?.toJson(),
    'followers': followers,
    'blocks': blocks,
    'full_name': full_name,
    'login_type': login_type,
    'uid': uid,
    'email': email,
    'slug': slug,
    'profile_image': profile_image,
    'photo_url': photo_url,
    'phone_code': phone_code,
    'is_locked_diamonds': is_locked_diamonds,
    'is_reseller': is_reseller,
    'is_moderator': is_moderator,
    'is_agent': is_agent,
    'is_host': is_host,
    'be_reseller_datetime': be_reseller_datetime,
    'be_moderator_datetime': be_moderator_datetime,
    'registered_date': registered_date,
    'updated_date': updated_date,
  };
}

class ProfileUser {
  int? uid;
  String? phone;

  ProfileUser();
  ProfileUser.fromJson(Map<String, dynamic> json)
    : uid = json['uid'],
      phone = json['phone'];

  Map<String, dynamic> toJson() => {'uid': uid, 'phone': phone};
}
