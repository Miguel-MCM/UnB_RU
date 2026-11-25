module Admin
  # Controlador administrativo responsável por dividir ou redividir um turno
  # de refeição em time-frames do FastPass.
  class TimeFramesController < BaseController
    # Aplica a nova duração de time-frame ao turno informado e redireciona de
    # volta para a listagem de turnos do restaurante com aviso de sucesso ou erro.
    #
    # Argumentos:: nenhum (lê +params[:turno_id]+ e
    #              +params[:duracao_time_frame_min]+).
    # Retorno:: corpo da resposta de redirecionamento HTTP gerado por +redirect_to+.
    # Efeitos colaterais:: busca o +Turno+ (pode lançar
    #                      +ActiveRecord::RecordNotFound+), recria seus
    #                      +TimeFrame+ no banco quando válido, define flash
    #                      (+notice+ ou +alert+) e redireciona para
    #                      +admin_restaurante_turnos_path+.
    def create
      turno = Turno.find(params[:turno_id])
      atualizado = turno.dividir_em_time_frames!(params.expect(:duracao_time_frame_min))

      redirect_to admin_restaurante_turnos_path(turno.restaurante), **flash_da_divisao(turno, atualizado)
    end

    private
      # Monta o hash de mensagem flash conforme o resultado da divisão do turno.
      #
      # Argumentos:: +turno+ (Turno) alvo e +atualizado+ (Boolean) indicando se
      #              a divisão foi aplicada.
      # Retorno:: +Hash+ com +:notice+ quando +atualizado+ é verdadeiro, ou com
      #           +:alert+ listando os erros do turno caso contrário.
      # Efeitos colaterais:: nenhum.
      def flash_da_divisao(turno, atualizado)
        return { notice: "Time-frames atualizados." } if atualizado

        { alert: "Não foi possível dividir o turno: #{turno.errors.full_messages.to_sentence}." }
      end
  end
end
