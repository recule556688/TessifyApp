import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MessagesPage extends StatefulWidget {
  final String sender;
  final String receiver;
  final String relationship;
  final String age;
  final String? initialPhoneNumber;

  const MessagesPage({
    super.key,
    required this.sender,
    required this.receiver,
    required this.relationship,
    required this.age,
    this.initialPhoneNumber,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  List<String> generatedMessages = [];
  String? selectedSender;
  String? selectedReceiver;
  String? selectedRelationship;
  String? selectedAge;

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.initialPhoneNumber ?? '';
    selectedSender = widget.sender;
    selectedReceiver = widget.receiver;
    selectedRelationship = widget.relationship;
    selectedAge = widget.age;
    _requestPermissions();
  }

  void _requestPermissions() async {
    await [Permission.sms].request();
  }

  Future<void> _generateMessages() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.169:9999/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender': selectedSender,
          'receiver': selectedReceiver,
          'relationship': selectedRelationship,
          'age': selectedAge,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          generatedMessages =
              List<String>.from(jsonDecode(response.body)['messages']);
        });
      } else {
        throw Exception('Failed to generate messages');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _sendSMS(String message, List<String> recipients) async {
    try {
      String result = await sendSMS(message: message, recipients: recipients);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to send SMS')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send SMS'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: selectedSender,
                  decoration: const InputDecoration(
                    labelText: 'Sender',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSender = newValue!;
                    });
                  },
                  items: <String>[widget.sender]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedReceiver,
                  decoration: const InputDecoration(
                    labelText: 'Receiver',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedReceiver = newValue!;
                    });
                  },
                  items: <String>[widget.receiver]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRelationship,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRelationship = newValue!;
                    });
                  },
                  items: <String>[widget.relationship]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedAge,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedAge = newValue!;
                    });
                  },
                  items: <String>[widget.age]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String phone = phoneController.text;
                    if (phone.isNotEmpty) {
                      _generateMessages();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a phone number')),
                      );
                    }
                  },
                  child: const Text('Generate Messages'),
                ),
                const SizedBox(height: 20),
                if (generatedMessages.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: generatedMessages.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(generatedMessages[index]),
                          onTap: () {
                            setState(() {
                              messageController.text = generatedMessages[index];
                            });
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              _sendSMS(messageController.text,
                                  [phoneController.text]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
