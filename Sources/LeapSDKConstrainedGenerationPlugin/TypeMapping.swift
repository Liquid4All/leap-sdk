import SwiftSyntax

// ADD a new return-type that carries the name of a custom type
indirect enum JSONKind {
  case primitive(String)  // "string", "number", …
  case array(JSONKind)  // element kind
  case custom(String)  // DayPlan, Activity, …
}

/// Returns true if `s` contains a `:` at bracket-depth 0 (i.e. not inside nested `[ ]` or `< >`).
/// Used to distinguish dictionary shorthand `[K: V]` from array shorthand `[T]`.
private func hasTopLevelColon(_ s: String) -> Bool {
  var depth = 0
  for ch in s {
    switch ch {
    case "[", "<": depth += 1
    case "]", ">": depth -= 1
    case ":" where depth == 0: return true
    default: break
    }
  }
  return false
}

func mapSwiftType(_ type: TypeSyntax) -> (JSONKind, isOptional: Bool) {
  let raw = type.description.trimmingCharacters(in: .whitespaces)

  // optionals ────────────────────────────────────────────────
  if raw.hasSuffix("?") {
    let inner = String(raw.dropLast())
    let (kind, _) = mapSwiftType(TypeSyntax(stringLiteral: inner))
    return (kind, true)
  }
  if raw.hasPrefix("Optional<"), raw.hasSuffix(">") {
    let inner = String(raw.dropFirst("Optional<".count).dropLast())
    let (kind, _) = mapSwiftType(TypeSyntax(stringLiteral: inner))
    return (kind, true)
  }

  // arrays / dictionaries ────────────────────────────────────
  // Dictionary shorthand [K: V] must be checked before the array branch because it also
  // starts with "[" and ends with "]". We detect a dictionary by looking for a colon at
  // bracket-depth 0 inside the brackets (so [[K: V]] is correctly classified as an array).
  if raw.hasPrefix("["), raw.hasSuffix("]") {
    let inner = String(raw.dropFirst().dropLast())
    if hasTopLevelColon(inner) {
      return (.primitive("object"), false)
    }
    let (elem, _) = mapSwiftType(TypeSyntax(stringLiteral: inner))
    return (.array(elem), false)
  }
  if raw.hasPrefix("Array<"), raw.hasSuffix(">") {
    let inner = String(raw.dropFirst("Array<".count).dropLast())
    let (elem, _) = mapSwiftType(TypeSyntax(stringLiteral: inner))
    return (.array(elem), false)
  }
  if raw.hasPrefix("Dictionary<"), raw.hasSuffix(">") {
    return (.primitive("object"), false)
  }

  // primitives ───────────────────────────────────────────────
  switch raw {
  case "String": return (.primitive("string"), false)
  case "Int", "Int8", "Int16",
    "Int32", "Int64",
    "UInt", "UInt8", "UInt16",
    "UInt32", "UInt64":
    return (.primitive("integer"), false)
  case "Float", "Double", "CGFloat": return (.primitive("number"), false)
  case "Bool": return (.primitive("boolean"), false)
  case "Date", "Data", "URL", "UUID": return (.primitive("string"), false)

  default:
    // *** NEW: everything else is assumed to be a nested @Generatable ***
    return (.custom(raw), false)
  }
}

