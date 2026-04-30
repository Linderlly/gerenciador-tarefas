import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //Criar recompensa
  Future<void> createReward({required String title, required int cost}) async {
    await _db.collection('rewards').add({'title': title, 'cost': cost});
  }

  //Listar recompensas
  Stream<QuerySnapshot> getRewards() {
    return _db.collection('rewards').snapshots();
  }

  //Resgatar recompensa
  Future<void> redeemReward({
    required String rewardId,
    required String userId,
    required int cost,
  }) async {
    var userRef = _db.collection('users').doc(userId);

    await _db.runTransaction((transaction) async {
      var userDoc = await transaction.get(userRef);

      int currentPoints = userDoc['points'] ?? 0;

      if (currentPoints >= cost) {
        transaction.update(userRef, {'points': currentPoints - cost});
      } else {
        throw Exception("Pontos insuficientes");
      }
    });
  }
}
