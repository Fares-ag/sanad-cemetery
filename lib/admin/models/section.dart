/// Cemetery section/site (e.g. "Section A", "Block 1").
class Section {
  final String id;
  final String name;
  final String? description;

  const Section({
    required this.id,
    required this.name,
    this.description,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };

  Section copyWith({String? id, String? name, String? description}) {
    return Section(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
