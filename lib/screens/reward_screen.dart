import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';

import '../services/reward_service.dart';
import '../services/audio_service.dart';

class RewardScreen extends StatelessWidget {
  RewardScreen({super.key});

  final RewardService rewardService = RewardService();

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;
    final background = theme.scaffoldBackgroundColor;
    final surface = theme.cardColor;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text("Recompensas"),
        centerTitle: true,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            );
          }

          var userData = userSnapshot.data!.data() as Map<String, dynamic>;

          String? familyCode = userData['familyCode'];

          if (familyCode == null || familyCode.isEmpty) {
            return Center(
              child: Text(
                "Código da família não encontrado",
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: rewardService.getRewards(familyCode),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: primary,
                  ),
                );
              }

              var rewards = snapshot.data?.docs ?? [];

              if (rewards.isEmpty) {
                return Center(
                  child: Text(
                    "Nenhuma recompensa",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  var reward = rewards[index];

                  String title = reward['title'] ?? "Sem nome";

                  int cost = reward['cost'] ?? 0;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    margin: EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.08),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.card_giftcard,
                          color: primary,
                        ),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Custo: $cost pontos",
                        ),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            // SOM DA RECOMPENSA
                            await AudioService.playRewardRedeemed();

                            // VIBRAÇÃO
                            if (await Vibration.hasVibrator() ?? false) {
                              Vibration.vibrate(
                                duration: 250,
                              );
                            }

                            await rewardService.redeemReward(
                              reward.id,
                              userId,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primary,
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  "Recompensa resgatada!",
                                ),
                              ),
                            );
                          } catch (e) {
                            // VIBRAÇÃO DE ERRO
                            if (await Vibration.hasVibrator() ?? false) {
                              Vibration.vibrate(
                                duration: 500,
                              );
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  "Pontos insuficientes",
                                ),
                              ),
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
