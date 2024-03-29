import 'package:flutter/material.dart';
import 'package:oph_core/utils/form_service.dart';
import 'package:oph_elements/utils/form_element.dart';
import 'package:oph_core/models/oph.dart';
//import 'package:oph_core/oph_core.dart';
import 'package:oph_core/models/preset.dart';

class FormDetail extends StatefulWidget {
  FormDetail(
      {Key key,
      this.title,
      @required this.alias,
      @required this.frm,
      //@required this.guid,
      this.parentguid,
      this.page,
      this.section,
      this.ratio,
      this.onChanged,
      @required this.preset})
      : super(key: key);

  final String title;
  final String alias;
  final FormService frm; // = FormService();
  //final String guid;
  final String parentguid;
  final int page;
  final int section;
  final double ratio;
  final Function onChanged;
  final Preset preset;
  @override
  _FormDetailState createState() => _FormDetailState();
}

class _FormDetailState extends State<FormDetail> {
  _FormDetailState();

  FormEl el = new FormEl();
  //Frm curForm;
  //Frm curForm = Frm(code: '', guid: '00000000-0000-0000-0000-000000000000');
  //bool isLoaded = false;

  @override
  void initState() {
    //curForm.code = widget.code;
    initForm();
    super.initState();
  }

  Future<void> initForm() async {
    //if (!widget.frm.isInit) widget.frm.init();
    if (!widget.frm.curForm().isLoaded) {
      await widget.frm.loadForm();
      if (mounted) setState(() {});
    }
    el.init(() {
      if (mounted) setState(() {});
    }, widget.preset
        //widget.preset,
        );

    //});
  }

  Future<bool> saveForm() async {
    bool b = true;
    widget.frm.curForm().fields.forEach((f) {
      if (!f.isNullable && f.controller.value.text == '') b = false;
    });
    if (b)
      b = await widget.frm.save(parentguid: widget.parentguid);
    else
      _showSnackBar('You have to complete all mandatory fields.');
    return b;
  }

  Future<bool> delForm() async {
    return await widget.frm.function(action: 'delete');
  }

