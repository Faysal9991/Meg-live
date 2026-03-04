import 'dart:convert';

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

  Profile();
  Profile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        diamonds = json['diamonds'] ?? 0,
        gift_diamonds = json['gift_diamonds'] ?? 0,
        loves = json['loves'] ?? 0,
        level = json['level'],
        vvip_or_vip_preference = jsonDecode(json['vvip_or_vip_preference']),
        user = ProfileUser.fromJson(json['user']),
        followers = json['followers'],
        blocks = json['blocks'],
        full_name = json['full_name'],
        login_type = json['login_type'],
        uid = json['uid'],
        email = json['email'],
        slug = json['slug'],
        profile_image = json['profile_image'],
        photo_url = json['photo_url'],
        phone_code = json['phone_code'],
        is_locked_diamonds = json['is_locked_diamonds'],
        is_reseller = json['is_reseller'],
        is_moderator = json['is_moderator'],
        is_agent = json['is_agent'],
        is_host = json['is_host'],
        be_reseller_datetime = json['be_reseller_datetime'],
        be_moderator_datetime = json['be_moderator_datetime'],
        registered_date = json['registered_date'],
        updated_date = json['updated_date'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'diamonds': diamonds,
        'gift_diamonds': gift_diamonds,
        'loves': loves,
        'user': user,
        'level': level,
        'vvip_or_vip_preference': jsonEncode(vvip_or_vip_preference),
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

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'phone': phone,
      };
}
