import 'package:flutter/material.dart';
import 'custom_contact.dart';
import 'edit_contact_page.dart';
import 'messages_page.dart';
import 'add_contact_page.dart'; // Ensure this import exists

class ContactManagementPage extends StatelessWidget {
  final List<CustomContact> customContacts;
  final Function(CustomContact) addContact;
  final Function(int, CustomContact) editContact;
  final Function(CustomContact) deleteContact;

  const ContactManagementPage({
    Key? key,
    required this.customContacts,
    required this.addContact,
    required this.editContact,
    required this.deleteContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddContactPage(
                    onAddContact: addContact,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: customContacts.length,
        itemBuilder: (context, index) {
          final contact = customContacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Text(contact.relationship),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesPage(
                    sender: "Your Name",
                    receiver: contact.name,
                    relationship: contact.relationship,
                    age: contact.birthday != null
                        ? (DateTime.now().year - contact.birthday!.year)
                            .toString()
                        : "Unknown",
                    initialPhoneNumber: contact.phoneNumber,
                  ),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditContactPage(
                          contact: contact,
                          onEditContact: (editedContact) {
                            editContact(index, editedContact);
                          },
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteContact(contact),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
