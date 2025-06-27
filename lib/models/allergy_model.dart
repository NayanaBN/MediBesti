class Allergy {
  final String name;

  Allergy({required this.name});

  Map<String, dynamic> toJson() => {'name': name};

  factory Allergy.fromJson(Map<String, dynamic> json) =>
      Allergy(name: json['name']);
}
