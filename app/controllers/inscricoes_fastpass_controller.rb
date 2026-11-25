# Controlador responsável por registrar a inscrição do estudante autenticado
# em um time-frame do sorteio do FastPass.
class InscricoesFastpassController < ApplicationController
  before_action :require_login

  # Processa a solicitação de inscrição no time-frame escolhido pelo estudante
  # e redireciona para a tela do FastPass com a mensagem de confirmação ou erro.
  #
  # Argumentos:: nenhum (lê +params[:time_frame_id]+ e usa +current_user+).
  # Retorno:: corpo da resposta de redirecionamento HTTP gerado por +redirect_to+.
  # Efeitos colaterais:: busca o +TimeFrame+ (pode lançar
  #                      +ActiveRecord::RecordNotFound+), persiste
  #                      +InscricaoFastpass+ e eventualmente +Sorteio+ no banco
  #                      em caso de sucesso, define flash (+notice+ ou +alert+) e
  #                      redireciona para +fastpass_path+.
  def create
    time_frame = TimeFrame.find(params.expect(:time_frame_id))
    inscricao = InscricaoFastpass.inscrever!(user: current_user, time_frame:)

    redirect_to fastpass_path, **flash_da_inscricao(inscricao, time_frame)
  end

  private
    # Monta o hash de mensagem flash correspondente ao resultado da inscrição.
    #
    # Argumentos:: +inscricao+ (InscricaoFastpass) resultante e +time_frame+
    #              (TimeFrame) escolhido.
    # Retorno:: +Hash+ com chave +:notice+ quando a inscrição foi persistida, ou
    #           com chave +:alert+ contendo os erros quando recusada.
    # Efeitos colaterais:: nenhum.
    def flash_da_inscricao(inscricao, time_frame)
      if inscricao.persisted?
        { notice: "Inscrição realizada no time-frame das #{time_frame.horario} do #{time_frame.turno.nome}." }
      else
        { alert: inscricao.errors.full_messages.to_sentence }
      end
    end
end
