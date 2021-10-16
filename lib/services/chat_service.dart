import 'dart:io';

import 'package:LIVE365/models/new_message_system.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  FirebaseStorage storage = FirebaseStorage.instance;

  deleteMessage(String chatId, String msgId) async {
    await chatRef.doc("$chatId").collection("messages").doc(msgId).delete();
  }

  deleteConversation(String chatId) async {
    await chatRef.doc("$chatId").delete();
  }

  sendMessage(Message message, String chatId) async {
    await chatRef
        .doc("$chatId")
        .collection("messages")
        .doc(message.msgId)
        .set(message.toJson());
    await chatRef.doc("$chatId").update({"lastTextTime": Timestamp.now()});
  }

  Future<String> sendFirstMessage(Message message, String recipient) async {
    User user = firebaseAuth.currentUser;
    DocumentReference ref = await chatRef.add({
      'users': [recipient, user.uid],
    });
    await sendMessage(message, ref.id);
    return ref.id;
  }

  Future<String> uploadImage(File image, String chatId) async {
    Reference storageReference =
        storage.ref().child("chats").child(chatId).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }

  setUserRead(String chatId, User user, int count) async {
    DocumentSnapshot snap = await chatRef.doc(chatId).get();
    Map reads = snap.data()['reads'] ?? {};
    reads[user?.uid] = count;
    await chatRef.doc(chatId).update({'reads': reads});
  }

  setUserTyping(String chatId, User user, bool userTyping) async {
    DocumentSnapshot snap = await chatRef.doc(chatId).get();
    Map typing = snap.data()['typing'] ?? {};
    typing[user?.uid] = userTyping;
    await chatRef.doc(chatId).update({
      'typing': typing,
    });
  }
}
