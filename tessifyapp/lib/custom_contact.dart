class CustomContact {
  String id;
  String name;
  String phoneNumber;
  String relationship;
  DateTime? birthday;

  CustomContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.birthday,
  });

  factory CustomContact.fromJson(Map<String, dynamic> json) {
    return CustomContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      relationship: json['relationship'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'birthday': birthday?.toIso8601String(),
    };
  }
}
