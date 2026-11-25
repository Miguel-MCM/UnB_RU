# Controlador responsável pela tela e confirmação de recarga de saldo do estudante.
class RecargasController < ApplicationController
  before_action :require_login

  # Prepara os dados de seleção de pacote, método de pagamento e tarifa vigente para a view.
  #
  # Argumentos:: nenhum (lê +params[:quantidade]+ e +params[:metodo]+ da requisição).
  # Retorno:: +nil+ (renderiza a view +recargas/show+).
  # Efeitos colaterais:: define +@quantidade+, +@metodo+ e +@tarifa+ para a view;
  #                      redireciona para o login se o estudante não estiver autenticado.
  def show
    quantidade = params[:quantidade].to_i
    @quantidade = quantidade if quantidade.positive?
    @metodo = params[:metodo].presence_in(Recarga::METODOS_PAGAMENTO.keys) || "pix"
    @tarifa = Tarifa.vigente_centavos
  end

  # Efetua a recarga de créditos na conta do estudante autenticado.
  #
  # Argumentos:: nenhum (lê +params[:quantidade]+ e +params[:metodo]+ da requisição).
  # Retorno:: redirecionamento HTTP para +recarga_path+.
  # Efeitos colaterais:: cria um registro de +Recarga+ e incrementa o saldo do usuário no banco
  #                      em caso de sucesso; redireciona para +recarga_path+ com +notice+ de confirmação
  #                      ou com +alert+ de erro quando os parâmetros são inválidos.
  def create
    current_user.recarregar!(quantidade: params[:quantidade], metodo_pagamento: params[:metodo])

    redirect_to recarga_path, notice: mensagem_confirmacao
  rescue ActiveRecord::RecordInvalid
    redirect_to recarga_path, alert: "Não foi possível confirmar a recarga. Escolha a quantidade e o método de pagamento."
  end

  private
    # Monta a mensagem de sucesso com o novo saldo formatado em refeições e reais.
    #
    # Argumentos:: nenhum.
    # Retorno:: +String+ com a mensagem de confirmação da recarga.
    # Efeitos colaterais:: nenhum.
    def mensagem_confirmacao
      "Recarga confirmada! Novo saldo: #{helpers.saldo_em_refeicoes(current_user.saldo_centavos)}."
    end
end
