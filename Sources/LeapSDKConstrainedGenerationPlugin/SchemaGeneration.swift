import SwiftSyntax
import SwiftSyntaxMacros

func generateJSONSchemaLazy(
  for declaration: some DeclGroupSyntax,
  typeName: String,
  description: String
) throws -> String {

  var propertySnippets: [String] = []
  var required: [String] = []

  for member in declaration.memberBlock.members {
    guard
      let varDecl = member.decl.as(VariableDeclSyntax.self),
      let binding = varDecl.bindings.first,
      binding.accessorBlock == nil,  // stored only
      !varDecl.modifiers.contains(where: { $0.name.text == "static" }),
      let ident = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
      let type = binding.typeAnnotation?.type
    else { continue }

    let name = ident.text
    let (kind, isOpt) = mapSwiftType(type)

    // -------- format one property snippet ------------
    let snippet: String

    switch kind {

    case .primitive(let json):
      snippet = """
        "\(jsonEscape(name))": { "type": "\(json)"\(guide(varDecl)) }
        """

    case .array(let elem):
      switch elem {
      case .primitive(let json):
        snippet = """
          "\(jsonEscape(name))": {
            "type": "array",
            "items": { "type": "\(json)" }\(guide(varDecl))
          }
          """

      case .custom(let elemName):
        snippet = """
          "\(jsonEscape(name))": {
            "type": "array",
            "items": \\(\(elemName).jsonSchema())\(guide(varDecl))
          }
          """

      case .array:  // nested-array edge-cases
        snippet = """
          "\(jsonEscape(name))": { "type": "array" }
          """
      }

    case .custom(let other):
      // Wrap the custom schema in an allOf to allow adding a field-level description.
      if let guideText = extractGuideDescription(from: varDecl) {
        snippet = """
          "\(jsonEscape(name))": { "description": "\(jsonEscape(guideText))", "allOf": [\\(\(other).jsonSchema())] }
          """
      } else {
        snippet = """
          "\(jsonEscape(name))": \\(\(other).jsonSchema())
          """
      }
    }

    propertySnippets.append(snippet)
    if !isOpt { required.append("\"\(jsonEscape(name))\"") }
  }

  // join everything
  let propertiesBlock = propertySnippets.joined(separator: ",\n")
  let requiredBlock = required.joined(separator: ", ")

  return #"""
    """
    {
      "type": "object",
      "title": "\#(jsonEscape(typeName))",
      "description": "\#(jsonEscape(description))",
      "properties": {
        \#(propertiesBlock)
      },
      "required": [\#(requiredBlock)]
    }
    """
    """#
}

// helper for optional @Guide text — always emits a leading comma since description
// is always an additional property inside an existing JSON object.
private func guide(_ decl: VariableDeclSyntax) -> String {
  guard let text = extractGuideDescription(from: decl) else { return "" }
  return ", \"description\": \"\(jsonEscape(text))\""
}

/// Escapes a string for safe embedding inside a JSON string literal.
private func jsonEscape(_ text: String) -> String {
  var result = ""
  for ch in text {
    switch ch {
    case "\"": result += "\\\""
    case "\\": result += "\\\\"
    case "\n": result += "\\n"
    case "\r": result += "\\r"
    case "\t": result += "\\t"
    default: result.append(ch)
    }
  }
  return result
}

// Helper to extract Guide description from variable declaration
func extractGuideDescription(from varDecl: VariableDeclSyntax) -> String? {
  for attribute in varDecl.attributes {
    guard let attrSyntax = attribute.as(AttributeSyntax.self),
      attrSyntax.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Guide"
    else {
      continue
    }

    if let argument = attrSyntax.arguments?.as(LabeledExprListSyntax.self),
      let expr = argument.first?.expression,
      let stringLiteral = expr.as(StringLiteralExprSyntax.self),
      let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
    {
      return segment.content.text
    }
  }

  return nil
}
