class DummyData {
  final int userId;
  final int id;
  final String title;
  final String body;

  const DummyData({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory DummyData.fromJson(Map<String, dynamic> json) {
    return DummyData(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}