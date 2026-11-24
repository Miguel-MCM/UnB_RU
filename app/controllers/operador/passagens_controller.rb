module Operador
  # Confirmação da passagem pela catraca, que faz o papel do sensor
  # (<tt>POST /operador/acessos/:acesso_id/passagem</tt>).
  class PassagensController < BaseController
    # POST /operador/acessos/:acesso_id/passagem: confirma que o estudante
    # passou e debita a refeição.
    #
    # Argumentos:: <tt>params[:acesso_id]</tt>: leitura feita pelo próprio operador.
    # Retorno:: redireciona para o terminal com o resultado (<tt>?acesso=</tt>),
    #           tenha a passagem sido confirmada ou recusada; responde 404 quando
    #           a leitura não existe ou é de outro operador.
    # Efeitos colaterais:: chama Acesso#confirmar_passagem!, que debita o saldo e
    #                      confirma o acesso, ou grava o motivo da recusa.
    def create
      acesso = current_funcionario.acessos.find(params[:acesso_id])
      acesso.confirmar_passagem!

      redirect_to operador_terminal_path(acesso:)
    end
  end
end
