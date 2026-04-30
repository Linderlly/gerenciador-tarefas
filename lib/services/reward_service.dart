import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CRIAR RECOMPENSA
  Future<void> createReward({
    required String title,
    required int cost,
    required String familyCode,
  }) async {
    await _db.collection('rewards').add({
      'title': title,
      'cost': cost,
      'familyCode': familyCode,
      'createdAt': Timestamp.now(),
    });
  }

  // LISTAR RECOMPENSAS
  Stream<QuerySnapshot> getRewards(String familyCode) {
    return _db
        .collection('rewards')
        .where('familyCode', isEqualTo: familyCode)
        .snapshots();
  }

  // RESGATAR RECOMPENSA
  Future<void> redeemReward(String rewardId, String userId) async {
    var rewardRef = _db.collection('rewards').doc(rewardId);
    var userRef = _db.collection('users').doc(userId);

    await _db.runTransaction((transaction) async {
      var rewardDoc = await transaction.get(rewardRef);
      var userDoc = await transaction.get(userRef);

      if (!rewardDoc.exists || !userDoc.exists) return;

      int cost = rewardDoc['cost'] ?? 0;
      int currentPoints = userDoc['points'] ?? 0;

      if (currentPoints >= cost) {
        transaction.update(userRef, {'points': currentPoints - cost});
      } else {
        throw Exception("Pontos insuficientes");
      }
    });
  }
}
