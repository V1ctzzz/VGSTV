import 'package:flutter/material.dart';
import 'package:vgs/helpers/responsive_helper.dart';

enum IconType { youtube, portal, radio, tv }

class MenuButton extends StatelessWidget {
  const MenuButton(
      {super.key, required this.iconType, required this.onPressed});
  final IconType iconType;
  final VoidCallback onPressed;

  static const Color corAzul = Color.fromRGBO(28, 23, 59, 1.0);

  String get text {
    switch (iconType) {
      case IconType.youtube:
        return 'YouTube';
      case IconType.portal:
        return 'Portal';
      case IconType.radio:
        return 'Rádio';
      case IconType.tv:
        return 'TV';
    }
  }

  AssetImage get image {
    switch (iconType) {
      case IconType.youtube:
        return const AssetImage('assets/images/youtube.png');
      case IconType.portal:
        return const AssetImage('assets/images/portal.png');
      case IconType.radio:
        return const AssetImage('assets/images/radio.png');
      case IconType.tv:
        return const AssetImage('assets/images/tv.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tamanhos responsivos baseados no tipo de dispositivo
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktopOrTV = ResponsiveHelper.isDesktopOrTV(context);
    
    final buttonHeight = ResponsiveHelper.getResponsiveSize(
      context,
      mobile: 140.0,
      tablet: 180.0,
      desktop: 200.0,
    );
    
    final buttonWidth = ResponsiveHelper.getResponsiveSize(
      context,
      mobile: 160.0,
      tablet: 200.0,
      desktop: 220.0,
    );
    
    final iconSize = ResponsiveHelper.getResponsiveSize(
      context,
      mobile: 60.0,
      tablet: 80.0,
      desktop: 90.0,
    );
    
    final fontSize = ResponsiveHelper.getResponsiveSize(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final borderRadius = isDesktopOrTV ? 20.0 : (isTablet ? 18.0 : 16.0);

    return Padding(
      padding: padding,
      child: SizedBox(
        height: buttonHeight,
        width: buttonWidth,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll(corAzul),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              )),
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: image,
                height: iconSize,
                width: iconSize,
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
