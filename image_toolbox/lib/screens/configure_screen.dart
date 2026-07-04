import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/edit_op.dart';
import '../models/encode_settings.dart';
import '../models/enums.dart';
import '../models/tool.dart';
import '../pipeline/pipeline_runner.dart';
import '../providers/jobs_provider.dart';
import '../providers/recipes_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/live_preview.dart';
import 'processing_screen.dart';

class ConfigureScreen extends StatefulWidget {
  final Tool tool;
  const ConfigureScreen({super.key, required this.tool});

  @override
  State<ConfigureScreen> createState() => _ConfigureScreenState();
}

class _ConfigureScreenState extends State<ConfigureScreen> {
  late OutputFormat _format;
  late int _quality;
  bool _useTarget = false;
  int _targetKb = 300;

  ResizeMode _resizeMode = ResizeMode.maxDimension;
  double _percent = 75;
  int _exactW = 1080;
  int _exactH = 1080;
  int _maxDim = 1920;
  bool _resizeInCompress = false;

  FilterPreset _filter = FilterPreset.none;
  double _brightness = 1.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  double _sharpen = 0.0;

  final TextEditingController _wmText = TextEditingController(text: '© Me');
  WatermarkPosition _wmPos = WatermarkPosition.bottomRight;
  double _wmOpacity = 0.6;

