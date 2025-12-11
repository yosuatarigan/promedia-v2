import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) return null;

      return userDoc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get chat messages stream
  Stream<QuerySnapshot> getChatMessages(String noKode, {int limit = 50}) {
    return _firestore
        .collection('chat_messages')
        .where('noKode', isEqualTo: noKode)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Send text message
  Future<void> sendTextMessage(String noKode, String content) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      final userData = await getCurrentUserData();
      if (userData == null) {
        throw Exception('Data user tidak ditemukan');
      }

      await _firestore.collection('chat_messages').add({
        'userId': currentUser.uid,
        'noKode': noKode,
        'userName': userData['namaLengkap'] ?? 'User',
        'userRole': userData['role'] ?? 'Unknown',
        'messageType': 'text',
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal mengirim pesan: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String noKode) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${currentUser.uid}_$timestamp.jpg';
      final path = 'chat_images/$noKode/$fileName';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }

  // Send image message
  Future<void> sendImageMessage(String noKode, File imageFile) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      final userData = await getCurrentUserData();
      if (userData == null) {
        throw Exception('Data user tidak ditemukan');
      }

      // Upload image first
      final imageUrl = await uploadImage(imageFile, noKode);

      // Send message with image URL
      await _firestore.collection('chat_messages').add({
        'userId': currentUser.uid,
        'noKode': noKode,
        'userName': userData['namaLengkap'] ?? 'User',
        'userRole': userData['role'] ?? 'Unknown',
        'messageType': 'image',
        'content': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal mengirim gambar: $e');
    }
  }

  // Get total messages count
  Future<int> getMessagesCount(String noKode) async {
    try {
      final snapshot = await _firestore
          .collection('chat_messages')
          .where('noKode', isEqualTo: noKode)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting messages count: $e');
      return 0;
    }
  }

  // Get last message
  Future<Map<String, dynamic>?> getLastMessage(String noKode) async {
    try {
      final snapshot = await _firestore
          .collection('chat_messages')
          .where('noKode', isEqualTo: noKode)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return snapshot.docs.first.data();
    } catch (e) {
      print('Error getting last message: $e');
      return null;
    }
  }

  // Delete message (only owner can delete)
  Future<void> deleteMessage(String messageId, String userId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != userId) {
        throw Exception('Anda tidak bisa menghapus pesan ini');
      }

      // Get message data
      final messageDoc =
          await _firestore.collection('chat_messages').doc(messageId).get();

      if (!messageDoc.exists) {
        throw Exception('Pesan tidak ditemukan');
      }

      final messageData = messageDoc.data()!;

      // If message is image, delete from storage too
      if (messageData['messageType'] == 'image') {
        final imageUrl = messageData['content'] as String;
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          print('Error deleting image from storage: $e');
        }
      }

      // Delete message document
      await _firestore.collection('chat_messages').doc(messageId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus pesan: $e');
    }
  }
}