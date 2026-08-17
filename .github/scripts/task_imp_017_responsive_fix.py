from pathlib import Path

path = Path('apps/dashboard/lib/src/features/exercises/views/dashboard_guidance_editor_view.dart')
text = path.read_text()

old = """              const SizedBox(height: StoneSetSpacing.xs),
              _GuidancePublicationBanner(media: media, readOnly: readOnly),
              const SizedBox(height: StoneSetSpacing.md),
              Expanded(
"""
new = """              const SizedBox(height: StoneSetSpacing.md),
              Expanded(
"""
if old not in text:
    raise RuntimeError('fixed publication banner anchor not found')
text = text.replace(old, new, 1)

old = """                    final editor = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _GuidanceForm(
"""
new = """                    final editor = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _GuidancePublicationBanner(media: media, readOnly: readOnly),
                        const SizedBox(height: StoneSetSpacing.md),
                        _GuidanceForm(
"""
if old not in text:
    raise RuntimeError('scrollable editor anchor not found')
text = text.replace(old, new, 1)

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
text = text.replace(old, new, 1)

path.write_text(text)
