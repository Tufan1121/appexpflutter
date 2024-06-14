import 'package:appexpflutter_update/features/precios/presentation/bloc/precios_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:appexpflutter_update/config/theme/app_theme.dart';
import 'package:appexpflutter_update/features/precios/presentation/screens/widgets/qr_scanner_overray.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ScannerPage extends HookWidget {
  ScannerPage({super.key});
  final MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    final scanResult = useState<String>('');

    useEffect(() {
      // Inicia la cámara cuando se construye el widget por primera vez
      cameraController.start();

      // Limpiar el controlador cuando se elimina el widget
      return () {
        cameraController.stop();
        cameraController.dispose();
      };
    }, []);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 325,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 223,
                      width: 223,
                      child: MobileScanner(
                        controller: cameraController,
                        fit: BoxFit.cover,
                        onDetect: (barcode) {
                          // Manejar la detección de códigos de barras
                          scanResult.value =
                              barcode.barcodes.first.rawValue ?? '';

                          // Cerrar modal, se crea una ruta a la que deseas regresar cuando se cierra el modal
                          Navigator.of(context)
                              .popUntil(ModalRoute.withName('/precios'));

                          context
                              .read<PreciosBloc>()
                              .add(GetQRProductEvent(clave: scanResult.value));
                        },
                      ),
                    ),
                    QRScannerOverlay(
                      overlayColour: Colors.black.withOpacity(0.2),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: cameraController,
                      builder: (context, state, child) {
                        if (!state.isInitialized || !state.isRunning) {
                          return const SizedBox.shrink();
                        }

                        switch (state.torchState) {
                          case TorchState.auto:
                            return IconButton(
                              color: Colors.black,
                              iconSize: 32.0,
                              icon: const Icon(Icons.flash_auto),
                              onPressed: () async {
                                await cameraController.toggleTorch();
                              },
                            );
                          case TorchState.off:
                            return IconButton(
                              color: Colors.black,
                              iconSize: 32.0,
                              icon: const Icon(Icons.flash_off),
                              onPressed: () async {
                                await cameraController.toggleTorch();
                              },
                            );
                          case TorchState.on:
                            return IconButton(
                              color: Colors.black,
                              iconSize: 32.0,
                              icon: const Icon(
                                Icons.flash_on,
                                color: Colors.yellow,
                              ),
                              onPressed: () async {
                                await cameraController.toggleTorch();
                              },
                            );
                          case TorchState.unavailable:
                            return const Icon(
                              Icons.no_flash,
                              color: Colors.grey,
                            );
                        }
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: cameraController,
                      builder: (context, state, child) {
                        if (!state.isInitialized || !state.isRunning) {
                          return const SizedBox.shrink();
                        }

                        final int? availableCameras = state.availableCameras;

                        if (availableCameras != null && availableCameras < 2) {
                          return const SizedBox.shrink();
                        }

                        final Widget icon;

                        switch (state.cameraDirection) {
                          case CameraFacing.front:
                            icon = const Icon(Icons.camera_front);
                          case CameraFacing.back:
                            icon = const Icon(Icons.camera_rear);
                        }

                        return IconButton(
                          iconSize: 32.0,
                          icon: icon,
                          onPressed: () async {
                            await cameraController.switchCamera();
                          },
                        );
                      },
                    )
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Clave:',
                        style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      AutoSizeText(
                        scanResult.value,
                        style: GoogleFonts.montserrat(
                            fontSize: 15, color: Colores.secondaryColor),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