  _showSnackBar(String message, {int duration = 3}) {
    if (message != '') {
      final snackBar = new SnackBar(
          duration: Duration(seconds: duration), content: new Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  PreferredSizeWidget appBarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(36.0),
        child: AppBar(
          backgroundColor: widget.preset.color2,
          elevation: 0,
          title: Text(widget.title ?? '', style: TextStyle(fontSize: 16)),
        ));
  }

  Widget inputForm(List<FrmField> f, int i) {
    double scrw = MediaQuery.of(context).size.width;
    print(f[i].boxType);
    return f[i].boxType == 'textBox'
        ? el.textBox(f[i], isEnabled: f[i].isEditable > 0, onChanged: () {
            if (widget.onChanged != null) widget.onChanged();
            setState(() {});
          })
        //, frm.fields[i].fieldName, frm.fields[i].caption, frm.fields[i].controller)
        : f[i].boxType == 'autosuggestBox'
            ? el.chooseBox(context, widget.alias, f[i], widget.frm,
                isEnabled: f[i].isEditable > 0, onChanged: () {
                if (widget.onChanged != null) widget.onChanged();
                setState(() {});
              }) //frm.fields[i].fieldName, frm.fields[i].caption, frm.fields[i].controller)
            : f[i].boxType == 'dateBox'
                ? el.dateBox(f[i], isEnabled: f[i].isEditable > 0,
                    onChanged: () {
                    if (widget.onChanged != null) widget.onChanged();
                    setState(() {});
                  }) //frm.fields[i].fieldName, frm.fields[i].caption, frm.fields[i].controller)

            : f[i].boxType == 'checkBox'
                ? el.switchBox(context, f[i], isEnabled: f[i].isEditable > 0,
                    onChanged: () {
                    if (widget.onChanged != null) widget.onChanged();
                    setState(() {});
                  }) //frm.fields[i].fieldName, frm.fields[i].caption, frm.fields[i].controller)
              : f[i].boxType == 'radioBox'
                ? el.radioButton(f[i], isEnabled: f[i].isEditable > 0,
                    onChanged: () {
                    if (widget.onChanged != null) widget.onChanged();
                    setState(() {});
                  }) //frm.fields[i].fieldName, frm.fields[i].caption, frm.fields[i].controller)

                : f[i].boxType == 'profileBox'
                    ? el.profileBox(
                        context, f[i], scrw, scrw / widget.ratio ?? 1,
                        isEnabled: f[i].isEditable > 0, onChanged: () {
                        if (widget.onChanged != null) widget.onChanged();
                        setState(() {});
                      })
                    : f[i].boxType == 'setGPSBox'
                        ? el.setGPSBox(context, f[i],
                            isEnabled: f[i].isEditable > 0, onChanged: () {
                            if (widget.onChanged != null) widget.onChanged();
                            setState(() {});
                          })
                        : f[i].boxType == 'passwordBox'
                            ? el.passwordBox(f[i],
                                isEnabled: f[i].isEditable > 0, onSubmitted: () {
                                if (widget.onChanged != null)
                                  widget.onChanged();
                                setState(() {});
                              })
                            : Container();
  }

  Widget listWidget(List<FrmField> fld) {
    var h = MediaQuery.of(context).size.height;
    return !widget.frm.curForm().isLoaded
        ? Center(child: Text('Loading...'))
        : SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
                padding: EdgeInsets.all(10.0),
                child: ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: fld.length + 1,
                    itemBuilder: (context, index) {
                      //children: List.generate(a.length + 1, (index) {
                      return (index < fld.length)
                          ? inputForm(fld, index)
                          : Container(
                              //height: 400,
                              child: ButtonBar(
                              buttonHeight: h / 16,
                              alignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  iconSize: h / 16 / 1.5,
                                  onPressed: () async {
                                    bool r = await delForm();
                                    if (r) Navigator.pop(context, true);
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        fontSize: h / 16 / 2,
                                        color: widget.preset.color4),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                ),
                                TextButton(
                                  //color: g.color1,
                                  style: TextButton.styleFrom(
                                      backgroundColor: widget.preset.color1),
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: h / 16 / 2,
                                        color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    bool r = await saveForm();
                                    if (r)
                                      Navigator.pop(context, true);
                                    else if (!r)
                                      _showSnackBar(widget.frm.error());
                                  },
                                ),
                              ],
                            ));
                    })));
  }

  Widget bodyWidget() {
    return listWidget(_refresh());

    /*FutureBuilder(
        builder: (context, projectSnap) {
          if (projectSnap.connectionState == ConnectionState.waiting &&
              projectSnap.data == null) {
            return Center(child: Text('Loading. Please wait...'));
          } else if ((projectSnap.connectionState == ConnectionState.none &&
              projectSnap.hasData == null)) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Center(child: Text('No data available'));
          } else
            return listWidget(projectSnap.data);
        },
        future: _refresh());*/
  }

  List<FrmField> _refresh({isForced: false}) {
    //frm = await BrowseList.getList(widget.alias, g.dataList)
    //  .getForm(widget.frm.formGUID(), reload: isForced);
    Frm curForm = widget.frm?.curForm();
    List<FrmField> r = [];
    if (curForm != null &&
        curForm.fields
                .where((f) =>
                    f.sectionNo ==
                        (widget.section != null
                            ? widget.section
                            : f.sectionNo) &&
                    f.pageNo == (widget.page != null ? widget.page : f.pageNo))
                .toList()
                .length >
            0)
      r = curForm.fields
          .where((f) =>
              f.sectionNo ==
                  (widget.section != null ? widget.section : f.sectionNo) &&
              f.pageNo == (widget.page != null ? widget.page : f.pageNo))
          .toList();
    return r;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBarWidget(),
      body: RefreshIndicator(
          onRefresh: () async {
            _refresh(isForced: true);
          },
          child: bodyWidget()),
    );
  }
}
