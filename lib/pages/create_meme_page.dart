import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/blocs/create_meme_bloc.dart';
import 'package:memogenerator/blocs/main_bloc.dart';
import 'package:memogenerator/resources/app_colors.dart';

import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

class CreateMemePage extends StatefulWidget {
  CreateMemePage({
    Key? key,
  }) : super(key: key);

  @override
  _CreateMemePageState createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppColors.darkGrey, //change your color here
          ),
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          title:
              Text('Создаем мем', style: TextStyle(color: AppColors.darkGrey)),
          bottom: EditTextBar(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.fuchsia,
          onPressed: () {},
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: Text(
            'Создать',
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(child: CreateMemePageContent()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({Key? key}) : super(key: key);

  @override
  _EditTextBarState createState() => _EditTextBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(68);
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final MemeText? selectedMemeText =
                snapshot.hasData ? snapshot.data : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? "";
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }
            final haveSelected = selectedMemeText != null;
            return TextField(
                enabled: haveSelected,
                controller: controller,
                onChanged: (text) => {
                      if (haveSelected)
                        {bloc.changeMemeText(selectedMemeText!.id, text)},
                    },
                onEditingComplete: () => bloc.deselectMemeText(),
                cursorColor: AppColors.fuchsia,
                decoration: InputDecoration(
                  hintText: haveSelected ? "Ввести текст" : null,
                  hintStyle:
                      TextStyle(color: AppColors.darkGrey38, fontSize: 16),
                  filled: true,
                  fillColor:
                      haveSelected ? AppColors.fuchsia16 : AppColors.darkGrey6,
                  disabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.darkGrey38, width: 1),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.fuchsia38, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fuchsia, width: 2),
                  ),
                ));
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  @override
  _CreateMemePageContentState createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: MemeCanvasWidget(),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.darkGrey,
        ),
        Expanded(
          flex: 1,
          child: BottomList(),
        ),
      ],
    );
  }
}

class BottomList extends StatelessWidget {
  const BottomList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: Colors.white,
      child: StreamBuilder<List<MemeTextWithSelection>>(
          stream: bloc.observeMemeTextWithSelection(),
          initialData: const <MemeTextWithSelection>[],
          builder: (context, snapshot) {
            final items = snapshot.hasData
                ? snapshot.data!
                : const <MemeTextWithSelection>[];
            return ListView.separated(
              itemCount: items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return const AddNewMemeTextButton();
                }
                final item = items[index - 1];
                return BottomMemeText(item: item);
              },
              separatorBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return const SizedBox.shrink();
                }
                return BottomSeparator();
              },
            );
          }),
    );
  }
}

class BottomSeparator extends StatelessWidget {
  const BottomSeparator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      height: 1,
      color: AppColors.darkGrey,
    );
  }
}

class BottomMemeText extends StatelessWidget {
  const BottomMemeText({
    Key? key,
    required this.item,
  }) : super(key: key);

  final MemeTextWithSelection item;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 48,
        alignment: Alignment.centerLeft,
        color: item.selected ? AppColors.darkGrey16 : null,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          item.memeText.text,
          style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
        ));
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: AppColors.darkGrey38,
      padding: EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
            color: Colors.white,
            child: StreamBuilder<List<MemeText>>(
                initialData: const <MemeText>[],
                stream: bloc.observeMemeTexts(),
                builder: (context, snapshot) {
                  final memeTexts =
                      snapshot.hasData ? snapshot.data! : const <MemeText>[];
                  return LayoutBuilder(builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => bloc.deselectMemeText(),
                      child: Stack(
                        children: memeTexts.map((memeText) {
                          return DraggableMemeText(
                            memeText: memeText,
                            parentConstraints: constraints,
                          );
                        }).toList(),
                      ),
                    );
                  });
                })),
      ),
    );
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeText memeText;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({
    Key? key,
    required this.memeText,
    required this.parentConstraints,
  }) : super(key: key);

  @override
  _DraggableMemeTextState createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  late double top ;
 late  double left;
  final double padding = 8;

  @override
  void initState() {
    top= widget.parentConstraints.maxHeight/2;
    left = widget.parentConstraints.maxWidth/3;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => bloc.selectMemeText(widget.memeText.id),
          onPanUpdate: (details) {
            bloc.selectMemeText(widget.memeText.id);
            print('DRAG UPDATE: ${details.globalPosition}');
            setState(() {
              left = calculateLeft(details);
              top = calculateTop(details);
            });
          },
          child: StreamBuilder<MemeText?>(
              stream: bloc.observeSelectedMemeText(),
              builder: (context, snapshot) {
                final selectedItem = snapshot.hasData ? snapshot.data : null;
                final selected = widget.memeText.id == selectedItem?.id;
                return MemeTextOnCanvas(
                  widget: widget,
                  parentConstraints: widget.parentConstraints,
                  memeText: widget.memeText,
                  padding: padding,
                  selected: selected,
                );
              })),
    );
  }

  double calculateTop(DragUpdateDetails details) {
    final rawTop = top + details.delta.dy;
    if (rawTop < 0) {
      return 0;
    }
    if (rawTop > widget.parentConstraints.maxHeight - padding * 2 - 30) {
      return widget.parentConstraints.maxHeight - padding * 2 - 30;
    }
    return rawTop;
  }

  double calculateLeft(DragUpdateDetails details) {
    final rawLeft = left + details.delta.dx;
    if (rawLeft < 0) {
      return 0;
    }
    if (rawLeft > widget.parentConstraints.maxWidth - padding * 2 - 10) {
      return widget.parentConstraints.maxWidth - padding * 2 - 10;
    }
    return rawLeft;
  }
}

class MemeTextOnCanvas extends StatelessWidget {
  const MemeTextOnCanvas({
    Key? key,
    required this.widget,
    required this.padding,
    required this.selected,
    required this.parentConstraints,
    required this.memeText,
  }) : super(key: key);

  final DraggableMemeText widget;

  final double padding;
  final bool selected;
  final BoxConstraints parentConstraints;
  final MemeText memeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: parentConstraints.maxWidth,
          maxHeight: parentConstraints.maxHeight),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
          color: selected ? AppColors.darkGrey16 : null,
          border: Border.all(
              color: selected ? AppColors.fuchsia : Colors.transparent,
              width: 1)),
      child: Text(
        memeText.text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }
}

class AddNewMemeTextButton extends StatelessWidget {
  const AddNewMemeTextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      onTap: () => bloc.addNewText(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                color: AppColors.fuchsia,
              ),
              const SizedBox(
                width: 8,
              ),
              Text("Добавить текст".toUpperCase(),
                  style: TextStyle(
                      color: AppColors.fuchsia,
                      fontSize: 14,
                      fontWeight: FontWeight.w500))
            ],
          ),
        ),
      ),
    );
  }
}
