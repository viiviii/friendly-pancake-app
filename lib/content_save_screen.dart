import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContentSaveScreen extends StatefulWidget {
  const ContentSaveScreen({super.key});

  @override
  State<ContentSaveScreen> createState() => _ContentSaveScreenState();
}

class _ContentSaveScreenState extends State<ContentSaveScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _title;
  String? _description;
  String? _url;
  String? _imageUrl;

  Future<void> _onContentSaved() async {
    _validateFields();
    await _save();
    _moveToHome();
  }

  void _validateFields() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
  }

  Future<void> _save() async {
    final url = Uri.http('localhost:8080', '/api/contents');

    final header = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'url': _url,
      'title': _title,
      'description': _description,
      'imageUrl': _imageUrl,
    });

    final response = await http.post(url, headers: header, body: body);
    assert(response.statusCode == 201, '임시');
  }

  void _moveToHome() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장되었습니다.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _ContentInputField(
                      icon: const Icon(Icons.text_format),
                      labelText: '타이틀',
                      hintText: '등록할 컨텐츠의 타이틀',
                      onSaved: (value) => _title = value,
                    ),
                    _ContentInputField(
                      icon: const Icon(Icons.text_format),
                      labelText: '설명',
                      hintText: '등록할 컨텐츠의 설명',
                      onSaved: (value) => _description = value,
                    ),
                    _ContentInputField(
                      icon: const Icon(Icons.link),
                      labelText: '컨텐츠 URL',
                      hintText: '등록할 컨텐츠의 URL',
                      onSaved: (value) => _url = value,
                    ),
                    _ContentInputField(
                      icon: const Icon(Icons.link),
                      labelText: '썸네일 URL',
                      hintText: '등록할 컨텐츠의 썸네일 URL',
                      onSaved: (value) => _imageUrl = value,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _onContentSaved,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentInputField extends StatelessWidget {
  const _ContentInputField({
    Key? key,
    required this.icon,
    required this.labelText,
    required this.hintText,
    required this.onSaved,
  }) : super(key: key);

  final Icon icon;
  final String labelText;
  final String hintText;
  final FormFieldSetter<String?> onSaved;

  String? _requiredValue(String? value) {
    if (value == null || value.isEmpty) {
      return '등록하기';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        icon: icon,
        labelText: labelText,
        hintText: hintText,
      ),
      validator: _requiredValue,
      onSaved: onSaved,
    );
  }
}
