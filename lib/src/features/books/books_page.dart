import 'package:flutter/material.dart';

import '../../models/word_book.dart';

class BooksPage extends StatelessWidget {
  const BooksPage({
    super.key,
    required this.books,
    required this.selectedBook,
    required this.onSelectBook,
    required this.onStartReview,
    required this.onCreateBook,
    required this.onAddWord,
    required this.onImportWords,
    required this.onEditBook,
    required this.onEditWord,
    required this.onDeleteWord,
  });

  final List<WordBook> books;
  final WordBook selectedBook;
  final ValueChanged<String> onSelectBook;
  final ValueChanged<String> onStartReview;
  final void Function({
    required String title,
    required String level,
    required String description,
  }) onCreateBook;
  final void Function({
    required String word,
    required String phonetic,
    required String partOfSpeech,
    required String meaning,
  }) onAddWord;
  final ValueChanged<String> onImportWords;
  final void Function({
    required String title,
    required String level,
    required String description,
  }) onEditBook;
  final void Function({
    required String wordId,
    required String word,
    required String phonetic,
    required String partOfSpeech,
    required String meaning,
  }) onEditWord;
  final ValueChanged<String> onDeleteWord;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('词书管理', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          '手机端先走单栏模式，避免词书卡片和词条预览互相挤压。',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: () => _showCreateBookDialog(context),
              icon: const Icon(Icons.library_add_rounded),
              label: const Text('新建词书'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showImportDialog(context),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('导入单词'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showAddWordDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增单词'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SelectedBookPanel(
          selectedBook: selectedBook,
          onAddWordPressed: () => _showAddWordDialog(context),
          onImportPressed: () => _showImportDialog(context),
          onEditBookPressed: () => _showEditBookDialog(context),
        ),
        const SizedBox(height: 16),
        ...books.map(
          (book) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _BookCard(
              book: book,
              isCurrent: book.id == selectedBook.id,
              onSelect: () => onSelectBook(book.id),
              onStartReview: () => onStartReview(book.id),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _WordPreviewList(
          selectedBook: selectedBook,
          onEditWord: (word) => _showEditWordDialog(context, word),
          onDeleteWord: onDeleteWord,
        ),
      ],
    );
  }

  Future<void> _showCreateBookDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final levelController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建词书'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: '词书名称')),
              const SizedBox(height: 12),
              TextField(controller: levelController, decoration: const InputDecoration(labelText: '分类标签')),
              const SizedBox(height: 12),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: '简介')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                return;
              }
              onCreateBook(
                title: titleController.text.trim(),
                level: levelController.text.trim(),
                description: descriptionController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddWordDialog(BuildContext context) async {
    final wordController = TextEditingController();
    final phoneticController = TextEditingController();
    final partOfSpeechController = TextEditingController();
    final meaningController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动添加单词'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: wordController, decoration: const InputDecoration(labelText: '单词')),
              const SizedBox(height: 12),
              TextField(controller: phoneticController, decoration: const InputDecoration(labelText: '音标')),
              const SizedBox(height: 12),
              TextField(controller: partOfSpeechController, decoration: const InputDecoration(labelText: '词性')),
              const SizedBox(height: 12),
              TextField(controller: meaningController, decoration: const InputDecoration(labelText: '释义')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (wordController.text.trim().isEmpty || meaningController.text.trim().isEmpty) {
                return;
              }
              onAddWord(
                word: wordController.text.trim(),
                phonetic: phoneticController.text.trim(),
                partOfSpeech: partOfSpeechController.text.trim(),
                meaning: meaningController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量导入单词'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('格式：word | /音标/ | 词性 | 中文释义', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 6,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'improve | /imˈpruːv/ | v. | 改进\nissue | /ˈɪʃuː/ | n. | 问题；议题',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              onImportWords(controller.text);
              Navigator.pop(context);
            },
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditBookDialog(BuildContext context) async {
    final titleController = TextEditingController(text: selectedBook.title);
    final levelController = TextEditingController(text: selectedBook.level);
    final descriptionController = TextEditingController(text: selectedBook.description);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑词书'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: '词书名称')),
              const SizedBox(height: 12),
              TextField(controller: levelController, decoration: const InputDecoration(labelText: '分类标签')),
              const SizedBox(height: 12),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: '简介')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                return;
              }
              onEditBook(
                title: titleController.text.trim(),
                level: levelController.text.trim(),
                description: descriptionController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditWordDialog(BuildContext context, WordItem item) async {
    final wordController = TextEditingController(text: item.word);
    final phoneticController = TextEditingController(text: item.phonetic);
    final partOfSpeechController = TextEditingController(text: item.partOfSpeech);
    final meaningController = TextEditingController(text: item.meaning);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑单词'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: wordController, decoration: const InputDecoration(labelText: '单词')),
              const SizedBox(height: 12),
              TextField(controller: phoneticController, decoration: const InputDecoration(labelText: '音标')),
              const SizedBox(height: 12),
              TextField(controller: partOfSpeechController, decoration: const InputDecoration(labelText: '词性')),
              const SizedBox(height: 12),
              TextField(controller: meaningController, decoration: const InputDecoration(labelText: '释义')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (wordController.text.trim().isEmpty || meaningController.text.trim().isEmpty) {
                return;
              }
              onEditWord(
                wordId: item.id,
                word: wordController.text.trim(),
                phonetic: phoneticController.text.trim(),
                partOfSpeech: partOfSpeechController.text.trim(),
                meaning: meaningController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.isCurrent,
    required this.onSelect,
    required this.onStartReview,
  });

  final WordBook book;
  final bool isCurrent;
  final VoidCallback onSelect;
  final VoidCallback onStartReview;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookCover(book: book),
            const SizedBox(height: 14),
            Text(book.level, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(book.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(book.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton(
                  onPressed: onSelect,
                  child: Text(isCurrent ? '当前词书' : '设为当前'),
                ),
                FilledButton(
                  onPressed: onStartReview,
                  child: const Text('开始刷词'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedBookPanel extends StatelessWidget {
  const _SelectedBookPanel({
    required this.selectedBook,
    required this.onAddWordPressed,
    required this.onImportPressed,
    required this.onEditBookPressed,
  });

  final WordBook selectedBook;
  final VoidCallback onAddWordPressed;
  final VoidCallback onImportPressed;
  final VoidCallback onEditBookPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前词书', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(selectedBook.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(selectedBook.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(selectedBook.level)),
                Chip(label: Text('${selectedBook.words.length} 个词条')),
                Chip(label: Text('${selectedBook.words.where((word) => word.isWrong).length} 个错词')),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(onPressed: onAddWordPressed, child: const Text('新增单词')),
                OutlinedButton(onPressed: onImportPressed, child: const Text('批量导入')),
                OutlinedButton(onPressed: onEditBookPressed, child: const Text('编辑词书')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WordPreviewList extends StatelessWidget {
  const _WordPreviewList({
    required this.selectedBook,
    required this.onEditWord,
    required this.onDeleteWord,
  });

  final WordBook selectedBook;
  final ValueChanged<WordItem> onEditWord;
  final ValueChanged<String> onDeleteWord;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('词条预览', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (selectedBook.words.isEmpty)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('这个词书还没有单词'),
                subtitle: Text('可以先手动添加，也可以批量导入。'),
              )
            else
              ...selectedBook.words.map(
                (word) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(word.word),
                  subtitle: Text(
                    [
                      if (word.phonetic.isNotEmpty) word.phonetic,
                      if (word.partOfSpeech.isNotEmpty) word.partOfSpeech,
                      word.meaning,
                    ].join('  '),
                  ),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      Icon(
                        word.isWrong ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                      ),
                      IconButton(
                        tooltip: '编辑',
                        onPressed: () => onEditWord(word),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      IconButton(
                        tooltip: '删除',
                        onPressed: () => onDeleteWord(word.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.book});

  final WordBook book;

  @override
  Widget build(BuildContext context) {
    final colors = switch (book.coverStyle) {
      'sun' => [const Color(0xFFFFE089), const Color(0xFFFFF2CA)],
      'sky' => [const Color(0xFF8FDFF7), const Color(0xFFD7F6FF)],
      _ => [const Color(0xFF83EAD1), const Color(0xFFCFFAF3)],
    };

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.level, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
