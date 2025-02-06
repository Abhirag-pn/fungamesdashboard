import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreboardPage extends StatelessWidget {
  final String gameId;
  final String gameName;
  
  const ScoreboardPage(this.gameId, this.gameName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameName),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('games')
                .doc(gameId)
                .collection('scores')
                .orderBy('score', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final scores = snapshot.data!.docs;
              if (scores.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined, 
                        size: 64, 
                        color: Colors.teal.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text('No scores yet',
                        style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showAddScoreDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Score'),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        _buildTopScores(scores.take(3).toList()),
                        const Divider(height: 32),
                        _buildScoresList(scores.skip(3).toList()),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddScoreDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Score'),
      ),
    );
  }

  Widget _buildTopScores(List<DocumentSnapshot> topScores) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (topScores.length > 1) _buildTopScore(topScores[1], 2, 0.85),
        if (topScores.isNotEmpty) _buildTopScore(topScores[0], 1, 1.0),
        if (topScores.length > 2) _buildTopScore(topScores[2], 3, 0.7),
      ],
    );
  }

  Widget _buildTopScore(DocumentSnapshot score, int position, double scale) {
    final baseHeight = 160.0;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(score['name']+" "+score['class'],
            style: TextStyle(fontSize: 16 * scale),
            overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Container(
            height: baseHeight * scale,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: position == 1 ? Colors.teal : Colors.teal.withOpacity(0.7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8 * scale)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    position == 1 ? Icons.emoji_events : 
                    position == 2 ? Icons.looks_two : Icons.looks_3,
                    color: Colors.white,
                    size: 24 * scale,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    score['score'].toString(),
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresList(List<DocumentSnapshot> scores) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.2),
              child: Text(
                '${index + 4}',
                style: const TextStyle(color: Colors.teal),
              ),
            ),
            title: Text(score['name']),
            subtitle: Text('Class: ${score['class']}'),
            trailing: Text(
              score['score'].toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddScoreDialog(BuildContext context) {
    final nameController = TextEditingController();
    final classController = TextEditingController();
    final scoreController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: classController,
              decoration: const InputDecoration(
                labelText: 'Class',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scoreController,
              decoration: const InputDecoration(
                labelText: 'Score',
                prefixIcon: Icon(Icons.score),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone No(optional)',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && 
                  scoreController.text.isNotEmpty) {
                FirebaseFirestore.instance
                    .collection('games')
                    .doc(gameId)
                    .collection('scores')
                    .add({
                      'name': nameController.text,
                      'class': classController.text,
                      'score': int.tryParse(scoreController.text) ?? 0,
                      'phone': phoneController.text,
                    });
                Navigator.pop(context);
              }
            },
            child: const Text('Add Score'),
          ),
        ],
      ),
    );
  }
}