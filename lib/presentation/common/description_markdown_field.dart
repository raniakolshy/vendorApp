import 'package:flutter/cupertino.dart' as md;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as mk;

class DescriptionMarkdownField extends StatefulWidget {
  const DescriptionMarkdownField({
    super.key,
    required this.label,
    required this.controller,
    this.help,
    this.minLines = 10,
    this.showPreview = true,
  });

  final String label;
  final String? help;
  final TextEditingController controller;
  final int minLines;
  final bool showPreview;

  @override
  State<DescriptionMarkdownField> createState() => _DescriptionMarkdownFieldState();
}

class _DescriptionMarkdownFieldState extends State<DescriptionMarkdownField> {
  final _focus = FocusNode();

  TextSelection get _sel => widget.controller.selection;
  String get _text => widget.controller.text;

  void _setText(String newText, int newStart, int newEnd) {
    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection(baseOffset: newStart, extentOffset: newEnd),
      composing: TextRange.empty,
    );
    setState(() {});
  }

  /// Wrap current selection with [left] and [right] tokens.
  void _wrap(String left, String right) {
    final s = _sel;
    final t = _text;
    final start = s.start.clamp(0, t.length);
    final end = s.end.clamp(0, t.length);
    final selected = (start < end) ? t.substring(start, end) : '';

    // If nothing selected: insert tokens and put caret in the middle.
    if (selected.isEmpty) {
      final inserted = t.replaceRange(start, end, '$left$right');
      final caret = start + left.length;
      _setText(inserted, caret, caret);
    } else {
      // If already wrapped, unwrap (toggle)
      final already =
          t.substring((start - left.length).clamp(0, t.length), start) == left &&
              t.substring(end, (end + right.length).clamp(0, t.length)) == right;

      if (already) {
        final before = t.substring(0, start - left.length);
        final after = t.substring(end + right.length);
        final middle = selected;
        final newText = '$before$middle$after';
        final newStart = start - left.length;
        final newEnd = newStart + middle.length;
        _setText(newText, newStart, newEnd);
      } else {
        final newText = t.replaceRange(start, end, '$left$selected$right');
        final newStart = start + left.length;
        final newEnd = newStart + selected.length;
        _setText(newText, newStart, newEnd);
      }
    }
    _focus.requestFocus();
  }

  /// Add a list prefix ('- ' or '1. ') at the start of the current line(s).
  void _toggleListPrefix(String prefix, {bool numbered = false}) {
    final s = _sel;
    final t = _text;

    // determine lines range covering selection
    int lineStart = t.lastIndexOf('\n', s.start - 1) + 1; // -1 -> -1 + 1 = 0
    int lineEnd = t.indexOf('\n', s.end);
    if (lineEnd == -1) lineEnd = t.length;

    final block = t.substring(lineStart, lineEnd);
    final lines = block.split('\n');

    bool allPrefixed = true;
    for (final l in lines) {
      final trimmed = l.trimLeft();
      if (numbered) {
        if (!RegExp(r'^\d+\. ').hasMatch(trimmed)) { allPrefixed = false; break; }
      } else {
        if (!trimmed.startsWith('- ')) { allPrefixed = false; break; }
      }
    }

    final newLines = <String>[];
    for (int i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (allPrefixed) {
        // remove prefix
        if (numbered) {
          newLines.add(l.replaceFirst(RegExp(r'^\s*\d+\. '), ''));
        } else {
          newLines.add(l.replaceFirst(RegExp(r'^\s*-\s'), ''));
        }
      } else {
        final currentPrefix = numbered ? '${i + 1}. ' : prefix;
        newLines.add('$currentPrefix$l');
      }
    }

    final replaced = newLines.join('\n');
    final newText = t.replaceRange(lineStart, lineEnd, replaced);
    final delta = replaced.length - block.length;

    _setText(newText, s.start + delta, s.end + delta);
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        if ((widget.help ?? '').isNotEmpty)
          Tooltip(
            message: widget.help!,
            waitDuration: const Duration(milliseconds: 250),
            child: const Icon(Icons.info_outline, size: 16, color: Colors.black87),
          ),
      ],
    );

    final toolbar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _btn(Icons.format_bold, () => _wrap('**', '**')),
          _gap(),
          _btn(Icons.format_italic, () => _wrap('_', '_')),
          _gap(),
          _btn(Icons.format_underline, () => _wrap('<u>', '</u>')), // HTML underline
          _gapWide(),
          _btn(Icons.format_list_bulleted, () => _toggleListPrefix('- ')),
          _gap(),
          _btn(Icons.format_list_numbered, () => _toggleListPrefix('1. ', numbered: true)),
        ]),
      ),
    );

    final editor = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          toolbar,
          Container(height: 1, color: const Color(0xFFEDEDED)),
          TextField(
            controller: widget.controller,
            focusNode: _focus,
            minLines: widget.minLines,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Input your text',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );

    final preview = widget.showPreview
        ? Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: MarkdownBody(
        data: widget.controller.text,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: const TextStyle(fontSize: 14, height: 1.35),
        ),
        inlineSyntaxes: [
          UnderlineSyntax(), // <-- our custom syntax
        ],
        builders: {
          'u': UnderlineBuilder(),
        },
      )

        ): const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelRow,
        const SizedBox(height: 8),
        editor,
        preview,
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onPressed) => IconButton(
    icon: Icon(icon, color: Colors.black87, size: 20),
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    splashRadius: 20,
    onPressed: onPressed,
    tooltip: '',
  );

  Widget _gap() => const SizedBox(width: 12);
  Widget _gapWide() => const SizedBox(width: 22);
}
class UnderlineSyntax extends mk.InlineSyntax {
  UnderlineSyntax() : super(r'<u>(.+?)<\/u>');

  @override
  bool onMatch(mk.InlineParser parser, Match match) {
    final inner = match.group(1) ?? '';
    parser.addNode(mk.Element.text('u', inner));
    return true;
  }
}
/// Markdown renderer for <u>…</u> tags
class UnderlineBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(mk.Element element, TextStyle? preferredStyle) {
    // Rebuild plain text from element children
    final buffer = StringBuffer();

    void walk(mk.Node node) {
      if (node is mk.Text) {
        buffer.write(node.text);
      } else if (node is mk.Element) {
        for (final child in node.children ?? const <mk.Node>[]) {
          walk(child);
        }
      }
    }

    for (final child in element.children ?? const <mk.Node>[]) {
      walk(child);
    }

    return Text(
      buffer.toString(),
      style: (preferredStyle ?? const TextStyle())
          .merge(const TextStyle(decoration: TextDecoration.underline)),
    );
  }
}

