class ExtratoPdf
  CABECALHO = [ "Data e hora", "Refeição / Evento", "Método", "Valor" ].freeze

  def initialize(extrato, user)
    @extrato = extrato
    @user = user
  end

  def render
    Prawn::Document.new(page_size: "A4", margin: 40, info: { Title: "Extrato e Histórico de Refeições" }) do |pdf|
      cabecalho(pdf)
      indicadores(pdf)
      lancamentos(pdf)
    end.render
  end

  private
    def reais(centavos)
      ActiveSupport::NumberHelper.number_to_currency(centavos / 100.0)
    end

    def cabecalho(pdf)
      pdf.text "RU UnB Digital · Portal do Estudante", size: 9, style: :bold, color: "1351B4"
      pdf.text "Extrato e Histórico de Refeições", size: 18, style: :bold
      pdf.text "#{@user.nome} · Matrícula #{@user.matricula}", size: 11
      pdf.text "Período: #{@extrato.rotulo_do_periodo} · Tipo: #{@extrato.rotulo_do_tipo}", size: 9, color: "5B5D66"
      pdf.text "Emitido em #{I18n.l(Time.current, format: "%d/%m/%Y %H:%M")}", size: 9, color: "5B5D66"
      pdf.move_down 16
    end

    def indicadores(pdf)
      pdf.text "Total gasto no mês: #{reais(@extrato.total_gasto_no_mes)} (#{@extrato.debitos_no_mes} débitos)", size: 10
      pdf.text "Total recarregado no mês: #{reais(@extrato.total_recarregado_no_mes)} · " \
               "Saldo restante: #{reais(@user.saldo_centavos)}", size: 10
      pdf.move_down 16
    end

    def lancamentos(pdf)
      lancamentos = @extrato.lancamentos
      return pdf.text("Nenhum lançamento encontrado para os filtros selecionados.", size: 10) if lancamentos.empty?

      linhas = lancamentos.map do |lancamento|
        [ I18n.l(lancamento.momento, format: "%d/%m/%Y %H:%M"), lancamento.descricao, lancamento.metodo, lancamento.valor_formatado ]
      end

      pdf.table([ CABECALHO, *linhas ], header: true, width: pdf.bounds.width,
                cell_style: { size: 9, borders: [ :bottom ], border_color: "EFE9E7", padding: [ 6, 8 ] }) do
        row(0).font_style = :bold
        row(0).background_color = "F3F0EF"
        column(3).align = :right
      end
    end
end
