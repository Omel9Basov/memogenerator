import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/blocs/main_bloc.dart';
import 'package:memogenerator/pages/create_meme_page.dart';
import 'package:memogenerator/resources/app_colors.dart';

import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  MainPage({
    Key? key,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          title: Text('Мемогенератор',
              style: GoogleFonts.seymourOne(
                  fontSize: 24, color: AppColors.darkGrey)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.fuchsia,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateMemePage(),
              ),
            );
          },
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
          child: Center(child: MainPageContent()),
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

class MainPageContent extends StatefulWidget {
  @override
  _MainPageContentState createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
