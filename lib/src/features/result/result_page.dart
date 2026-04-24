import 'package:flutter/material.dart';

import '../home/state/home_state.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.wrongCount,
    required this.session,
    required this.onPrimaryPressed,
    required this.onHomePressed,
  });

  final int wrongCount;
  final SessionSummary session;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onHomePressed;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 900;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.mode == ReviewMode.wrongWords ? '错词回刷完成' : '整本快刷完成',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '这一轮已经结束，下面是本轮结果和下一步建议。',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isCompact)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ResultStat(title: '本轮已刷', value: '${session.done}'),
              _ResultStat(title: '认识', value: '${session.known}'),
              _ResultStat(title: '不认识', value: '${session.unknown}'),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: _ResultStat(title: '本轮已刷', value: '${session.done}')),
              const SizedBox(width: 16),
              Expanded(child: _ResultStat(title: '认识', value: '${session.known}')),
              const SizedBox(width: 16),
              Expanded(child: _ResultStat(title: '不认识', value: '${session.unknown}')),
            ],
          ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wrongCount > 0 ? '继续回刷更有效' : '这一轮已经清空错词',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  wrongCount > 0
                      ? '建议立刻继续刷错词，把刚才不熟的词再筛一轮。'
                      : '当前没有残留错词，可以回首页，或者重新开始一轮整本快刷。',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                if (isCompact)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onPrimaryPressed,
                          child: Text(wrongCount > 0 ? '继续刷错词' : '重新刷整本'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onHomePressed,
                          child: const Text('回到首页'),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      FilledButton(
                        onPressed: onPrimaryPressed,
                        child: Text(wrongCount > 0 ? '继续刷错词' : '重新刷整本'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: onHomePressed,
                        child: const Text('回到首页'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 900;
    return SizedBox(
      width: compact ? (MediaQuery.of(context).size.width - 40) / 2 : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
