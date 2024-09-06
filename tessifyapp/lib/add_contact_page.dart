import 'package:flutter/material.dart';
import 'custom_contact.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class AddContactPage extends StatefulWidget {
  final Function(CustomContact) onAddContact;

  const AddContactPage({super.key, required this.onAddContact});

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _relationshipController;
  DateTime? _birthdate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _relationshipController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final contact = CustomContact(
        id: uuid.v4(),
        name: _nameController.text,
        phoneNumber: _phoneNumberController.text,
        relationship: _relationshipController.text,
        birthday: _birthdate,
      );
      widget.onAddContact(contact);
      Navigator.pop(context);
    }
  }

  void _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _birthdate) {
      setState(() {
        _birthdate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(labelText: 'Relationship'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a relationship';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: _selectBirthdate,
                child: Text(
                  _birthdate == null
                      ? 'Select Birthdate'
                      : 'Birthdate: ${_birthdate!.toLocal()}'.split(' ')[0],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
