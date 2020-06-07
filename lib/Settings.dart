import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();


  @override
  void initState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _usernameController.text = prefs.getDouble('messageFontSize') ?? '10.0';
    _messageController.text = prefs.getDouble('usernameFontSize') ?? '10.0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Font Size',
                  labelText: 'Message Font Size',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Font size is required.'
                    : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Font Size',
                  labelText: 'Username Font Size',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Font size is required.'
                    : null,
              ),
              RaisedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _go(
                      messageFontSize: _messageController.text,
                      usernameFontSize: _usernameController.text,
                    );
                  }
                },
                child: Text('GO!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _go({String messageFontSize, String usernameFontSize}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('messageFontSize', double.parse(messageFontSize) ?? 10.0);
    await prefs.setDouble('usernameFontSize', double.parse(usernameFontSize) ?? 10.0);
  }
}
