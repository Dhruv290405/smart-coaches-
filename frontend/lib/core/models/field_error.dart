class FieldError {
  final String path;
  final String message;

  FieldError({required this.path, required this.message});

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      path: json['path'],
      message: json['msg'],
    );
  }
}
