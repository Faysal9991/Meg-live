//Nav
const STREAMING_LIST = 0;
// Search is under construction and hidden from the production navigation.
// const SEARCH = 1;
const LIVE_STREAM = 1;
const CHATS = 2;
const PROFILE = 3;

// Notification
const NOTIFY_STREAM_FOLLOWER = 'STREAM_LIVE';
const NOTIFY_CHAT = 'CHAT';
const NOTIFY_GROUP_CHAT = 'GROUP_CHAT';

const LOAD_GIFTS = 'load_gifts';
const LOAD_PROFILE = 'load_profile';
const UPDATE_PROFILE = 'update_profile';
const SEND_GIFT = 'send_gift';
const GAME = 'game';
const FORTUNE_WHEEL = 'fortune_wheel';
const FRUIT_GAME = 'fruit_game';
const DICE_ROLLER = 'dice_roller';
const TEEN_PATTI = 'teen_patti';
final CHECK_DEVICE_BLOCKED = 'check_device_blocked';

const kDefaultPadding = 20.0;
const VIDEO_AS_CONTAINER = true;

// Live Room
const STREAMING = 'streaming';
const DELETE_LIVE = 'delete_live';
const UPDATE_CAMERA_FILTER = 'update_camera_filter';
const ALLOW_COMMENT_EMOJI_SEND = 'allow_comment_emoji_send';
const ADD_USER_TO_CALLING_GROUP = 'add_user_to_calling_group';
const REMOVE_USER_FROM_CALLING_GROUP = 'remove_user_from_calling_group';
const UPDATE_LIVE_LOCK = 'update_live_lock';
const UPDATE_VIEWERS_COUNT = 'update_viewers_count';
const UPDATE_LIVE_PAKCAGE_THEME = 'update_live_package_theme';
const LIVE_ROOM_BLOCKS = 'live_room_blocks';

const bool kIsDevEnv = false;

// thresholds for live group rooms
// Total 9 rooms in group call
const int kHighQualityMaxParticipants = 1; //HD(1280x720)
const int kMediumQualityMaxParticipants = kIsDevEnv ? 2 : 4; //QHD(960x540)
const int kLowQualityMaxParticipants = kIsDevEnv ? 3 : 6; //SD(640x360)
// more than kLowQualityMaxParticipants is QSD(320x180)

String refineDeviceName({required String deviceName}) {
  String refinedName = '';
  for (int i = 0; i < deviceName.length; i++) {
    String char = deviceName[i];
    if (specialCharacters.contains(char)) {
      refinedName += '_';
    } else {
      refinedName += char;
    }
  }
  return refinedName;
}

List<String> specialCharacters = [
  '~',
  '`',
  '!',
  '@',
  '#',
  '%',
  '^',
  '&',
  '*',
  '(',
  ')',
  '-',
  '+',
  '=',
  "[",
  "{",
  "]",
  '}',
  '|',
  ':',
  ';',
  '"',
  "'",
  ',',
  '<',
  '.',
  '>',
  '.',
  '?',
  '/',
  "\\",
  "\$",
];

// 👍 thumbsup
// 👌 ok_hand
// 👏 clap
const List<String> listEmojiLikeKeywordName = ['thumbsup', 'ok_hand', 'clap'];

// I/flutter (23134): 😍 heart_eyes ,
// I/flutter (23134): 🥰 smiling_face_with_3_hearts ,
// I/flutter (23134): 😘 kissing_heart ,
// I/flutter (23134): 😙 kissing_smiling_eyes ,
// I/flutter (23134): 😚 kissing_closed_eyes ,
// I/flutter (23134): 🤗 hugging ,
const List<String> listEmojiSmileKeywordName = [
  'heart_eyes',
  'smiling_face_with_3_hearts',
  'kissing_heart',
  'kissing_smiling_eyes',
  'kissing_closed_eyes',
  'hugging',
];

// I/flutter (23134): 💕 two_hearts ,
// I/flutter (23134): 💞 revolving_hearts ,
// I/flutter (23134): 💓 heartbeat ,
// I/flutter (23134): 💗 heartpulse ,
// I/flutter (23134): 💖 sparkling_heart ,
// I/flutter (23134): 💘 cupid ,
// I/flutter (23134): 💝 gift_heart ,
const List<String> listEmojiHeartKeywordName = [
  'two_hearts',
  'revolving_hearts',
  'heartbeat',
  'heartpulse',
  'sparkling_heart',
  'cupid',
  'gift_heart',
];

// I/flutter (26025): 😀 grinning
// I/flutter (26025): 😃 smiley
// I/flutter (26025): 😄 smile
// I/flutter (26025): 😁 grin
// I/flutter (26025): 😆 laughing
// I/flutter (26025): 😅 sweat_smile
// I/flutter (26025): 😂 joy
// I/flutter (26025): 🤣 rofl
// I/flutter (26025): 😝 stuck_out_tongue_closed_eyes
// I/flutter (26025): 🤡 clown
// I/flutter (26025): 😹 joy_cat
const List<String> listEmojiHaHaKeywordName = [
  'grinning',
  'smiley',
  'smile',
  'grin',
  'laughing',
  'sweat_smile',
  'joy',
  'rofl',
  'stuck_out_tongue_closed_eyes',
  'clown',
  'joy_cat',
];
