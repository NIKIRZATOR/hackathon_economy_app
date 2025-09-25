class AppResponseModel {
  final dynamic error;
  final dynamic data;
  final dynamic message;

  AppResponseModel({this.error, this.data, this.message});

  factory AppResponseModel.fromJson(Map<String, dynamic> json) {
    return AppResponseModel(
      error: json['error'],
      data: json['data'],
      message: json['message'],
    );
  }

  bool get isOk => error == null;
}
