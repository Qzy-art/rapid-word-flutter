import 'package:flutter/material.dart';

import '../../../models/word_book.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.book,
    required this.wrongCount,
    required this.todayCount,
    required this.totalSessions,
    required this.knownRate,
    required this.wrongReviewCount,
    required this.supabaseEnabled,
    this.cloudMessage,
    required this.onContinuePressed,
    required this.onReviewWrongPressed,
    required this.onManageBooksPressed,
  });

  final WordBook book;
  final int wrongCount;
  final int todayCount;
  final int totalSessions;
  final double knownRate;
  final int wrongReviewCount;
  final bool supabaseEnabled;
  final String? cloudMessage;
  final VoidCallback onContinuePressed;
  final VoidCallback onReviewWrongPressed;
  final VoidCallback onManageBooksPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCompact = MediaQuery.of(context).size.width < 900;

    return ListView(
      children: [
        Text('把不会的词，越刷越少', style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          '用最快的方式筛出生词、难词和错词，再通过多轮回刷逐步清空。',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        if (isCompact)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(title: '今日已刷', value: '$todayCount', icon: Icons.trending_up_rounded),
              _MetricCard(title: '错词数量', value: '$wrongCount', icon: Icons.priority_high_rounded, warm: true),
              _MetricCard(title: '总学习轮次', value: '$totalSessions', icon: Icons.layers_rounded),
              _MetricCard(
                title: '识别率',
                value: '${(knownRate * 100).toStringAsFixed(0)}%',
                icon: Icons.insights_rounded,
              ),
              _MetricCard(title: '错词回刷轮次', value: '$wrongReviewCount', icon: Icons.refresh_rounded),
            ],
          )
        else ...[
          Row(
            children: [
              Expanded(child: _MetricCard(title: '今日已刷', value: '$todayCount', icon: Icons.trending_up_rounded)),
              const SizedBox(width: 16),
              Expanded(child: _MetricCard(title: '错词数量', value: '$wrongCount', icon: Icons.priority_high_rounded, warm: true)),
              const SizedBox(width: 16),
              Expanded(child: _MetricCard(title: '总学习轮次', value: '$totalSessions', icon: Icons.layers_rounded)),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  title: '识别率',
                  value: '${(knownRate * 100).toStringAsFixed(0)}%',
                  icon: Icons.insights_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MetricCard(title: '错词回刷轮次', value: '$wrongReviewCount', icon: Icons.refresh_rounded),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(
                  supabaseEnabled ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  color: const Color(0xFF11353A),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cloudMessage ??
                        (supabaseEnabled ? 'Supabase 已配置，首页统计优先显示云端学习数据。' : 'Supabase 尚未配置，当前仍使用本地 mock 数据运行。'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (isCompact) ...[
          _InfoCard(
            title: '继续本轮刷词',
            body: '当前词书：${book.title}\n建议先整本快刷，再继续回刷错词。',
            actionLabel: '继续刷词',
            onPressed: onContinuePressed,
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: '闭环回刷',
            body: '第一轮刷整本，点“不认识”的词会自动进入错词本，下一轮继续缩小范围。',
            actionLabel: wrongCount > 0 ? '继续刷错词' : '管理词书',
            onPressed: wrongCount > 0 ? onReviewWrongPressed : onManageBooksPressed,
          ),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoCard(
                  title: '继续本轮刷词',
                  body: '当前词书：${book.title}\n建议先整本快刷，再继续回刷错词。',
                  actionLabel: '继续刷词',
                  onPressed: onContinuePressed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoCard(
                  title: '闭环回刷',
                  body: '第一轮刷整本，点“不认识”的词会自动进入错词本，下一轮继续缩小范围。',
                  actionLabel: wrongCount > 0 ? '继续刷错词' : '管理词书',
                  onPressed: wrongCount > 0 ? onReviewWrongPressed : onManageBooksPressed,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.warm = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 900;
    return SizedBox(
      width: compact ? (MediaQuery.of(context).size.width - 40) / 2 : null,
      child: Card(
        color: warm ? const Color(0xFFFFF0C9) : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF11353A)),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
