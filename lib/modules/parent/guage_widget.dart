// lib/widgets/gauge_widget.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Paleta principal inspirada en la imagen: rojo, morado, azul, naranja, verde.
const kGaugeColors = <Color>[
  Color(0xFFF04B3A), // rojo
  Color(0xFF7E57C2), // morado
  Color(0xFF29B6F6), // azul
  Color(0xFFF39C12), // naranja
  Color(0xFF2ECC71), // verde
];

/// Gauge con animación y stream opcional
class GaugeLive extends StatefulWidget {
  final double value; // 0..100
  final Stream<double>? stream; // opcional
  final String titleBottom;
  final Duration animDuration;
  final List<(Color, String, String)>? legend;

  const GaugeLive({
    super.key,
    required this.value,
    this.stream,
    required this.titleBottom,
    this.animDuration = const Duration(milliseconds: 450),
    this.legend,
  });

  @override
  State<GaugeLive> createState() => _GaugeLiveState();
}

class _GaugeLiveState extends State<GaugeLive> {
  late double _cur, _prev;
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();
    _cur = _prev = _clamp(widget.value);
    _attach();
  }

  @override
  void didUpdateWidget(covariant GaugeLive old) {
    super.didUpdateWidget(old);
    if (old.stream != widget.stream) {
      _sub?.cancel();
      _attach();
    }
    if (widget.stream == null && old.value != widget.value) {
      setState(() {
        _prev = _cur;
        _cur = _clamp(widget.value);
      });
    }
  }

  void _attach() {
    if (widget.stream != null) {
      _sub = widget.stream!.listen((v) {
        setState(() {
          _prev = _cur;
          _cur = _clamp(v);
        });
      });
    }
  }

  double _clamp(double v) => v.clamp(0, 100).toDouble();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _prev, end: _cur),
      duration: widget.animDuration,
      curve: Curves.easeOutCubic,
      builder: (_, animated, __) => GaugeCard(
        value: animated,
        titleBottom: widget.titleBottom,
        legend: widget.legend,
      ),
    );
  }
}

class GaugeCard extends StatelessWidget {
  final double value; // 0..100
  final String titleBottom;
  final List<(Color, String, String)>? legend;

  const GaugeCard({
    super.key,
    required this.value,
    required this.titleBottom,
    this.legend,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.clamp(320, 520).toDouble();
    final h = width * 0.95;

    final defaultLegend = <(Color, String, String)>[
      (
        const Color(0xFF2ECC71),
        'Primer nivel',
        'Menos de 2 h: saludable y estable.',
      ),
      (
        const Color(0xFF29B6F6),
        'Segundo nivel',
        '2–3.5 h: aceptable con pausas.',
      ),
      (const Color(0xFFF39C12), 'Tercer nivel', '3.5–4.6 h: zona límite.'),
      (const Color(0xFF7E57C2), 'Cuarto nivel', '4.7–4.8 h: crítico; reducir.'),
      (const Color(0xFFF04B3A), 'Quinto nivel', 'Más de 4.8 h: sobreuso.'),
    ];
    final legendData = legend ?? defaultLegend;

    Widget legendTile(Color c, String t, String d) => Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  d,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(.05), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Medidor
          SizedBox(
            width: width * 0.92,
            height: h * 0.65,
            child: CustomPaint(
              painter: _GaugePainter(value: value.clamp(0, 100)),
            ),
          ),
          const SizedBox(height: 12),
          // Título
          Text(
            titleBottom.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          // Muestras de color
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: kGaugeColors
                .map(
                  (c) => Container(
                    width: 34,
                    height: 18,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Leyenda
          ...legendData.map((e) => legendTile(e.$1, e.$2, e.$3)),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value; // 0..100
  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final center = Offset(w / 2, h * 0.96);
    final r = w * 0.43;
    const start = pi, sweep = pi;
    final rect = Rect.fromCircle(center: center, radius: r);

    // sombra suave
    final shadow = Paint()
      ..color = Colors.black.withOpacity(.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.15
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(rect, start, sweep, false, shadow);

    // pista
    final track = Paint()
      ..color = Colors.black.withOpacity(.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.13
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, track);

    // segmentos de color
    final segSweep = sweep / kGaugeColors.length;
    const gap = 0.04;
    for (int i = 0; i < kGaugeColors.length; i++) {
      final segStart = start + i * segSweep + gap / 2;
      final segLen = segSweep - gap;
      final p = Paint()
        ..color = kGaugeColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.13
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, segStart, segLen, false, p);

      if (i > 0) {
        final a = start + i * segSweep;
        final p1 = Offset(
          center.dx + cos(a) * (r - w * 0.07),
          center.dy + sin(a) * (r - w * 0.07),
        );
        final p2 = Offset(
          center.dx + cos(a) * (r + w * 0.07),
          center.dy + sin(a) * (r + w * 0.07),
        );
        final div = Paint()
          ..color = Colors.white.withOpacity(.9)
          ..strokeWidth = 1.2;
        canvas.drawLine(p1, p2, div);
      }
    }

    // aguja
    final ang = pi + pi * (value / 100.0);
    final end = Offset(
      center.dx + cos(ang) * (r * 0.9),
      center.dy + sin(ang) * (r * 0.9),
    );
    final sh = Paint()
      ..color = Colors.black.withOpacity(.18)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final arm = Paint()
      ..color = const Color(0xFF3b3b3b)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center.translate(0, 2), end.translate(0, 2), sh);
    canvas.drawLine(center, end, arm);
    canvas.drawCircle(
      center,
      w * 0.08,
      Paint()..color = const Color(0xFF2b2b2b),
    );
    canvas.drawCircle(
      center,
      w * 0.05,
      Paint()..color = const Color(0xFF1a1a1a),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.value != value;
}
