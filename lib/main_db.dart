import 'package:cloud_firestore/cloud_firestore.dart';

class MainDBRank{
  List<ToRank> rankList = [];
  String newRankName = '';
  int newRankScore = 0;

  ///ランキング情報取得
  Future getRankListRealtime (String modetx) async {
    final snapshots = FirebaseFirestore.instance.collection(modetx).snapshots();
    await snapshots.listen((snapshot) {
      final docs = snapshot.docs;
      final rankList = docs.map((doc) => ToRank(doc)).toList();
      rankList.sort((a, b) => b.votes.compareTo(a.votes));
      this.rankList = rankList;
      //print(snapshot.docs.map((message) => message.data()).toList());
    });
  }

  ///ランキング情報追加
  Future add(String addText) async {
    final collection = FirebaseFirestore.instance.collection(addText);

    await collection.add({
      'name': newRankName,
      'votes': newRankScore,
    });
  }

  ///ランキング情報更新
  Future fetchBooks() async {
    final snapshot = await FirebaseFirestore.instance.collection('bady').get();
    final rankList = snapshot.docs.map((doc) => ToRank(doc)).toList();
    rankList.sort((a, b) => b.votes.compareTo(a.votes));
    this.rankList = rankList;
  }

  ///ランキング情報削除
  Future deleteBook(List<ToRank> rankList, String crTxt) async {

    await FirebaseFirestore.instance
        .collection(crTxt)
        .doc(rankList[9].documentID)
        .delete();
  }

  ///ランキング情報全削除
  Future deleteCheckedItems() async {
    final references =
    rankList.map((toRank) => toRank.documentReference).toList();

    final batch = FirebaseFirestore.instance.batch();

    references.forEach((reference) {
      batch.delete(reference);
    });
    return batch.commit();
  }
}

///ランキング情報
class ToRank {
  ToRank(DocumentSnapshot doc) {
    this.documentID = doc.id;
    this.documentReference = doc.reference;
    this.title = doc.data()['name'];
    this.votes = doc.data()['votes'];
    this.rankingTxt = "$title:$votes" .toString();
  }
  var documentID;
  String rankingTxt;
  String title;
  int votes;
  //DateTime createdAt;
  bool isDone = false;
  DocumentReference documentReference;
}