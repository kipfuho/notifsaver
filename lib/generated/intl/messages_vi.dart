// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "home": MessageLookupByLibrary.simpleMessage("Trang chủ"),
        "login": MessageLookupByLibrary.simpleMessage("Đăng nhập"),
        "login_google":
            MessageLookupByLibrary.simpleMessage("Đăng nhập với Google"),
        "read": MessageLookupByLibrary.simpleMessage("Đã đọc"),
        "saved": MessageLookupByLibrary.simpleMessage("Đã lưu"),
        "settings_exclusiveApps": MessageLookupByLibrary.simpleMessage(
            "Các ứng dụng không cho phép đọc thông báo"),
        "settings_openNotificationSetting":
            MessageLookupByLibrary.simpleMessage(
                "Mở cài đặt quyền truy cập thông báo"),
        "settings_selectLangugage":
            MessageLookupByLibrary.simpleMessage("Chọn ngôn ngữ"),
        "settings_title": MessageLookupByLibrary.simpleMessage("Cài đặt"),
        "unread": MessageLookupByLibrary.simpleMessage("Chưa đọc")
      };
}
