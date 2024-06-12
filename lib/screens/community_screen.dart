import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/member.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_chat/widgets/community_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _goal = "";

  List<Member> _list = [];
  final List<ChatUser> _searchList = [];

  bool _isSearching = false;

  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
            onWillPop: () {
              if (_isSearching) {
                setState(() {
                  _isSearching = !_isSearching;
                });
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                leading: Icon(Icons.home),
                title: _isSearching
                    ? TextField(
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Name, Email, ...'),
                        autofocus: true,
                        style:
                            const TextStyle(fontSize: 17, letterSpacing: 0.5),
                        onChanged: (val) {
                          _searchList.clear();

                          // for (var i in _list) {
                          //   if (i.name
                          //           .toLowerCase()
                          //           .contains(val.toLowerCase()) ||
                          //       i.email
                          //           .toLowerCase()
                          //           .contains(val.toLowerCase())) {
                          //     _searchList.add(i);
                          //   }
                          //   setState(() {
                          //     _searchList;
                          //   });
                          // }
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
                      icon: Icon(
                          _isSearching ? Icons.clean_hands : Icons.search)),
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
              ),

              //floating button to add new user
              floatingActionButton: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  child: FloatingActionButton.extended(
                    backgroundColor: Color.fromARGB(255, 244, 118, 118),
                    onPressed: () async {
                      await showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                                content: Stack(
                                  clipBehavior: Clip.none,
                                  children: <Widget>[
                                    Positioned(
                                      right: -40,
                                      top: -40,
                                      child: InkResponse(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const CircleAvatar(
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close),
                                        ),
                                      ),
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: TextFormField(
                                              onSaved: (value) {
                                                _name = value!;
                                              },
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Please enter the Group Name.';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                labelText: "Group Name",
                                                hintText: "eg. Geek Heaven",
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: TextFormField(
                                              onSaved: (value) {
                                                _goal = value!;
                                              },
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Please enter the goal.';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                labelText: "Group goal",
                                                hintText: "To Save IIITA",
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: ElevatedButton(
                                              child: const Text(
                                                'Create',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  iconColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  minimumSize: Size(100, 50)),
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  _formKey.currentState!.save();
                                                  APIs.createCommunity(
                                                      _name, _goal);
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                    },

                    icon: const Icon(
                      Icons.group_add_rounded,
                      color: Colors.white,
                    ), // Use named parameter `icon`
                    label: const Text(
                      'New',
                      style: TextStyle(color: Colors.white),
                    ), // Use named parameter `label`
                  ),
                ),
              ),

              body: Column(
                children: [
                  StreamBuilder(
                    stream: APIs.getAllCommunity(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          if (snapshot.hasData) {
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => Member.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.length == 0) {
                              return Center(
                                child: Container(
                                  child: Text("No Data Found",
                                      style: TextStyle(fontSize: 35)),
                                ),
                              );
                            } else {
                              return ListView.builder(
                                  itemCount: _list.length,
                                  shrinkWrap:
                                      true, // Ensure the ListView doesn't try to expand infinitely
                                  itemBuilder: (context, index) {
                                    return CommunityCard(
                                      member: _list[index],
                                    );
                                  });
                            }
                          } else {
                            return Center(
                              child: Text("No Data Found",
                                  style: TextStyle(fontSize: 35)),
                            );
                          }
                        default:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                      }
                    },
                  ),
                ],
              ),
            )));
  }
}
