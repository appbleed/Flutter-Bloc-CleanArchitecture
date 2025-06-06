import '../index.dart';

class AvoidHardCodedColors extends DartLintRule {
  const AvoidHardCodedColors() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_hard_coded_colors',
    problemMessage:
        'Avoid hard-coding colors, except for Colors.transparent, such as Color(0xFFFFFF) and Colors.white.\nPlease use \'AppColors\' instead',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    resolver.getResolvedUnitResult().then((value) =>
        value.unit.visitChildren(VariableAndArgumentVisitor(
          onVisitInstanceCreationExpression: (InstanceCreationExpression node) {
            node.argumentList.arguments.forEach((element) {
              if (element is NamedExpression) {
                if (_isHardCoded(element.expression.toString())) {
                  reporter.atNode(element.expression, _code);
                }
              } else if (_isHardCoded(element.toString())) {
                reporter.atNode(element, _code);
              }
            });
          },
          onVisitVariableDeclaration: (VariableDeclaration node) {
            if (node.initializer != null &&
                _isHardCoded(node.initializer.toString())) {
              reporter.atNode(node.initializer!, _code);
            }
          },
          onVisitAssignmentExpression: (AssignmentExpression node) {
            if (_isHardCoded(node.rightHandSide.toString())) {
              reporter.atNode(node.rightHandSide, _code);
            }
          },
          onVisitConstructorFieldInitializer:
              (ConstructorFieldInitializer node) {
            if (_isHardCoded(node.expression.toString())) {
              reporter.atNode(node.expression, _code);
            }
          },
          onVisitSuperConstructorInvocation: (SuperConstructorInvocation node) {
            node.argumentList.arguments.forEach((element) {
              if (element is NamedExpression) {
                if (_isHardCoded(element.expression.toString())) {
                  reporter.atNode(element.expression, _code);
                }
              } else if (_isHardCoded(element.toString())) {
                reporter.atNode(element, _code);
              }
            });
          },
          onVisitConstructorDeclaration: (ConstructorDeclaration node) {
            node.parameters.parameterElements.forEach((element) {
              if (element?.defaultValueCode != null &&
                  _isHardCoded(element!.defaultValueCode!)) {
                if (element is DefaultFieldFormalParameterElementImpl) {
                  reporter.atNode(element.constantInitializer!, _code);
                } else if (element is DefaultParameterElementImpl) {
                  reporter.atNode(element.constantInitializer!, _code);
                } else {
                  reporter.atNode(node, _code);
                }
              }
            });
          },
          onVisitArgumentList: (node) {
            node.arguments.forEach((element) {
              if (element is NamedExpression) {
                if (_isHardCoded(element.expression.toString())) {
                  reporter.atNode(element.expression, _code);
                }
              } else if (_isHardCoded(element.toString())) {
                reporter.atNode(element, _code);
              }
            });
          },
        )));
  }

  bool _isHardCoded(String color) {
    if (color == 'Colors.transparent') {
      return false;
    }

    if (color.replaceAll(' ', '').startsWith('Color(') ||
        color.replaceAll(' ', '').startsWith('Colors.') ||
        color.replaceAll(' ', '').startsWith('Color.')) {
      return true;
    }

    return false;
  }
}
