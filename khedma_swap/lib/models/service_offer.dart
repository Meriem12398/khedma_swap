class ServiceOffer {
  final int id;
  final String title;
  final String description;
  final String city;
  final String offeredBy;
  final String offersSkill;
  final String needsSkill;

  const ServiceOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.offeredBy,
    required this.offersSkill,
    required this.needsSkill,
  });

  factory ServiceOffer.fromJson(Map<String, dynamic> json) {
    return ServiceOffer(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      offeredBy: json['offeredBy'] ?? '',
      offersSkill: json['offersSkill'] ?? '',
      needsSkill: json['needsSkill'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'city': city,
      'offeredBy': offeredBy,
      'offersSkill': offersSkill,
      'needsSkill': needsSkill,
    };
  }
}
