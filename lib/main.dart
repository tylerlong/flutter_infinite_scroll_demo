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
    debugPrint('load more');
    state.addAll(generateWordPairs().take(10));
  }
}

class RandomWordsWidget extends ConsumerWidget {
  const RandomWordsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordPairs = ref.watch(wordPairsProvider);
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider();
        final index = i ~/ 2;
        if (index >= wordPairs.length) {
          ref.read(wordPairsProvider.notifier).loadMore();
        }
        return ListTile(
          title: Text(
            wordPairs[index].asPascalCase,
            style: const TextStyle(fontSize: 18),
          ),
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
