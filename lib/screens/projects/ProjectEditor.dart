
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import '../../../blocs/projects/bloc.dart';
import '../../../l10n.dart';
import '../../../models/project.dart';

class ProjectEditor extends StatefulWidget {
  final Project? project;
  const ProjectEditor({Key? key, required this.project}) : super(key: key);

  @override
  State<ProjectEditor> createState() => _ProjectEditorState();
}

class _ProjectEditorState extends State<ProjectEditor> {
  TextEditingController? _nameController;
  Color? _colour;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.name);
    _colour = widget.project?.colour ?? Colors.grey[50];
  }

  @override
  void dispose() {
    _nameController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text(
              widget.project == null
                  ? L10N.of(context).tr.createNewProject
                  : L10N.of(context).tr.editProject,
              style: Theme.of(context).textTheme.headline6,
            ),
            TextFormField(
              controller: _nameController,
              validator: (String? value) => value!.trim().isEmpty
                  ? L10N.of(context).tr.pleaseEnterAName
                  : null,
              decoration: InputDecoration(
                hintText: L10N.of(context).tr.projectName,
              ),
            ),
            MaterialColorPicker(
              selectedColor: _colour,
              shrinkWrap: true,
              onColorChange: (Color colour) => _colour = colour,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Text(L10N.of(context).tr.cancel, style: TextStyle(color: Colors.white),),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: 10,),
                TextButton(
                  child: Text(widget.project == null
                      ? L10N.of(context).tr.create
                      : L10N.of(context).tr.save, style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    bool valid = _formKey.currentState!.validate();
                    if (!valid) return;

                    final ProjectsBloc projects =
                        BlocProvider.of<ProjectsBloc>(context);
                    if (widget.project == null) {
                      projects.add(CreateProject(
                          _nameController!.text.trim(), _colour!));
                    } else {
                      Project p = Project.clone(widget.project!,
                          name: _nameController!.text.trim(), colour: _colour);
                      projects.add(EditProject(p));
                    }
                    Navigator.of(context).pop();
                  },
                )
              ],
            )
          ],
        ),
      ),
    ));
  }
}
