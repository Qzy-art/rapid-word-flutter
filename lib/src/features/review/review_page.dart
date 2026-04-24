import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/word_book.dart';
import '../home/state/home_state.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({
    super.key,
    required this.book,
    required this.words,
    required this.currentIndex,
    required this.mode,
    required this.knownCount,
    required this.unknownCount,
    required this.onRestart,
    required this.onKnown,
    required this.onUnknown,
  });

  final WordBook book;
  final List<WordItem> words;
  final int currentIndex;
  final ReviewMode mode;
  final int knownCount;
  final int unknownCount;
  final VoidCallback onRestart;
  final VoidCallback onKnown;
  final VoidCallback onUnknown;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool _showAnswer = false;
  bool _confirmingKnown = false;
  bool _confirmingUnknown = false;
  Timer? _autoAdvanceTimer;

  @override
  void didUpdateWidget(covariant ReviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex || oldWidget.mode != widget.mode) {
      _cancelAutoAdvance();
      _showAnswer = false;
      _confirmingKnown = false;
      _confirmingUnknown = false;
    }
  }

  @override
  void dispose() {
    _cancelAutoAdvance();
    super.dispose();
  }

  String _syllableHint(String word) {
    final lower = word.toLowerCase();
    const mapped = <String, String>{
      'abandon': 'a·ban·don',
      'ability': 'a·bil·i·ty',
      'abroad': 'a·broad',
      'academic': 'ac·a·dem·ic',
      'access': 'ac·cess',
      'accurate': 'ac·cu·rate',
      'achieve': 'a·chieve',
      'adjust': 'ad·just',
      'advance': 'ad·vance',
      'affect': 'af·fect',
      'agency': 'a·gen·cy',
      'announce': 'an·nounce',
      'approach': 'ap·proach',
      'attempt': 'at·tempt',
      'audience': 'au·di·ence',
      'average': 'av·er·age',
      'benefit': 'ben·e·fit',
      'category': 'cat·e·go·ry',
      'challenge': 'chal·lenge',
      'comment': 'com·ment',
      'commit': 'com·mit',
      'community': 'com·mu·ni·ty',
      'complex': 'com·plex',
      'context': 'con·text',
      'creative': 'cre·a·tive',
      'culture': 'cul·ture',
      'define': 'de·fine',
      'device': 'de·vice',
      'distance': 'dis·tance',
      'impression': 'im·pres·sion',
      'cooperation': 'co·op·er·a·tion',
      'guarantee': 'guar·an·tee',
      'concerned': 'con·cerned',
      'engage': 'en·gage',
      'perceive': 'per·ceive',
    };
    return mapped[lower] ?? word;
  }

  void _handleKnownPressed() {
    _cancelAutoAdvance();
    if (_confirmingUnknown || _confirmingKnown) {
      widget.onKnown();
      return;
    }
    setState(() {
      _showAnswer = true;
      _confirmingKnown = true;
      _confirmingUnknown = false;
    });
  }

  void _handleUnknownPressed() {
    if (_confirmingKnown) {
      widget.onUnknown();
      return;
    }
    _cancelAutoAdvance();
    setState(() {
      _showAnswer = true;
      _confirmingKnown = false;
      _confirmingUnknown = true;
    });
    _autoAdvanceTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      widget.onUnknown();
    });
  }

  void _cancelAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final hasWords = widget.words.isNotEmpty && widget.currentIndex < widget.words.length;
    final word = hasWords ? widget.words[widget.currentIndex] : null;
    final progress = widget.words.isEmpty ? 0.0 : ((widget.currentIndex + 1) / widget.words.length).clamp(0.0, 1.0);
    final displayWord = word == null ? '本轮已完成' : (_showAnswer ? _syllableHint(word.word) : word.word);
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 700;
    final wordSize = isCompact ? 44.0 : 60.0;

    return ListView(
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mode == ReviewMode.wrongWords ? '错词回刷' : '整本快刷',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(widget.book.title, style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            OutlinedButton.icon(
              onPressed: widget.onRestart,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('重新开始'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 18 : 28),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFE7F3F1),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4CB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    !_confirmingKnown && !_confirmingUnknown
                        ? (hasWords ? '先看英文，自己在脑中想答案' : '这一轮刷完了')
                        : (_confirmingUnknown ? '已显示中文，2 秒后自动切到下一词' : '答案已经显示，确认一下你刚才记对没'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7A5B00),
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayWord,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: wordSize,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF11353A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  word?.phonetic ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF5E8782),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: !_showAnswer
                      ? const SizedBox.shrink(key: ValueKey('hidden'))
                      : !hasWords
                          ? Text(
                              '当前没有待刷单词，可以回词书页补充单词，或者重新开始一轮。',
                              key: const ValueKey('empty'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            )
                          : Container(
                              key: const ValueKey('meaning'),
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FBFF),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                word!.meaning,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                ),
                const SizedBox(height: 24),
                if (isCompact)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: hasWords ? _handleKnownPressed : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          child: Text((_confirmingKnown || _confirmingUnknown) ? '答对了' : '认识'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: hasWords ? _handleUnknownPressed : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD15F),
                            foregroundColor: const Color(0xFF11353A),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          child: Text((_confirmingKnown || _confirmingUnknown) ? '答错了' : '不认识'),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: hasWords ? _handleKnownPressed : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          child: Text((_confirmingKnown || _confirmingUnknown) ? '答对了' : '认识'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: hasWords ? _handleUnknownPressed : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD15F),
                            foregroundColor: const Color(0xFF11353A),
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                          ),
                          child: Text((_confirmingKnown || _confirmingUnknown) ? '答错了' : '不认识'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 20,
              runSpacing: 16,
              children: [
                _MiniStat(label: '本轮已刷', value: '${widget.knownCount + widget.unknownCount}'),
                _MiniStat(label: '认识', value: '${widget.knownCount}'),
                _MiniStat(label: '不认识', value: '${widget.unknownCount}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