  Uint8List? _proxy;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _format = s.defaultFormat;
    _quality = s.defaultQuality;
    _buildProxy();
  }

  Future<void> _buildProxy() async {
    final jobs = context.read<JobsProvider>().jobs;
    if (jobs.isEmpty) return;
    final proxy = await compute(makeProxy, jobs.first.sourceBytes);
    if (mounted) setState(() => _proxy = proxy);
  }

  @override
  void dispose() {
    _wmText.dispose();
    super.dispose();
  }

  ToolId get id => widget.tool.id;

  List<EditOp> _buildOps() {
    final ops = <EditOp>[];
    if (id == ToolId.resize) {
      ops.add(_resizeOp());
    }
    if (id == ToolId.compress && _resizeInCompress) {
      ops.add(ResizeOp(mode: ResizeMode.maxDimension, maxDim: _maxDim));
    }
    if (id == ToolId.filters) {
      if (_filter != FilterPreset.none) ops.add(FilterOp(_filter));
      final adjust = AdjustOp(
        brightness: _brightness,
        contrast: _contrast,
        saturation: _saturation,
        sharpen: _sharpen,
      );
      if (!adjust.isNeutral) ops.add(adjust);
    }
    if (id == ToolId.watermark) {
      ops.add(WatermarkOp(
        text: _wmText.text,
        position: _wmPos,
        opacity: _wmOpacity,
      ));
    }
    return ops;
  }

  ResizeOp _resizeOp() {
    switch (_resizeMode) {
      case ResizeMode.percentage:
        return ResizeOp(mode: ResizeMode.percentage, percent: _percent);
      case ResizeMode.exact:
        return ResizeOp(mode: ResizeMode.exact, width: _exactW, height: _exactH);
      case ResizeMode.maxDimension:
      case ResizeMode.none:
        return ResizeOp(mode: ResizeMode.maxDimension, maxDim: _maxDim);
    }
  }

  EncodeSettings _buildEncode() {
    final s = context.read<SettingsProvider>();
    return EncodeSettings(
      format: _format,
      quality: _quality,
      targetSizeKb: _useTarget && _format.isLossy ? _targetKb : null,
      keepExif: s.keepExif,
    );
  }

  Future<void> _saveAsRecipe() async {
    final nameController = TextEditingController(text: widget.tool.name);
    const emojis = ['⚙️', '🗜️', '📐', '🔄', '🎨', '💧', '🌐', '📸', '✉️', '🔻'];
    String emoji = widget.tool.emoji;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Save as recipe', style: AppTheme.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: AppTheme.subtitle.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Recipe name',
                  hintStyle: AppTheme.body,
                  filled: true,
                  fillColor: AppColors.surfaceAlt,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: emojis
                    .map((e) => GestureDetector(
                          onTap: () => setModal(() => emoji = e),
                          child: CircleAvatar(
                            backgroundColor: emoji == e
                                ? AppColors.primary
                                : AppColors.surfaceAlt,
                            child: Text(e,
                                style: const TextStyle(fontSize: 18)),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved != true || !mounted) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    await context.read<RecipesProvider>().add(
          name: name,
          emoji: emoji,
          ops: _buildOps(),
          encode: _buildEncode(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved recipe "$name"')));
    }
  }

  void _apply() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(
          ops: _buildOps(),
          encode: _buildEncode(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<JobsProvider>().total;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tool.name),
        actions: [
          IconButton(
            tooltip: 'Save as recipe',
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: _saveAsRecipe,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                LivePreview(
                  proxyBytes: _proxy,
                  ops: _buildOps(),
                  encode: _buildEncode(),
                ),
                const SizedBox(height: 12),
                Text('$count image${count == 1 ? '' : 's'} selected',
                    style: AppTheme.body),
                const SizedBox(height: 16),
                if (id == ToolId.resize) _resizeSection(),
                if (id == ToolId.compress) _compressSection(),
                if (id == ToolId.filters) _filtersSection(),
                if (id == ToolId.watermark) _watermarkSection(),
                if (id != ToolId.filters) _outputSection(),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.bolt),
                  label: Text('APPLY TO $count',
                      style: AppTheme.subtitle.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: AppTheme.label),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );

  Widget _resizeSection() {
    return _section('Resize', [
      Wrap(
        spacing: 8,
        children: [
          _chip('Max side', _resizeMode == ResizeMode.maxDimension,
              () => setState(() => _resizeMode = ResizeMode.maxDimension)),
          _chip('Percent', _resizeMode == ResizeMode.percentage,
              () => setState(() => _resizeMode = ResizeMode.percentage)),
          _chip('Exact', _resizeMode == ResizeMode.exact,
              () => setState(() => _resizeMode = ResizeMode.exact)),
        ],
      ),
      const SizedBox(height: 12),
      if (_resizeMode == ResizeMode.maxDimension) ...[
        _sliderRow('Max dimension', '$_maxDim px', _maxDim.toDouble(), 240, 4096,
            (v) => setState(() => _maxDim = v.round())),
        Wrap(
          spacing: 8,
          children: [512, 1080, 1920, 2560, 3840]
              .map((v) => _chip('$v', _maxDim == v,
                  () => setState(() => _maxDim = v)))
              .toList(),
        ),
      ],
      if (_resizeMode == ResizeMode.percentage)
        _sliderRow('Scale', '${_percent.round()}%', _percent, 10, 200,
            (v) => setState(() => _percent = v)),
      if (_resizeMode == ResizeMode.exact) ...[
        _numberField('Width', _exactW, (v) => setState(() => _exactW = v)),
        const SizedBox(height: 8),
        _numberField('Height', _exactH, (v) => setState(() => _exactH = v)),
      ],
    ]);
  }

  Widget _compressSection() {
    return _section('Compression', [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeThumbColor: AppColors.primary,
        title: Text('Target file size', style: AppTheme.subtitle),
        subtitle: Text('Auto-tune quality to hit a size', style: AppTheme.body),
        value: _useTarget,
        onChanged: (v) => setState(() => _useTarget = v),
      ),
      if (_useTarget)
        _sliderRow('Target', '$_targetKb KB', _targetKb.toDouble(), 20, 2000,
            (v) => setState(() => _targetKb = v.round()))
      else
        _sliderRow('Quality', '$_quality', _quality.toDouble(), 10, 100,
            (v) => setState(() => _quality = v.round())),
      const Divider(color: AppColors.border, height: 24),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        activeThumbColor: AppColors.primary,
        title: Text('Also limit dimensions', style: AppTheme.subtitle),
        value: _resizeInCompress,
        onChanged: (v) => setState(() => _resizeInCompress = v),
      ),
      if (_resizeInCompress)
        _sliderRow('Max dimension', '$_maxDim px', _maxDim.toDouble(), 240, 4096,
            (v) => setState(() => _maxDim = v.round())),
    ]);
  }

  Widget _filtersSection() {
    return _section('Filters & Adjust', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: FilterPreset.values
            .map((f) => _chip(f.label, _filter == f,
                () => setState(() => _filter = f)))
            .toList(),
      ),
      const SizedBox(height: 12),
      _sliderRow('Brightness', _brightness.toStringAsFixed(2), _brightness,
          0.5, 1.5, (v) => setState(() => _brightness = v)),
      _sliderRow('Contrast', _contrast.toStringAsFixed(2), _contrast, 0.5, 1.5,
          (v) => setState(() => _contrast = v)),
      _sliderRow('Saturation', _saturation.toStringAsFixed(2), _saturation, 0.0,
          2.0, (v) => setState(() => _saturation = v)),
      _sliderRow('Sharpen', _sharpen.toStringAsFixed(2), _sharpen, 0.0, 1.0,
          (v) => setState(() => _sharpen = v)),
    ]);
  }

  Widget _watermarkSection() {
    return _section('Watermark', [
      TextField(
        controller: _wmText,
        style: AppTheme.subtitle.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Watermark text',
          hintStyle: AppTheme.body,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: WatermarkPosition.values
            .map((p) => _chip(p.label, _wmPos == p,
                () => setState(() => _wmPos = p)))
            .toList(),
      ),
      const SizedBox(height: 8),
      _sliderRow('Opacity', '${(_wmOpacity * 100).round()}%', _wmOpacity, 0.1,
          1.0, (v) => setState(() => _wmOpacity = v)),
    ]);
  }

  Widget _outputSection() {
    return _section('Output', [
      Wrap(
        spacing: 8,
        children: OutputFormat.values
            .map((f) => _chip(f.label, _format == f,
                () => setState(() => _format = f)))
            .toList(),
      ),
      if (_format.isLossy && !(id == ToolId.compress && _useTarget)) ...[
        const SizedBox(height: 12),
        _sliderRow('Quality', '$_quality', _quality.toDouble(), 10, 100,
            (v) => setState(() => _quality = v.round())),
      ],
      if (_format == OutputFormat.jpeg)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('Transparency is flattened onto white for JPEG.',
              style: AppTheme.body.copyWith(fontSize: 12)),
        ),
    ]);
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: AppColors.surfaceAlt,
      selectedColor: AppColors.primary,
      labelStyle: AppTheme.body.copyWith(
        color: selected ? Colors.black : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border),
    );
  }

  Widget _sliderRow(String label, String value, double current, double min,
      double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.body),
            Text(value,
                style: AppTheme.body.copyWith(color: AppColors.textPrimary)),
          ],
        ),
        Slider(
          value: current.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _numberField(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: AppTheme.body)),
        Expanded(
          child: TextFormField(
            initialValue: '$value',
            keyboardType: TextInputType.number,
            style: AppTheme.subtitle.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (t) {
              final v = int.tryParse(t);
              if (v != null && v > 0) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
