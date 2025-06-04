import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String nickname;
  final String date;
  final String content;

  const PostDetailScreen({
    Key? key,
    required this.imageUrl,
    required this.nickname,
    required this.date,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('게시물', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text(nickname, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Text('|', style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 8),
                  Text(date, style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  content,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 