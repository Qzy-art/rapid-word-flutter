import 'package:flutter/material.dart';

import '../../models/word_book.dart';

class WrongWordsPage extends StatelessWidget {
  const WrongWordsPage({
    super.key,
    required this.words,
    required this.onReviewWrongPressed,
  });

  final List<WordItem> words;
  final VoidCallback onReviewWrongPressed;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 900;

    if (isCompact) {
      return ListView(
        children: [
          _WrongSummaryCard(words: words, onReviewWrongPressed: onReviewWrongPressed),
          const SizedBox(height: 16),
          ...words.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _WrongWordCard(word: word),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _WrongSummaryCard(words: words, onReviewWrongPressed: onReviewWrongPressed),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: ListView.separated(
            itemCount: words.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _WrongWordCard(word: words[index]),
          ),
        ),
      ],
    );
  }
}

class _WrongSummaryCard extends StatelessWidget {
  const _WrongSummaryCard({
    required this.words,
    required this.onReviewWrongPressed,
  });

  final List<WordItem> words;
  final VoidCallback onReviewWrongPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前错词概览', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('${words.length}', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              '错词会在每轮复习后保留，直到你逐步把它们清掉。',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: words.isEmpty ? null : onReviewWrongPressed,
              child: const Text('继续刷错词'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WrongWordCard extends StatelessWidget {
  const _WrongWordCard({required this.word});

  final WordItem word;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        title: Text(word.word),
        subtitle: Text(
          [
            if (word.phonetic.isNotEmpty) word.phonetic,
            if (word.partOfSpeech.isNotEmpty) word.partOfSpeech,
            word.meaning,
          ].join('  '),
        ),
        trailing: const Icon(Icons.warning_amber_rounded),
      ),
    );
  }
}
