module RecargasHelper
  CHAVE_PIX = "ru-recarga-darcy@unb.br"

  # O pagamento é simulado: o CRC do código (campo 63) é inválido de propósito,
  # para que nenhum app de banco aceite pagar este PIX.
  def codigo_pix(valor_centavos)
    campo = ->(id, valor) { "#{id}#{valor.length.to_s.rjust(2, "0")}#{valor}" }

    [
      campo.("00", "01"),
      campo.("26", campo.("00", "br.gov.bcb.pix") + campo.("01", CHAVE_PIX)),
      campo.("52", "0000"),
      campo.("53", "986"),
      campo.("54", format("%d.%02d", *valor_centavos.divmod(100))),
      campo.("58", "BR"),
      campo.("59", "RU UnB Digital"),
      campo.("60", "Brasilia"),
      "6304SIMU"
    ].join
  end

  def qr_code_pix(codigo)
    RQRCode::QRCode.new(codigo).as_svg(
      viewbox: true, use_path: true, color: "003a8c",
      svg_attributes: { class: "pix__qr", role: "img", "aria-label": "QR Code PIX" }
    ).html_safe
  end
end
