ParameterType(
  name: "reais",
  regexp: /R\$ \d{1,3}(?:\.\d{3})*,\d{2}/,
  type: Integer,
  transformer: ->(valor) { valor.delete("^0-9").to_i }
)
