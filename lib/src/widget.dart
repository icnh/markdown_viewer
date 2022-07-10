import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import 'renderer.dart';
import 'definition.dart';
import 'extensions.dart';
import 'style.dart';

class MarkdownViewer extends StatefulWidget {
  const MarkdownViewer(
    this.data, {
    this.styleSheet,
    this.onTapLink,
    this.listItemMarkerBuilder,
    this.highlightBuilder,
    this.checkboxBuilder,
    this.enableTaskList = false,
    Key? key,
  }) : super(key: key);

  final String data;
  final bool enableTaskList;
  final MarkdownStyle? styleSheet;
  final MarkdownTapLinkCallback? onTapLink;
  final MarkdownListItemMarkerBuilder? listItemMarkerBuilder;
  final MarkdownCheckboxBuilder? checkboxBuilder;
  final MarkdownHighlightBuilder? highlightBuilder;

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  List<Widget> _children = [];

  @override
  Widget build(BuildContext context) {
    _parseMarkdown();

    Widget widget;
    if (_children.length > 1) {
      widget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      );
    } else if (_children.length == 1) {
      widget = _children.single;
    } else {
      widget = const SizedBox.shrink();
    }

    return widget;
  }

  void _parseMarkdown() {
    final md.Document document = md.Document(
      enableHtmlBlock: false,
      enableRawHtml: false,
      enableHighlight: true,
      enableStrikethrough: true,
      enableTaskList: widget.enableTaskList,
    );
    final theme = Theme.of(context);
    final astNodes = document.parseLines(widget.data);

    // TODO(Zhiguang): merge custom stylesheet with the default.
    final styleSheet = widget.styleSheet ?? MarkdownStyle.fromTheme(theme);

    final renderer = MarkdownRenderer(
      styleSheet: styleSheet,
      onTapLink: widget.onTapLink,
      listItemMarkerBuilder: widget.listItemMarkerBuilder,
      checkboxBuilder: widget.checkboxBuilder,
      highlightBuilder: widget.highlightBuilder,
    );

    _children = renderer.render(astNodes);
  }
}
