import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ylc/AuthorDetails.dart';
import 'package:ylc/Config.dart';
import 'package:ylc/TextMessage.dart';

///
///
///
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

///
///
///
class _HomeState extends State<Home> {
  ScrollController _scrollController;
  StreamController<bool> _controller;
  String apiKey;
  String liveChatId;
  int sleepTime = 0;
  String pageToken;
  List<TextMessage> messages = [];

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = StreamController();
    _initData();
  }

  void _initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    apiKey = prefs.getString('api_key');
    liveChatId = prefs.getString('live_chat_id');

    _loadData();
  }

  ///
  ///
  ///
  void _loadData() async {
    while (true) {
      await Future.delayed(
        Duration(milliseconds: sleepTime),
        () async {
          print('Sleep Time: $sleepTime');

          Uri uri = Uri.parse('${Config.baseApi}/liveChat/messages');
          Map<String, String> qs = {};

          qs['key'] = apiKey;
          qs['liveChatId'] = liveChatId;
          qs['part'] = 'snippet,authorDetails';

          if (pageToken != null) {
            qs['pageToken'] = pageToken;
          }

          uri = uri.replace(queryParameters: qs);

          Response response = await get(uri);

          Map<String, dynamic> body = json.decode(response.body);

          pageToken = body['nextPageToken'];
          sleepTime = body['pollingIntervalMillis'];

          for (Map<String, dynamic> item in body['items']) {
            if (item['snippet']['type'] == 'textMessageEvent' &&
                item['snippet']['hasDisplayContent']) {
              AuthorDetails authorDetails = AuthorDetails();
              authorDetails.displayName = item['authorDetails']['displayName'];
              authorDetails.profileImageUrl =
                  item['authorDetails']['profileImageUrl'];

              TextMessage textMessage = TextMessage();
              textMessage.id = item['id'];
              textMessage.displayMessage = item['snippet']['displayMessage'];
              textMessage.authorDetails = authorDetails;

              messages.add(textMessage);
            }
          }

          _controller.add(true);

          Future.delayed(
              Duration(milliseconds: 300),
              () => _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  ));

          /*
{
  "kind": "youtube#liveChatMessage",
  "etag": etag,
  "id": string,
  "snippet": {
    "type": string,
    "liveChatId": string,
    "authorChannelId": string,
    "publishedAt": datetime,
    "hasDisplayContent": boolean,
    "displayMessage": string,
    "fanFundingEventDetails": {
      "amountMicros": unsigned long,
      "currency": string,
      "amountDisplayString": string,
      "userComment": string
    },
    "textMessageDetails": {
      "messageText": string
    },
    "messageDeletedDetails": {
      "deletedMessageId": string
    },
    "userBannedDetails": {
      "bannedUserDetails": {
        "channelId": string,
        "channelUrl": string,
        "displayName": string,
        "profileImageUrl": string
      },
      "banType": string,
      "banDurationSeconds": unsigned long
    },
    "superChatDetails": {
      "amountMicros": unsigned long,
      "currency": string,
      "amountDisplayString": string,
      "userComment": string,
      "tier": unsigned integer
    },
    "superStickerDetails": {
      "superStickerMetadata": {
        "stickerId": string,
        "altText": string,
        "language": string
      },
      "amountMicros": unsigned long,
      "currency": string,
      "amountDisplayString": string,
      "tier": unsigned integer
    }
  },
  "authorDetails": {
    "channelId": string,
    "channelUrl": string,
    "displayName": string,
    "profileImageUrl": string,
    "isVerified": boolean,
    "isChatOwner": boolean,
    "isChatSponsor": boolean,
    "isChatModerator": boolean
  }
}
           */
        },
      );
    }
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<bool>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          return ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              TextMessage message = messages[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(message.authorDetails.profileImageUrl),
                ),
                title: Text(message.authorDetails.displayName),
                subtitle: Text(message.displayMessage),
              );
            },
            itemCount: messages.length,
          );
        },
      ),
    );
  }
}
