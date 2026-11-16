
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_mark.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onGuest;

  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mc.frame,
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;

            // Responsive image height
            final imageHeight =
                (screenHeight * 0.48).clamp(180.0, 420.0);

            return Column(
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          'https://images.pexels.com/photos/8483832/pexels-photo-8483832.jpeg?auto=compress&cs=tinysrgb&w=1200',
                          fit: BoxFit.cover,
                          alignment: Alignment(0, -0.6),
                          width: double.infinity,
                          height: double.infinity,
                          webHtmlElementStrategy:
                              WebHtmlElementStrategy.prefer,
                          loadingBuilder:
                              (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : Container(
                                          color: context.mc.placeholder,
                                        ),
                          errorBuilder: (context, error, stack) {
                            debugPrint(
                                'Welcome image failed: $error');
                            return Container(
                              color: context.mc.placeholder,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: context.mc.textFaint,
                              ),
                            );
                          },
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF31231B).withOpacity(0.18),
                              Color(0xFF31231B).withOpacity(0.48),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 28,
                        left: 28,
                        child: BrandMark(light: true),
                      ),

                      Positioned(
                        top: 33,
                        right: 28,
                        child: Text(
                          'SS / 26',
                          style: TextStyle(
                            letterSpacing: 1.28,
                            fontSize: 9,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable bottom section
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        28, 25, 28, 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 13,
                                color: context.mc.brandSoft,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'THE CONSIDERED EDIT',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.3,
                                  color: context.mc.brandSoft,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15),

                          RichText(
                            text: TextSpan(
                              style: context.mc.heroTitle.copyWith(
                                fontSize: 50,
                                height: 0.98,
                              ),
                              children: [
                                TextSpan(text: 'Wear what\n'),
                                TextSpan(
                                  text: 'feels like you.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: context.mc.brandLight,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 17),

                          Text(
                            'Thoughtfully selected pieces for the life you actually live.',
                            style: context.mc.body,
                          ),

                          SizedBox(height: 25),

                          _PrimaryButton(
                            label: 'Create your account',
                            onPressed: onStart,
                          ),

                          SizedBox(height: 12),

                          GestureDetector(
                            onTap: onGuest,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Explore as guest',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.mc.textMid,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 17),

                          Center(
                            child: Text(
                              'By continuing, you agree to our Terms & Privacy Policy.',
                              style: TextStyle(
                                fontSize: 8,
                                color: context.mc.textFaint
                                    .withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: context.mc.primaryButton,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 9),
            Icon(
              Icons.arrow_forward,
              size: 17,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
