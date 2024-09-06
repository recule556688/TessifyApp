class CustomContact {
  String name;
  String phoneNumber;
  String relationship;
  DateTime? birthday;

  CustomContact({
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    required this.birthday,
  });

  factory CustomContact.fromJson(Map<String, dynamic> json) {
    return CustomContact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      relationship: json['relationship'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'birthday': birthday?.toIso8601String(),
    };
  }
}