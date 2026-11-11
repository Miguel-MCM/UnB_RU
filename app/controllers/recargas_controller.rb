class RecargasController < ApplicationController
  before_action :require_login

  def show
    quantidade = params[:quantidade].to_i
    @quantidade = quantidade if quantidade.positive?
    @metodo = params[:metodo].presence_in(Recarga::METODOS_PAGAMENTO.keys) || "pix"
  end

  def create
    current_user.recarregar!(quantidade: params[:quantidade], metodo_pagamento: params[:metodo])

    redirect_to recarga_path, notice: "Recarga confirmada! Novo saldo: #{helpers.saldo_em_refeicoes(current_user.saldo_centavos)}."
  rescue ActiveRecord::RecordInvalid
    redirect_to recarga_path, alert: "Não foi possível confirmar a recarga. Escolha a quantidade e o método de pagamento."
  end
end
