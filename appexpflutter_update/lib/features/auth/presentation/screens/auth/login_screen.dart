import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:appexpflutter_update/features/auth/presentation/screens/auth/widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.open(Media('asset:///assets/videos/background_login_mobile.mp4'));
    player.setPlaylistMode(PlaylistMode.loop);
    player.setVolume(0.0);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Video de fondo
            Positioned.fill(
              child: Video(
                controller: controller,
                controls: NoVideoControls,
                fit: BoxFit.cover,
              ),
            ),
            // Overlay oscuro para legibilidad
            Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height,
                ),
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 90),
                        Image.asset(
                          'assets/images/tufan_logo.png',
                          scale: 2.5,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: size.height - 340,
                          width: double.infinity,
                          child: const LoginForm(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
