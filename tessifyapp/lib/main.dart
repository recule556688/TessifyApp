import 'package:flutter/material.dart';
import 'shared_prefs_util.dart';
import 'custom_contact.dart';
import 'calendar_page.dart';
import 'contact_management_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<CustomContact> customContacts = [];
  Set<String> transformedEventIds = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadTransformedEventIds();
  }

  Future<void> _loadContacts() async {
    final loadedContacts = await SharedPrefsUtil.loadContacts();
    setState(() {
      customContacts = loadedContacts;
    });
  }

  Future<void> _loadTransformedEventIds() async {
    final loadedTransformedEventIds =
        await SharedPrefsUtil.loadTransformedEventIds();
    setState(() {
      transformedEventIds = loadedTransformedEventIds;
    });
  }

  void _addContact(CustomContact contact) {
    setState(() {
      customContacts.add(contact);
      SharedPrefsUtil.saveContacts(customContacts);
    });
  }

  void _deleteContact(CustomContact contact) {
    setState(() {
      customContacts.remove(contact);
      SharedPrefsUtil.saveContacts(customContacts);
      transformedEventIds.remove(contact.id);
      SharedPrefsUtil.saveTransformedEventIds(transformedEventIds);
    });
  }

  void _editContact(int index, CustomContact updatedContact) {
    setState(() {
      customContacts[index] = updatedContact;
      SharedPrefsUtil.saveContacts(customContacts);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      CalendarPage(
        customContacts: customContacts,
        addContact: _addContact,
        deleteContact: _deleteContact,
        transformedEventIds: transformedEventIds,
      ),
      ContactManagementPage(
        customContacts: customContacts,
        addContact: _addContact,
        editContact: _editContact,
        deleteContact: _deleteContact,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
