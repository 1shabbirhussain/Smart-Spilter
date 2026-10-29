import 'package:cloud_firestore/cloud_firestore.dart';

/// All app data lives under ONE root collection so the Firebase project can
/// be shared with other apps:
///
/// smart_split/app
///   ├─ users/{uid}                     profile + fcmTokens
///   │    ├─ friends/{friendUid}
///   │    └─ notifications/{id}
///   ├─ usernames/{username}            { uid }  (uniqueness claims)
///   ├─ friendRequests/{from}_{to}
///   └─ groups/{groupId}                group + members[] + memberUids[]
///        ├─ expenses/{expenseId}
///        └─ settlements/{settlementId}
class FsPaths {
  FsPaths._();

  static const rootCollection = 'smart_split';
  static const appDoc = 'app';

  static FirebaseFirestore get _fs => FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> get root =>
      _fs.collection(rootCollection).doc(appDoc);

  static CollectionReference<Map<String, dynamic>> get users =>
      root.collection('users');

  static CollectionReference<Map<String, dynamic>> get usernames =>
      root.collection('usernames');

  static CollectionReference<Map<String, dynamic>> get friendRequests =>
      root.collection('friendRequests');

  static CollectionReference<Map<String, dynamic>> get groups =>
      root.collection('groups');

  static CollectionReference<Map<String, dynamic>> friends(String uid) =>
      users.doc(uid).collection('friends');

  static CollectionReference<Map<String, dynamic>> notifications(String uid) =>
      users.doc(uid).collection('notifications');

  static CollectionReference<Map<String, dynamic>> expenses(String groupId) =>
      groups.doc(groupId).collection('expenses');

  static CollectionReference<Map<String, dynamic>> settlements(
    String groupId,
  ) => groups.doc(groupId).collection('settlements');
}
