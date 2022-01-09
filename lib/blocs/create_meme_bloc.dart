import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class CreateMemeBloc {

  final memeTextsSubject = BehaviorSubject<List<MemeText>>.seeded(<MemeText>[]);
  final selectedMemeTextsSubject = BehaviorSubject<MemeText?>.seeded(null);

  void addNewText() {
    final newMemeText = MemeText.create();
    memeTextsSubject.add([...memeTextsSubject.value, newMemeText]);
    selectedMemeTextsSubject.add(newMemeText);
  }

  void changeMemeText(final String id, final String text) {
    final copiedList = [...memeTextsSubject.value];
    final index = copiedList.indexWhere((memeText) => memeText.id == id);
    if (index == -1) {
      return;
    }
    copiedList.removeAt(index);
    copiedList.insert(index, MemeText(id: id, text: text));
    memeTextsSubject.add(copiedList);
  }

  void selectMemeText(final String id) {
    final foundMemeText = memeTextsSubject.value.firstWhereOrNull((
        memeText) => memeText.id == id);
    selectedMemeTextsSubject.add(foundMemeText);
  }

  void deselectMemeText() {
    selectedMemeTextsSubject.add(null);
  }


  Stream<List<MemeText>> observeMemeTexts() =>
      memeTextsSubject.distinct((prev, next) =>
          ListEquality().equals(prev, next));


  Stream<MemeText?> observeSelectedMemeText() =>
      selectedMemeTextsSubject.distinct();

  Stream<List<MemeTextWithSelection>> observeMemeTextWithSelection() {
    return
      Rx.combineLatest2 < List<MemeText>,
          MemeText?,
        List<  MemeTextWithSelection>>(observeMemeTexts(), observeSelectedMemeText(), (memeText, selectedMemeText) {
    return memeText.map((memeText){
    return MemeTextWithSelection(memeText: memeText, selected: memeText.id== selectedMemeText?.id);
    }).toList();
    },
      );


  }

  void dispose() {
    memeTextsSubject.close();
    selectedMemeTextsSubject.close();
  }
}

class MemeTextWithSelection {
  final MemeText memeText;
  final bool selected;

  MemeTextWithSelection({required this.memeText, required this.selected});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MemeTextWithSelection &&
              runtimeType == other.runtimeType &&
              memeText == other.memeText &&
              selected == other.selected;

  @override
  int get hashCode => memeText.hashCode ^ selected.hashCode;

}

class MemeText {
  final String id;
  final String text;

  MemeText({required this.id, required this.text});


  factory MemeText.create(){
    return MemeText(id: Uuid().v4(), text: "");
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MemeText &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;

  @override
  String toString() {
    return 'MemeText{id: $id, text: $text}';
  }
}