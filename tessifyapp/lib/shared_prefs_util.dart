import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_contact.dart';

class SharedPrefsUtil {
  static const String contactsKey = 'contacts_key';
  static const String transformedEventsKey = 'transformed_events_key';

  static Future<List<CustomContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString(contactsKey);
    if (contactsJson != null) {
      final List<dynamic> decodedJson = jsonDecode(contactsJson);
      return decodedJson.map((json) => CustomContact.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<void> saveContacts(List<CustomContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson =
        jsonEncode(contacts.map((contact) => contact.toJson()).toList());
    await prefs.setString(contactsKey, contactsJson);
  }

  static Future<void> saveTransformedEventIds(Set<String> eventIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(transformedEventsKey, eventIds.toList());
  }

  static Future<Set<String>> loadTransformedEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(transformedEventsKey)?.toSet() ?? {};
  }
}
