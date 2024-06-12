import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:we_chat/screens/profile_screen.dart';

class Tabbar extends StatefulWidget {
  const Tabbar({super.key});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];

  bool _isSearching = false;

  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        //--------------------------------App Bar widget---------------------------------------------//

        appBar: AppBar(
          leading: Icon(Icons.home),
          title: _isSearching
              ? TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Name, Email, ...'),
                  autofocus: true,
                  style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                  onChanged: (val) {
                    _searchList.clear();

                    for (var i in _list) {
                      if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                          i.email.toLowerCase().contains(val.toLowerCase())) {
                        _searchList.add(i);
                      }
                      setState(() {
                        _searchList;
                      });
                    }
                  },
                )
              : Text('we chat'),

          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching ? Icons.clean_hands : Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                                user: APIs.me,
                              )));
                },
                icon: const Icon(Icons.more_vert))
          ],

          //-----------------------------Tab Bar Icon--------------------------------------------------//

          bottom: TabBar(indicatorColor: Colors.black, tabs: [
            Tab(
              icon: Icon(
                Icons.chat,
              ),
              text: 'Chats',
            ),
            Tab(
              icon: Icon(
                Icons.group,
              ),
              text: 'Communities',
            ),
          ]),
        ),

        //-------------------------------Body Widget------------------------------------------------//

        body: TabBarView(
          children: [
            Container(
                child: Center(
                    child: Text(
              'Chats',
              style: TextStyle(fontSize: 30),
            ))),
            Container(
                child: Center(
                    child: Text(
              'Communities',
              style: TextStyle(fontSize: 30),
            ))),
          ],
        ),
      ),
    );
  }
}
