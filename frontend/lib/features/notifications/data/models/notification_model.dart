class NotificationModel {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String type;
  final String? createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.type,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final isReadRaw = json['is_read'];
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: isReadRaw == 1 || isReadRaw == true,
      type: json['type'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      type: type,
      createdAt: createdAt,
    );
  }
}
