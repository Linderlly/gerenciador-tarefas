import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/reward_service.dart';

class RewardScreen extends StatelessWidget {
  final RewardService rewardService = RewardService();

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Recompensas")),
      body: StreamBuilder(
        stream: rewardService.getRewards(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var rewards = snapshot.data.docs;

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
                        await rewardService.redeemReward(
                          rewardId: reward.id,
                          userId: userId,
                          cost: reward['cost'],
                        );

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
      ),
    );
  }
}
