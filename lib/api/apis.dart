import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_chat/models/member.dart';
import 'dart:io';
import 'package:we_chat/models/message.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '',
        groups: []);

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //for updating user profile
  static Future<void> updateUser(String name, String about) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': name, 'about': about});
  }

  //for getting all user from database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for storing current user information
  static late ChatUser me;

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${user.uid}.${ext}');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  /***************************** Chat Screen Related APIs ***********************************/

  // function For making conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: Type.text,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessgeReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});

    log('message read updated : ${message.sent}');
  }

  /*****************************Community Related Screen APIs ******************************/

  static Future<void> createCommunity(String name, String goal) async {
    final CollectionReference userCollection =
        FirebaseFirestore.instance.collection("users");
    final CollectionReference groupCollection =
        FirebaseFirestore.instance.collection("community");

    var url =
        "https://images.squarespace-cdn.com/content/v1/5b9580a050a54f9cd774077b/1638822253185-JGN4L0X3H6N72GCCWPDA/creative+coding+2.JPG";

    final Member member = Member(
        cname: name,
        cimage: url,
        cgoal: goal,
        adminid: me.id,
        cid: '',
        members: []);

    DocumentReference docRef = await groupCollection.add(member.toJson());

    await groupCollection.doc(docRef.id).update({
      "members": FieldValue.arrayUnion(["${me.id}_${me.name}"]),
      "cid": docRef.id
    });

    await userCollection.doc(me.id).update({
      "group": FieldValue.arrayUnion(["${docRef.id}_${name}"])
    });
  }

  static late ChatUser Admin;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCommunity() {
    final String member_id = '${me.id}_${me.name}';
    return firestore
        .collection("community")
        .where('members', arrayContains: member_id)
        .snapshots();

    // getAdminDetails(mem);
  }

  //   static Future<void> getAdminDetails(String id) async {
  //   await firestore.collection('users').doc(user.uid).get().then((user) async {
  //     if (user.exists) {
  //       me = ChatUser.fromJson(user.data()!);
  //     } else {
  //       await createUser().then((value) => getAdminDetails());
  //     }
  //   });
  // }
}
