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
    state.addAll(generateWordPairs().take(10));
  }
}

@riverpod
class SavedWordPairs extends _$SavedWordPairs {
  @override
  Set<WordPair> build() => {};

  void add(WordPair wordPair) {
    debugPrint('add');
    state.add(wordPair);
    debugPrint('${state.map((e) => e.asPascalCase)}');
  }

  void remove(WordPair wordPair) {
    debugPrint('remove');
    state.remove(wordPair);
  }
}

class RandomWordsWidget extends ConsumerWidget {
  const RandomWordsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordPairs = ref.watch(wordPairsProvider);
    final savedWordPairs = ref.watch(savedWordPairsProvider);
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider();
        final index = i ~/ 2;
        if (index >= wordPairs.length) {
          ref.read(wordPairsProvider.notifier).loadMore();
        }
        final alreadySaved = savedWordPairs.contains(wordPairs[index]);
        debugPrint('$alreadySaved');
        return ListTile(
          title: Text(
            wordPairs[index].asPascalCase,
            style: const TextStyle(fontSize: 18),
          ),
          trailing: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
            semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
          ),
          onTap: () {
            if (alreadySaved) {
              ref
                  .read(savedWordPairsProvider.notifier)
                  .remove(wordPairs[index]);
            } else {
              ref.read(savedWordPairsProvider.notifier).add(wordPairs[index]);
            }
          },
        );
      },
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: const Center(
          child: RandomWordsWidget(),
        ),
      ),
    );
  }
}
