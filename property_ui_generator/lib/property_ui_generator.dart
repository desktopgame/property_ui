import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator.dart';

Builder propertyUIBuilder(BuilderOptions options) =>
    LibraryBuilder(PropertyUIGenerator(), generatedExtension: ".ui.dart");
