import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../mock/mock_data.dart';
import '../../models/cafe_style.dart';
import 'generating_screen.dart';
import '../../src/constant.dart';

class CustomStudioScreen extends StatefulWidget {
  final String imagePath;
  final CafeStyle selectedStyle;

  const CustomStudioScreen({
    super.key,
    required this.imagePath,
    required this.selectedStyle,
  });

  @override
  State<CustomStudioScreen> createState() => _CustomStudioScreenState();
}

class _CustomStudioScreenState extends State<CustomStudioScreen>
    with TickerProviderStateMixin {
  // Core Settings
  double _density = 0.5;
  double _tableSize = 0.3;
  double _decorScale = 0.0;
  double _sunlight = 0.7;
  double _barScale = 0.5;
  double _colorVibrancy = 0.6;

  // Selection States
  String _season = 'Spring';
  String _timeOfDay = 'Golden Hour';
  int _selectedFlooring = 0;
  int _selectedLighting = 0;
  int _selectedDecorFeature = -1;

  // Prompt Controller
  final TextEditingController _promptController = TextEditingController();
  bool _isPromptExpanded = false;

  late TabController _tabController;

  final List<Map<String, dynamic>> _seasonData = [
    {'name': 'Spring', 'icon': '🌸', 'color': Color(0xFFE91E63)},
    {'name': 'Summer', 'icon': '☀️', 'color': Color(0xFFFF9800)},
    {'name': 'Autumn', 'icon': '🍂', 'color': Color(0xFFFF5722)},
    {'name': 'Winter', 'icon': '❄️', 'color': Color(0xFF2196F3)},
  ];

  final List<Map<String, dynamic>> _timeData = [
    {'name': 'Dawn', 'icon': '🌅'},
    {'name': 'Morning', 'icon': '🌤️'},
    {'name': 'Golden Hour', 'icon': '🌇'},
    {'name': 'Night', 'icon': '🌃'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _updatePrompt();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  // logic to build a dynamic prompt
  void _updatePrompt() {
    String flooring = MockData.flooringOptions[_selectedFlooring]['name'];
    String lighting = MockData.cafeLightingOptions[_selectedLighting]['name'];
    String decor = _selectedDecorFeature != -1 ? MockData.decorOptions[_selectedDecorFeature]['name'] : "standard decor";
    
    String prompt = "Professional interior design of a ${widget.selectedStyle.name} cafe. "
        "The space features $flooring flooring and is illuminated by $lighting. "
        "Furniture includes ${(_density > 0.6) ? 'dense' : 'minimal'} seating with ${(_tableSize > 0.6) ? 'large communal' : 'intimate'} tables. "
        "Ambiance is set for $_season during $_timeOfDay. Highlight $decor as key feature. "
        "High quality architectural photography, 8k, cinematic lighting.";
    
    setState(() {
      _promptController.text = prompt;
    });
  }

  Map<String, dynamic> get _allSettings => {
        'density': _density,
        'tableSize': _tableSize,
        'decorScale': _decorScale,
        'sunlight': _sunlight,
        'barScale': _barScale,
        'colorVibrancy': _colorVibrancy,
        'season': _season,
        'timeOfDay': _timeOfDay,
        'flooring': _selectedFlooring,
        'lighting': _selectedLighting,
        'decorFeature': _selectedDecorFeature,
        'customPrompt': _promptController.text, // Sending the custom prompt
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── BACKGROUND PREVIEW ───────────────────────────────────────────
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _styleImage(widget.imagePath),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── TOP NAVIGATION ───────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    _GlassTitle(title: widget.selectedStyle.name.toUpperCase()),
                    _RoundIconButton(
                      icon: Icons.refresh_rounded,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _density = 0.5;
                          _tableSize = 0.3;
                          _decorScale = 0.0;
                          _sunlight = 0.7;
                          _barScale = 0.5;
                          _colorVibrancy = 0.6;
                          _season = 'Spring';
                          _timeOfDay = 'Golden Hour';
                          _selectedFlooring = 0;
                          _selectedLighting = 0;
                          _selectedDecorFeature = -1;
                        });
                        _updatePrompt();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── FLOATING CONTROL PANEL ───────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF161A21).withValues(alpha: 0.98),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                        child: TabBar(
                          controller: _tabController,
                          dividerColor: Colors.transparent,
                          indicatorColor: AppTheme.mossGreen,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white24,
                          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                          isScrollable: true,
                          tabs: const [
                            Tab(text: 'ATMOSPHERE'),
                            Tab(text: 'LAYOUT'),
                            Tab(text: 'STYLE'),
                            Tab(text: 'DECOR'),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAtmosphereTab(),
                            _buildLayoutTab(),
                            _buildStyleTab(),
                            _buildDecorTab(),
                          ],
                        ),
                      ),

                      // ── PROMPT PREVIEW / EDITOR BOX ──────────────────────────
                      _buildPromptEditor(),

                      _buildBottomActions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptEditor() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isPromptExpanded = !_isPromptExpanded),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppTheme.mossGreen, size: 14),
                const SizedBox(width: 8),
                const Text("AI PROMPT ENGINE", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const Spacer(),
                Icon(_isPromptExpanded ? Icons.keyboard_arrow_down_rounded : Icons.edit_note_rounded, color: Colors.white38, size: 18),
              ],
            ),
          ),
          if (_isPromptExpanded) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: "Enter your custom design instructions...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 8),
            const Text("Tip: You can manually refine the AI prompt above", style: TextStyle(color: Colors.white24, fontSize: 9, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _buildAtmosphereTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Season', icon: Icons.wb_sunny_outlined),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _seasonData.length,
              itemBuilder: (context, index) {
                final s = _seasonData[index];
                final isSelected = _season == s['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _season = s['name']);
                    _updatePrompt();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? (s['color'] as Color).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isSelected ? s['color'] as Color : Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Text(s['icon'], style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(s['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Time of Day', icon: Icons.nights_stay_outlined),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _timeData.map((t) {
              final isSelected = _timeOfDay == t['name'];
              return GestureDetector(
                onTap: () {
                  setState(() => _timeOfDay = t['name'] as String);
                  _updatePrompt();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.sunGlow.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppTheme.sunGlow : Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t['icon']),
                      const SizedBox(width: 8),
                      Text(t['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _SliderCard(
            label: 'Sunlight Intensity',
            value: _sunlight,
            icon: Icons.wb_sunny_rounded,
            color: AppTheme.sunGlow,
            onChanged: (v) {
              setState(() => _sunlight = v);
              _updatePrompt();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _SliderCard(
            label: 'Seating Density',
            value: _density,
            icon: Icons.people_outline_rounded,
            color: AppTheme.mossGreen,
            onChanged: (v) {
              setState(() => _density = v);
              _updatePrompt();
            },
          ),
          const SizedBox(height: 16),
          _SliderCard(
            label: 'Table Size',
            value: _tableSize,
            icon: Icons.table_restaurant_rounded,
            color: AppTheme.roseGold,
            onChanged: (v) {
              setState(() => _tableSize = v);
              _updatePrompt();
            },
          ),
          const SizedBox(height: 16),
          _SliderCard(
            label: 'Bar Scale',
            value: _barScale,
            icon: Icons.local_cafe_rounded,
            color: AppTheme.skyBlue,
            onChanged: (v) {
              setState(() => _barScale = v);
              _updatePrompt();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStyleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Flooring Material', icon: Icons.layers_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.flooringOptions.length,
              itemBuilder: (context, index) {
                return _SquareSelectableIcon(
                  label: MockData.flooringOptions[index]['name'],
                  icon: MockData.flooringOptions[index]['icon'],
                  isSelected: _selectedFlooring == index,
                  onTap: () {
                    setState(() => _selectedFlooring = index);
                    _updatePrompt();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Lighting Fixture', icon: Icons.light_rounded),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.cafeLightingOptions.length,
              itemBuilder: (context, index) {
                return _SquareSelectableIcon(
                  label: MockData.cafeLightingOptions[index]['name'],
                  icon: MockData.cafeLightingOptions[index]['icon'],
                  isSelected: _selectedLighting == index,
                  onTap: () {
                    setState(() => _selectedLighting = index);
                    _updatePrompt();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderCard(
            label: 'Decor Scale',
            value: _decorScale,
            icon: Icons.auto_awesome_mosaic_rounded,
            color: AppTheme.coral,
            onChanged: (v) {
              setState(() => _decorScale = v);
              _updatePrompt();
            },
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Key Feature', icon: Icons.star_rounded),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(MockData.decorOptions.length, (index) {
              final option = MockData.decorOptions[index];
              final isSelected = _selectedDecorFeature == index;
              return _ChipSelectable(
                label: option['name'],
                emoji: option['icon'],
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedDecorFeature = isSelected ? -1 : index);
                  _updatePrompt();
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1117),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: ElevatedButton(
        onPressed: () async {
          final ok = await PremiumGate.checkGate(context);
          if (!ok) return;
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GeneratingScreen(
                  imagePath: widget.imagePath,
                  style: widget.selectedStyle,
                  settings: _allSettings,
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.mossGreen,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('ENGAGE AI TRANSFORMATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _GlassTitle extends StatelessWidget {
  final String title;
  const _GlassTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppTheme.mossGreen, size: 14),
      const SizedBox(width: 8),
      Text(title.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    ]);
  }
}

class _SliderCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final ValueChanged<double> onChanged;
  const _SliderCard({required this.label, required this.value, required this.icon, required this.color, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
        ]),
        SliderTheme(
          data: SliderThemeData(activeTrackColor: color, inactiveTrackColor: Colors.white12, thumbColor: Colors.white, trackHeight: 2),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ]),
    );
  }
}

class _SquareSelectableIcon extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _SquareSelectableIcon({required this.label, required this.icon, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.mossGreen.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? AppTheme.mossGreen : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _ChipSelectable extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  const _ChipSelectable({required this.label, required this.emoji, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.skyBlue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppTheme.skyBlue : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

Widget _styleImage(String path, {BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('http')) return Image.network(path, fit: fit);
  return Image.asset(path, fit: fit);
}