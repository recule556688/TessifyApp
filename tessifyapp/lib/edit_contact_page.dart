import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_contact.dart';

class EditContactPage extends StatefulWidget {
  final CustomContact contact;
  final Function(CustomContact) onEditContact;

  const EditContactPage({
    Key? key,
    required this.contact,
    required this.onEditContact,
  }) : super(key: key);

  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _relationshipController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _phoneNumberController =
        TextEditingController(text: widget.contact.phoneNumber);
    _relationshipController =
        TextEditingController(text: widget.contact.relationship);
    _selectedDate = widget.contact.birthday;
  }

  Future<void> _selectBirthdate() async {
    DateTime initialDate = _selectedDate ?? DateTime.now();
    if (initialDate.isAfter(DateTime.now())) {
      initialDate = DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(labelText: 'Relationship'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Birthdate:'),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : 'Not set',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectBirthdate,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedContact = CustomContact(
                  id: widget.contact.id,
                  name: _nameController.text,
                  phoneNumber: _phoneNumberController.text,
                  relationship: _relationshipController.text,
                  birthday: _selectedDate,
                );
                widget.onEditContact(updatedContact);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }
}
