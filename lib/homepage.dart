import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fungamesdashboard/scoreboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAppInfoDialog(context),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return StreamBuilder(
  stream: FirebaseFirestore.instance.collection('games').snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final games = snapshot.data!.docs;
    if (games.isEmpty) {
      return const Center(
        child: Text(
          'No games added yet',
          style: TextStyle(fontSize: 18, color: Colors.teal),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 3
                : constraints.maxWidth > 600
                    ? 2
                    : 1,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _buildGameCard(context, game);
      },
    );
  },
);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGameDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Game'),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, DocumentSnapshot game) {
    String imageUrl = game['imageUrl'] ?? ''; // Get image URL or empty string

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScoreboardPage(game.id, game['name']),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.2),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                          onError: (error, stackTrace) {
                            debugPrint("Image Load Error: $error");
                          },
                        )
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? const Icon(Icons.sports_esports,
                        color: Colors.teal, size: 48)
                    : null,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      game['name'],
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGameDialog(BuildContext context) {
    final nameController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Game'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Game Name',
                prefixIcon: Icon(Icons.gamepad),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (Optional)',
                prefixIcon: Icon(Icons.image),
              ),
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
              if (nameController.text.isNotEmpty) {
                String imageUrl = imageUrlController.text.trim();
                FirebaseFirestore.instance.collection('games').add({
                  'name': nameController.text.trim(),
                  'imageUrl': imageUrl.isNotEmpty
                      ? imageUrl
                      : 'https://via.placeholder.com/150', // Default image
                });

                setState(() {}); // Force UI refresh
                Navigator.pop(context);
              }
            },
            child: const Text('Add Game'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Dashboard'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_esports, size: 48, color: Colors.teal),
            SizedBox(height: 16),
            Text(
              'Track and manage game scores across multiple games. Add new games and record player achievements.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
