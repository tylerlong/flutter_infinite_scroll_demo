import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

@riverpod
class WordPairs extends _$WordPairs {
  @override
  List<WordPair> build() => [];

  void loadMore() {
    // special: it is not rebuild, it is to change the list when building.
    state.addAll(generateWordPairs().take(10));
  }
}

@riverpod
class SavedWordPairs extends _$SavedWordPairs {
  @override
  Set<WordPair> build() => {};

  void add(WordPair wordPair) {
    state = {...state, wordPair};
  }

  void remove(WordPair wordPair) {
    state.remove(wordPair);
    state = {...state};
  }
}

class ListTileWidget extends ConsumerWidget {
  const ListTileWidget(this.wordPair, {super.key});
  final WordPair wordPair;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedWordPairs = ref.watch(savedWordPairsProvider);
    final alreadySaved = savedWordPairs.contains(wordPair);
    return ListTile(
      title: Text(
        wordPair.asPascalCase,
        style: const TextStyle(fontSize: 18),
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        if (alreadySaved) {
          ref.read(savedWordPairsProvider.notifier).remove(wordPair);
        } else {
          ref.read(savedWordPairsProvider.notifier).add(wordPair);
        }
      },
    );
  }
}

class SavedWidget extends ConsumerWidget {
  const SavedWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedWordPairs = ref.watch(savedWordPairsProvider);
    final tiles = savedWordPairs.map(
      (pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
    final divided = tiles.isNotEmpty
        ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
        : <Widget>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Suggestions'),
      ),
      body: ListView(children: divided),
    );
  }
}

class RandomWordsWidget extends ConsumerWidget {
  const RandomWordsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordPairs = ref.watch(wordPairsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Flutter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const SavedWidget(),
              ),
            ),
            tooltip: 'Saved Word Pairs',
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            if (i.isOdd) return const Divider();
            final index = i ~/ 2;
            if (index >= wordPairs.length) {
              ref.read(wordPairsProvider.notifier).loadMore();
            }
            return ListTileWidget(wordPairs[index]);
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      home: RandomWordsWidget(),
    );
  }
}
