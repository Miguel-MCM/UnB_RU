# Área administrativa do sistema, restrita a funcionários administradores.
module Admin
  # Controlador administrativo para listagem e cadastro de turnos de refeição
  # vinculados a um restaurante.
  class TurnosController < BaseController
    before_action :set_restaurante

    # Lista os turnos do restaurante com seus time-frames e prepara um novo
    # turno para o formulário de cadastro.
    #
    # Argumentos:: nenhum (usa +params[:restaurante_id]+ via +set_restaurante+).
    # Retorno:: nova instância de +Turno+ atribuída a +@turno+ (o Rails
    #           renderiza a view +admin/turnos/index+).
    # Efeitos colaterais:: consulta o banco de dados, popula +@restaurante+,
    #                      +@turnos+ e +@turno+ e renderiza a página HTML.
    def index
      carregar_turnos
      @turno = Turno.new
    end

    # Cadastra um novo turno para o restaurante; em caso de erro de validação,
    # reexibe a listagem com status HTTP 422 e mensagem de alerta.
    #
    # Argumentos:: nenhum (lê +params[:restaurante_id]+ e +params[:turno]+).
    # Retorno:: resposta HTTP gerada por +redirect_to+ (sucesso) ou +render+
    #           (falha de validação).
    # Efeitos colaterais:: insere um registro de +Turno+ no banco e redireciona
    #                      para +admin_restaurante_turnos_path+ com +notice+ no
    #                      sucesso; na falha, recarrega +@turnos+, define
    #                      +flash.now[:alert]+ e renderiza +:index+ com status
    #                      +:unprocessable_content+.
    def create
      @turno = Turno.new(restaurante: @restaurante, **turno_params)

      if @turno.save
        redirect_to admin_restaurante_turnos_path(@restaurante), notice: "Turno cadastrado."
      else
        carregar_turnos
        flash.now[:alert] = @turno.errors.full_messages.to_sentence
        render :index, status: :unprocessable_content
      end
    end

    private
      # Localiza o restaurante alvo a partir do parâmetro de rota.
      #
      # Argumentos:: nenhum (lê +params[:restaurante_id]+).
      # Retorno:: +Restaurante+ encontrado e atribuído a +@restaurante+; lança
      #           +ActiveRecord::RecordNotFound+ se o identificador não existir.
      # Efeitos colaterais:: consulta o banco de dados e popula +@restaurante+.
      def set_restaurante
        @restaurante = Restaurante.find(params[:restaurante_id])
      end

      # Carrega os turnos do restaurante atual com seus time-frames pré-carregados.
      #
      # Argumentos:: nenhum.
      # Retorno:: +ActiveRecord::Relation+ atribuída a +@turnos+.
      # Efeitos colaterais:: consulta o banco de dados e popula +@turnos+.
      def carregar_turnos
        @turnos = @restaurante.turnos.includes(:time_frames)
      end

      # Extrai e valida os parâmetros permitidos para criação de um turno.
      #
      # Argumentos:: nenhum (lê +params[:turno]+).
      # Retorno:: +ActionController::Parameters+ permitidos (+:nome+,
      #           +:hora_inicio+, +:hora_fim+); lança
      #           +ActionController::ParameterMissing+ se ausentes.
      # Efeitos colaterais:: nenhum.
      def turno_params
        params.expect(turno: [ :nome, :hora_inicio, :hora_fim ])
      end
  end
end
