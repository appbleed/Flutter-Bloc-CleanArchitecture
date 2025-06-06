import '../index.dart';

class MissingCallingResponsive extends DartLintRule {
  const MissingCallingResponsive() : super(code: _code);

  static const _code = LintCode(
    name: 'missing_calling_responsive',
    problemMessage:
        'Dimensions must be called with the \'responsive()\' function.\nPlease add the \'responsive()\' function.',
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
                if (_notResponsive(element.expression.toString())) {
                  reporter.atNode(element.expression, _code);
                }
              } else if (_notResponsive(element.toString())) {
                reporter.atNode(element, _code);
              }
            });
          },
          onVisitVariableDeclaration: (VariableDeclaration node) {
            if (node.initializer != null &&
                _notResponsive(node.initializer.toString())) {
              reporter.atNode(node.initializer!, _code);
            }
          },
          onVisitAssignmentExpression: (AssignmentExpression node) {
            if (_notResponsive(node.rightHandSide.toString())) {
              reporter.atNode(node.rightHandSide, _code);
            }
          },
          onVisitConstructorFieldInitializer:
              (ConstructorFieldInitializer node) {
            if (_notResponsive(node.expression.toString())) {
              reporter.atNode(node.expression, _code);
            }
          },
          onVisitSuperConstructorInvocation: (SuperConstructorInvocation node) {
            node.argumentList.arguments.forEach((element) {
              if (element is NamedExpression) {
                if (_notResponsive(element.expression.toString())) {
                  reporter.atNode(element.expression, _code);
                }
              } else if (_notResponsive(element.toString())) {
                reporter.atNode(element, _code);
              }
            });
          },
          onVisitConstructorDeclaration: (ConstructorDeclaration node) {
            node.parameters.parameterElements.forEach((element) {
              if (element?.defaultValueCode != null &&
                  _notResponsive(element!.defaultValueCode!)) {
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
                if (_notResponsive(element.expression.toString())) {
                  reporter.atNode(element.expression, _code);
                }
              } else if (_notResponsive(element.toString())) {
                reporter.atNode(element, _code);
              }
            });
          },
        )));
  }

  bool _notResponsive(String value) {
    return value.startsWith('Dimens.d') && !value.contains('responsive(');
  }

  @override
  List<Fix> getFixes() => [
        AddResponsiveFunction(),
      ];
}

class AddResponsiveFunction extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final changeBuilder = reporter.createChangeBuilder(
      message: 'Add .responsive()',
      priority: 75,
    );

    changeBuilder.addDartFileEdit((builder) {
      builder.addSimpleInsertion(
          analysisError.sourceRange.end, '.responsive()');
    });
  }
}
