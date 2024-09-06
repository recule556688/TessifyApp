import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'custom_contact.dart';
import 'messages_page.dart';
import 'edit_contact_page.dart';
import 'shared_prefs_util.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}

class CalendarPage extends StatefulWidget {
  final List<CustomContact> customContacts;
  final Function(CustomContact) addContact;
  final Function(CustomContact) deleteContact;
  final Set<String> transformedEventIds;

  const CalendarPage({
    Key? key,
    required this.customContacts,
    required this.addContact,
    required this.deleteContact,
    required this.transformedEventIds,
  }) : super(key: key);

  @override
  State<CalendarPage> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      google_calendar.CalendarApi.calendarScope,
    ],
  );

  google_calendar.CalendarApi? _calendarApi;
  List<google_calendar.Event>? _events;
  bool _isSignedIn = false;
  bool _isLoading = false;
  List<int> years =
      List<int>.generate(10, (int index) => DateTime.now().year - index);
  int? selectedYear;
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
    selectedYear = DateTime.now().year;
  }

  Future<void> _checkSignInStatus() async {
    try {
      var currentUser = await _googleSignIn.signInSilently();
      if (currentUser != null) {
        await _onCurrentUserChanged(currentUser);
      }
    } catch (error, stacktrace) {
      debugPrint("Error signing in silently: $error");
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> _onCurrentUserChanged(GoogleSignInAccount? account) async {
    if (!mounted) return;
    if (account != null) {
      try {
        final authHeaders = await account.authHeaders;
        final authenticateClient = GoogleAuthClient(authHeaders);
        _calendarApi = google_calendar.CalendarApi(authenticateClient);
        await _fetchEvents();
        if (!mounted) return;
        setState(() {
          _isSignedIn = true;
        });
      } catch (error, stacktrace) {
        debugPrint("Error on user changed: $error");
        debugPrint(stacktrace.toString());
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isSignedIn = false;
      });
    }
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    try {
      final events = await _calendarApi!.events.list('primary');
      final filteredEvents = events.items?.where((event) {
        final summaryLower = event.summary?.toLowerCase() ?? '';
        final eventYear = event.start?.dateTime?.year ?? DateTime.now().year;
        return (summaryLower.contains('birthday') ||
                summaryLower.contains('anniversaire')) &&
            eventYear == selectedYear &&
            !widget.transformedEventIds.contains(event.id);
      }).toList();
      if (!mounted) return;
      setState(() {
        _events = filteredEvents;
      });
    } catch (error, stacktrace) {
      debugPrint("Error fetching events: $error");
      debugPrint(stacktrace.toString());
    }
  }

  void _transformEventToContact(google_calendar.Event event) async {
    // Remove the words 'birthday' or 'anniversaire' from the event summary
    String cleanedSummary = event.summary
            ?.replaceAll(
                RegExp(r'\b(birthday|anniversaire)\b', caseSensitive: false),
                '')
            .trim() ??
        'No Title';

    final contact = CustomContact(
      id: uuid.v4(),
      name: cleanedSummary,
      relationship: 'Friend',
      phoneNumber: '',
      birthday: event.start?.dateTime,
    );
    widget.addContact(contact);
    setState(() {
      widget.transformedEventIds.add(event.id!);
    });
    SharedPrefsUtil.saveTransformedEventIds(widget.transformedEventIds);
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Center(
        child: Column(
          children: [
            DropdownButton<int>(
              value: selectedYear,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (int? newValue) {
                if (!mounted) return;
                setState(() {
                  selectedYear = newValue;
                  _fetchEvents();
                });
              },
              items: years.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            Expanded(
              child: _isSignedIn
                  ? _events == null
                      ? const CircularProgressIndicator()
                      : ListView.builder(
                          itemCount:
                              _events!.length + widget.customContacts.length,
                          itemBuilder: (context, index) {
                            if (index < _events!.length) {
                              final event = _events![index];
                              final startDate = event.start?.dateTime;
                              final formattedDate = startDate != null
                                  ? DateFormat('EEEE, MMMM d, yyyy')
                                      .format(startDate)
                                  : 'No Date';

                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(event.summary ?? 'No Title',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text(formattedDate,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _transformEventToContact(event);
                                          });
                                        },
                                        child:
                                            const Text('Transform to Contact'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              final contact = widget
                                  .customContacts[index - _events!.length];
                              final formattedDate = contact.birthday != null
                                  ? DateFormat('EEEE, MMMM d, yyyy')
                                      .format(contact.birthday!)
                                  : 'No Birthday';

                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(contact.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text(formattedDate,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MessagesPage(
                                                sender: "Your Name",
                                                receiver: contact.name,
                                                relationship:
                                                    contact.relationship,
                                                age: contact.birthday != null
                                                    ? (DateTime.now().year -
                                                            contact
                                                                .birthday!.year)
                                                        .toString()
                                                    : "Unknown",
                                                initialPhoneNumber:
                                                    contact.phoneNumber,
                                              ),
                                            ),
                                          );
                                        },
                                        child:
                                            const Text('Send Birthday Message'),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditContactPage(
                                                    contact: contact,
                                                    onEditContact:
                                                        (updatedContact) {
                                                      setState(() {
                                                        widget.customContacts[
                                                                index -
                                                                    _events!
                                                                        .length] =
                                                            updatedContact;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text('Edit'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                widget.deleteContact(contact);
                                                widget.transformedEventIds
                                                    .remove(contact.id);
                                              });
                                              SharedPrefsUtil
                                                  .saveTransformedEventIds(
                                                      widget
                                                          .transformedEventIds);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        )
                  : _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            var account = await _googleSignIn.signIn();
                            await _onCurrentUserChanged(account);
                          },
                          child: const Text('Sign in to Google'),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
