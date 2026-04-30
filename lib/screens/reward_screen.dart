import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/reward_service.dart';

class RewardScreen extends StatelessWidget {
  final RewardService rewardService = RewardService();

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Recompensas")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = userSnapshot.data!.data() as Map<String, dynamic>;

          String familyCode = userData['familyCode'];

          return StreamBuilder<QuerySnapshot>(
            stream: rewardService.getRewards(familyCode),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var rewards = snapshot.data!.docs;

              if (rewards.isEmpty) {
                return Center(child: Text("Nenhuma recompensa"));
              }

              return ListView.builder(
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  var reward = rewards[index];

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(reward['title']),
                      subtitle: Text("Custo: ${reward['cost']} pontos"),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          try {
                            await rewardService.redeemReward(reward.id, userId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Recompensa resgatada!")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Pontos insuficientes")),
                            );
                          }
                        },
                        child: Text("Resgatar"),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
