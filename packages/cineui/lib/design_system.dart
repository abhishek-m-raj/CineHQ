import 'package:flutter/material.dart';
import 'package:cineui/cineui.dart';
import 'typography/fonts.dart';

class CineDesignSystemScreen extends StatelessWidget {
  const CineDesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Design System Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypographySection(),
            _ButtonsSection(),
            _InputSection(),
            _IconsSection(),
            _CardsSection(),
            _MiscSection(),
            _DialogSection(),
          ],
        ),
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CineText('Typography', style: CineTextStyles.h2),
        SizedBox(height: 16),
        Wrap(
          runSpacing: 8,
          spacing: 8,
          children: [
            CineText('Teko', style: CineFonts.teko),
            CineText('Rubik', style: CineFonts.rubik),
            CineText('Poppins', style: CineFonts.poppins),
            CineText('Roboto', style: CineFonts.roboto),
          ],
        ),
        SizedBox(height: 8),
        CineText('Headline 1', style: CineTextStyles.h1),
        CineText('Headline 2', style: CineTextStyles.h2),
        CineText('Headline 3', style: CineTextStyles.h3),
        CineText('body 1', style: CineTextStyles.b1),
        CineText('body 2', style: CineTextStyles.b2),
        CineText('body 3', style: CineTextStyles.b3),
        CineText('button text', style: CineTextStyles.btnText),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CineText('Buttons', style: CineTextStyles.h2),
        SizedBox(height: 8),
        SizedBox(
          width: 500,
          child: Column(
            children: [
              CinePrimaryBtn(text: "Primary Btn", onTap: () {}),
              SizedBox(height: 8),
              CineSecondaryBtn(text: "Secondary Btn", onTap: () {}),
              SizedBox(height: 8),
              CineTertiaryBtn(onTap: () {}, icon: NormalIcon(Icons.add)),
              SizedBox(height: 8),
              CineListTile(title: "ListTile", leadingIcon: CineIcons.home, endArrow: true, onPress: () {}),
              SizedBox(height: 8),
              CineDropDown<String>(
                width: 200,
                hintText: "Dropdown",
                items: ["Item 1", "Item 2", "Item 3"],
                initialItem: "Item 1",
                onChange: (_) {},
              ),
              SizedBox(height: 8),
              CineRadioBtn<String>(items: ["Item 1", "Item 2", "Item 3"], initialItem: "Item 1", onChange: (_) {}),
            ],
          ),
        ),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  const _InputSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CineText('Input', style: CineTextStyles.h2),
        SizedBox(height: 8),
        CineTextField(hintText: "Enter text !!", onChange: (value) {}),
        SizedBox(height: 8),
        CineTextField(hintText: "Search here!", icon: CineIcons.search, onChange: (value) {}),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _IconsSection extends StatelessWidget {
  const _IconsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CineText('Icons', style: CineTextStyles.h2),
        SizedBox(height: 8),
        Wrap(
          spacing: 30,
          runSpacing: 30,
          children: [
            ...CineIcons.getAllIcons().map((IconSource icon) {
              return CineIcon(icon: icon, size: 50);
            }),
          ],
        ),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CineText('Cards', style: CineTextStyles.h2),
        SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              CineCard(height: 200, aspectRatio: 1, padding: EdgeInsets.all(16), child: SizedBox()),
              SizedBox(width: 8),
              SizedBox(width: 200, height: 200, child: CineSkelton()),
            ],
          ),
        ),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _MiscSection extends StatelessWidget {
  const _MiscSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CineText('Misc', style: CineTextStyles.h2),
        SizedBox(height: 8),
        CineChip(text: "Chip", onTap: () {}),
        SizedBox(height: 8),
        CineFilterChip<String>(selected: ["Item 1"], options: ["Item 1", "Item 2", "Item 3"], onChange: (value) {}),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
      ],
    );
  }
}

class _DialogSection extends StatelessWidget {
  const _DialogSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CineText('Dialog', style: CineTextStyles.h2),
        SizedBox(height: 8),
        CineChip(
          text: "Dialog",
          onTap: () {
            CineDialog(
              content: CineText("CineHQ", style: CineTextStyles.h2),
              actions: [CineChip(text: "cancel", onTap: () => Navigator.of(context).pop())],
            ).show(context);
          },
        ),
        SizedBox(height: 8),
        CineChip(
          text: "Snackbar",
          onTap: () {
            CineSnackbar(icon: CineIcons.download, content: "CineHQ").show(context);
          },
        ),
        SizedBox(height: 8),
        CineChip(
          text: "BottomSheet",
          onTap: () {
            CineBottomSheet(
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CineListTile(title: "title1", onPress: () {}),
                    CineListTile(title: "title2", onPress: () {}),
                  ],
                );
              },
            ).show(context);
          },
        ),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 16),
      ],
    );
  }
}
