class EventModel {
  final int? id;
  final String name;
  final String date;
  final String? location;
  final String? description;
  final int userId;

  EventModel({
    this.id,
    required this.name,
    required this.date,
    this.location,
    this.description,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      userId: map['userId'],
    );
  }
}
