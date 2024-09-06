class Contact {
  String name;
  String phoneNumber;
  String relationship;
  DateTime birthdate;

  Contact({
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    required this.birthdate,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      relationship: json['relationship'],
      birthdate: DateTime.parse(json['birthdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'birthdate': birthdate.toIso8601String(),
    };
  }
}
