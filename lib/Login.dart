import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ylc/Config.dart';
import 'package:ylc/Home.dart';

///
///
///
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

///
///
///
class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _videoIdController = TextEditingController();

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Center(
          child: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                SharedPreferences prefs = snapshot.data;

                _apiKeyController.text = prefs.getString('api_key');
                _videoIdController.text = prefs.getString('video_id');

                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'YouTube Live Chat',
                        style: Theme.of(context).textTheme.headline4,
                        textAlign: TextAlign.center,
                      ),
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'API Key',
                          labelText: 'API Key',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'API Key required.'
                            : null,
                      ),
                      TextFormField(
                        controller: _videoIdController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Video ID',
                          labelText: 'Video ID',
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Video ID required.'
                            : null,
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _go(
                              apiKey: _apiKeyController.text,
                              videoId: _videoIdController.text,
                            );
                          }
                        },
                        child: Text('GO!'),
                      ),
                    ],
                  ),
                );
              }

              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  ///
  ///
  ///
  void _go({String apiKey, String videoId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('api_key', apiKey);
    await prefs.setString('video_id', videoId);

    Uri uri = Uri.parse('${Config.baseApi}/videos');
    Map<String, String> qs = {};

    qs['key'] = apiKey;
    qs['id'] = videoId;
    qs['part'] = 'liveStreamingDetails';

    uri = uri.replace(queryParameters: qs);

    Response response = await get(uri);

    Map<String, dynamic> body = json.decode(response.body);

    String liveChatId =
        body['items'].first['liveStreamingDetails']['activeLiveChatId'];

    await prefs.setString('live_chat_id', liveChatId);

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
      (_) => false,
    );
  }
}
