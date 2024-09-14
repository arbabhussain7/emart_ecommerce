import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/firebase_const.dart';
import 'package:emart_app/controllers/home_controllers.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ChatContoller extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getChatId();
  }

  var chats = firestore.collection(chatsCollection);
  var friendName = Get.arguments[0];
  var friendId = Get.arguments[1];
  var senderName = Get.find<HomeControllers>().username;
  var currentId = currentUser!.uid;
  var msgController = TextEditingController();
  dynamic chatDocId;
  var isLoading = false.obs;
  getChatId() async {
    isLoading(true);
    await chats
        .where('user', isEqualTo: {friendId: null, currentId: null})
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
          if (snapshot.docs.isNotEmpty) {
            chatDocId = snapshot.docs.single.id;
          } else {
            chats.add({
              'create_on': null,
              "last_msg": "",
              "users": {friendId: null, currentId: null},
              "toId": "",
              "fromId": "",
              "friend_name": friendName,
              "sender_name": senderName,
            }).then((value) {
              chatDocId = value.id;
            });
          }
        });
    isLoading(false);
  }

  sendMsg(String msg) async {
    print(chatDocId);
    if (msg.trim().isNotEmpty) {
      chats.doc(chatDocId).update({
        "created_on": FieldValue.serverTimestamp(),
        "last_msg": msg,
        "toId": friendId,
        "fromId": currentId,
      });

      chats.doc(chatDocId).collection(messagesCollection).doc().set({
        "created_on": FieldValue.serverTimestamp(),
        "msg": msg,
        "uid": currentId,
      });
    }
  }
}
