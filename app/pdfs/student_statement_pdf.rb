require "prawn"
require "prawn/table"

class StudentStatementPdf
  def initialize(user:, recargas:, acessos:, total_gasto_centavos:, total_recarregado_centavos:, filtro_periodo: nil, filtro_refeicao: nil)
    @user = user
    @recargas = recargas
    @acessos = acessos
    @total_gasto_centavos = total_gasto_centavos
    @total_recarregado_centavos = total_recarregado_centavos
    @filtro_periodo = filtro_periodo
    @filtro_refeicao = filtro_refeicao
  end

  def render
    Prawn::Document.new do |pdf|
      pdf.text "Extrato e Histórico do Estudante - RU UnB Digital", size: 16, style: :bold
      pdf.move_down 6
      pdf.text "Estudante: #{@user.nome} | Matrícula: #{@user.matricula}", size: 11
      pdf.text "Período: #{@filtro_periodo.presence || 'Período atual'} | Refeição: #{@filtro_refeicao.presence || 'Todas'}", size: 10
      pdf.move_down 12

      pdf.text "Resumo do Período", size: 13, style: :bold
      pdf.move_down 4
      pdf.text "Total Gasto: #{format_currency(@total_gasto_centavos)}"
      pdf.text "Total Recarregado: #{format_currency(@total_recarregado_centavos)}"
      pdf.text "Saldo Restante: #{format_currency(@user.saldo_centavos)}"
      pdf.move_down 14

      if @recargas.any?
        pdf.text "Recargas Realizadas", size: 13, style: :bold
        pdf.move_down 6
        recarga_rows = [ [ "Tipo", "Matrícula", "Método", "Quantidade", "Valor", "Data" ] ]
        @recargas.each do |recarga|
          recarga_rows << [
            "Recarga de Saldo",
            @user.matricula,
            Recarga::METODOS_PAGAMENTO[recarga.metodo_pagamento] || recarga.metodo_pagamento,
            "#{recarga.quantidade} refeições",
            format_currency(recarga.valor_centavos),
            recarga.created_at.strftime("%d/%m/%Y %H:%M")
          ]
        end
        pdf.table(recarga_rows, header: true, width: pdf.bounds.width)
        pdf.move_down 14
      end

      if @acessos.any?
        pdf.text "Refeições Realizadas", size: 13, style: :bold
        pdf.move_down 6
        acesso_rows = [ [ "Tipo", "Matrícula", "Turno", "Valor Debitado", "Data/Hora" ] ]
        @acessos.each do |acesso|
          acesso_rows << [
            "Refeição Realizada",
            acesso.identificacao,
            meal_type_label(acesso.created_at),
            format_currency(acesso.valor_centavos),
            acesso.created_at.strftime("%d/%m/%Y %H:%M")
          ]
        end
        pdf.table(acesso_rows, header: true, width: pdf.bounds.width)
      end
    end.render
  end

  private
    def format_currency(centavos)
      reais = centavos.to_i / 100.0
      "R$ #{format('%.2f', reais).tr('.', ',')}"
    end

    def meal_type_label(timestamp)
      hour = timestamp.hour
      if hour < 10
        "Café da Manhã"
      elsif hour < 15
        "Almoço"
      else
        "Jantar"
      end
    end
end
