# Helpers de geração do payload PIX simulado e do respectivo QR Code SVG na recarga.
module RecargasHelper
  # Chave PIX institucional fictícia utilizada no código simulado.
  CHAVE_PIX = "ru-recarga-darcy@unb.br"

  # Monta o código PIX (copia e cola) no padrão EMV para o valor informado.
  # O pagamento é simulado: o CRC do código (campo 63) é inválido de propósito,
  # para que nenhum app de banco aceite pagar este PIX.
  #
  # Argumentos::
  #   +valor_centavos+:: (+Integer+) valor total da recarga em centavos.
  # Retorno:: +String+ com o payload PIX formatado no padrão EMV + CRC simulado.
  # Efeitos colaterais:: nenhum.
  def codigo_pix(valor_centavos)
    campos_pix(valor_centavos).map { |id, valor| campo_emv(id, valor) }.join + "6304SIMU"
  end

  # Gera a representação em SVG do QR Code correspondente ao código PIX informado.
  #
  # Argumentos::
  #   +codigo+:: (+String+) payload PIX gerado por +codigo_pix+.
  # Retorno:: +ActiveSupport::SafeBuffer+ contendo o markup SVG pronto para renderização HTML.
  # Efeitos colaterais:: nenhum.
  def qr_code_pix(codigo)
    RQRCode::QRCode.new(codigo).as_svg(
      viewbox: true, use_path: true, color: "003a8c",
      svg_attributes: { class: "pix__qr", role: "img", "aria-label": "QR Code PIX" }
    ).html_safe
  end

  private
    # Formata um campo TLV (Tag-Length-Value) no padrão EMV do PIX.
    #
    # Argumentos::
    #   +id+:: (+String+) identificador numérico de dois dígitos do campo EMV.
    #   +valor+:: (+String+) conteúdo do campo.
    # Retorno:: +String+ no formato +<id><tamanho_2_digitos><valor>+.
    # Efeitos colaterais:: nenhum.
    def campo_emv(id, valor)
      "#{id}#{valor.length.to_s.rjust(2, "0")}#{valor}"
    end

    # Monta o dicionário ordenado dos campos EMV que compõem o código PIX simulado.
    #
    # Argumentos::
    #   +valor_centavos+:: (+Integer+) valor da recarga em centavos.
    # Retorno:: +Hash{String => String}+ mapeando cada tag EMV ao seu valor.
    # Efeitos colaterais:: nenhum.
    def campos_pix(valor_centavos)
      {
        "00" => "01",
        "26" => campo_emv("00", "br.gov.bcb.pix") + campo_emv("01", CHAVE_PIX),
        "52" => "0000",
        "53" => "986",
        "54" => format("%d.%02d", *valor_centavos.divmod(100)),
        "58" => "BR",
        "59" => "RU UnB Digital",
        "60" => "Brasilia"
      }
    end
end
