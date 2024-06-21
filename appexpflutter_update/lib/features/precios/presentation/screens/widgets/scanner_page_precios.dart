import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPrecioPage extends HookWidget {
  final void Function(BarcodeCapture)? onDetect;

  const ScannerPrecioPage({super.key, this.onDetect});

  @override
  Widget build(BuildContext context) {
    final cameraController = useMemoized(() => MobileScannerController(), []);

    useEffect(() {
      cameraController.start();

      return () {
        cameraController.stop();
        cameraController.dispose();
      };
    }, []);

    Widget buildBarcode(Barcode? value) {
      if (value == null) {
        return const Text(
          '¡Escanea algo!',
          overflow: TextOverflow.fade,
          style: TextStyle(color: Colors.white),
        );
      }

      return Text(
        value.displayValue ?? 'Sin valor de visualización.',
        overflow: TextOverflow.fade,
        style: const TextStyle(color: Colors.white),
      );
    }

    return AlertDialog(
      title: Center(
          child: Text(
        'Producto scanner',
        style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colores.secondaryColor,
            shadows: [
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2.0, 5.0),
              )
            ]),
      )),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: onDetect,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.bottomCenter,
                height: 100,
                color: Colors.black.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: Center(child: buildBarcode(null))),
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
