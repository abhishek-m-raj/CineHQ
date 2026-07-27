import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/style/style.dart';
import 'package:video/widgets/btns/btn.dart';
import '../../controller.dart';

class FitBtn extends StatelessWidget {
  final Controller controller;
  final VidStyle style;

  const FitBtn({super.key, required this.style, required this.controller});

  IconSource _getIcon(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return HqIcons.vidBoxContain;
      case BoxFit.cover:
        return HqIcons.vidBoxCover;
      case BoxFit.fill:
        return HqIcons.vidBoxFill;
      default:
        return HqIcons.vidBoxContain;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BoxFit>(
      stream: controller.fitController.stream,
      initialData: controller.fit,
      builder: (context, snapshot) {
        final BoxFit currentFit = snapshot.data ?? BoxFit.contain;
        return Tooltip(
          message: 'Fit: ${currentFit.toString().split('.').last}',
          child: VidBtn(onTap: () => controller.cycleFit(), icon: _getIcon(currentFit), style: style),
        );
      },
    );
  }
}
