from pathlib import Path

path = Path('apps/dashboard/lib/src/features/exercises/views/dashboard_guidance_editor_view.dart')
text = path.read_text()
old = """  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StoneSetStatusIndicator(kind: kind, label: label),
        const SizedBox(width: StoneSetSpacing.sm),
        Expanded(child: Text(message)),
      ],
    ),
  );
}"""
new = """  @override
  Widget build(BuildContext context) => StoneSetCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StoneSetStatusIndicator(kind: kind, label: label),
        const SizedBox(height: StoneSetSpacing.xs),
        Text(message),
      ],
    ),
  );
}"""
if old not in text:
    raise RuntimeError('publication status card anchor not found')
path.write_text(text.replace(old, new, 1))
