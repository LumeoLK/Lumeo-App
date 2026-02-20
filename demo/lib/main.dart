import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:ar_flutter_plugin_flutterflow/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

// ── Entry point ───────────────────────────────────────────
void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

// ── App root ──────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumeo',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}

// ── Home screen with AR button ────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ARScreen()),
            );
          },
          icon: const Icon(Icons.view_in_ar),
          label: const Text('Launch AR'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFBB040),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// ── AR Screen ─────────────────────────────────────────────
class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  String statusText = "🔍 Slowly move your phone to scan surfaces...";

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Cube Placer'),
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFBB040).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '👆 Tap on a detected surface to place a cube',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    arSessionManager!.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      handleTaps: true,
    );

    arObjectManager!.onInitialize();

    arSessionManager!.onPlaneOrPointTap = _onPlaneTapped;

    arSessionManager!.onPlaneDetected = (plane) {
      setState(() {
        statusText = "✅ Surface detected! Tap to place a cube.";
      });
    };
  }

  Future<void> _onPlaneTapped(List<ARHitTestResult> hits) async {
    ARHitTestResult? planeHit;
    try {
      planeHit = hits.firstWhere(
        (h) => h.type == ARHitTestResultType.plane,
      );
    } catch (_) {
      if (hits.isEmpty) {
        setState(() => statusText = "⚠️ Tap directly on a detected surface.");
        return;
      }
      planeHit = hits.first;
    }

    setState(() => statusText = "📦 Placing cube...");

    final anchor = ARPlaneAnchor(transformation: planeHit.worldTransform);
    final anchorAdded = await arAnchorManager!.addAnchor(anchor);

    if (anchorAdded != true) {
      setState(() => statusText = "❌ Could not place anchor. Try again.");
      return;
    }

    anchors.add(anchor);

    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: "assets/models/cube.glb", // ← make sure this matches your file
      scale: vector.Vector3(0.15, 0.15, 0.15),
      position: vector.Vector3(0.0, 0.0, 0.0),
      rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
    );

    final nodeAdded = await arObjectManager!.addNode(node, planeAnchor: anchor);

    if (nodeAdded == true) {
      nodes.add(node);
      setState(() => statusText = "✅ Cube placed! Tap again to add more.");
    } else {
      setState(() => statusText = "❌ Failed to place cube. Check asset path.");
    }
  }

  Future<void> _clearAll() async {
    for (final node in nodes) {
      await arObjectManager?.removeNode(node);
    }
    for (final anchor in anchors) {
      await arAnchorManager?.removeAnchor(anchor);
    }
    nodes.clear();
    anchors.clear();
    setState(() => statusText = "🔍 Slowly move your phone to scan surfaces...");
  }
}