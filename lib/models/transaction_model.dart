import 'dart:convert';

// ฟังก์ชันเพื่อแปลง JSON เป็น transactionModel
TransactionModel transactionModelFromJson(String str) => TransactionModel.fromJson(json.decode(str));

// ฟังก์ชันเพื่อแปลง transactionModel เป็น JSON
String transactionModelToJson(TransactionModel data) => json.encode(data.toJson());

class TransactionModel {
  String id;
  String title;
  String content;
  String amount;
  String message;
  DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.content,
    required this.amount,
    required this.message,
    required this.date,
  });

  // ฟังก์ชันเพื่อสร้าง transactionModel จาก JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json["_id"],
        title: json["title"],
        content: json["content"],
        amount: json["amount"],
        message: json["message"],
        date: DateTime.parse(json["date"]), // แปลงค่า date เป็น DateTime
      );

  // ฟังก์ชันเพื่อแปลง PostModel เป็น JSON
  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "content": content,
        "amount": amount,
        "message": message,
        "date": date.toIso8601String(), // แปลง DateTime เป็น ISO 8601 string
      };
}
