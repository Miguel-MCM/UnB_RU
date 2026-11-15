class AccessReportsController < ApplicationController
  before_action :require_operador
  before_action :require_administrador

  def index
    load_report_data
  end

  private
    def load_report_data
      @restaurantes = Restaurante.ordenados
      @catracas = Catraca.order(:nome)
      @acessos = Acesso.includes(:restaurante, :catraca, :user).order(created_at: :desc)

      if params[:restaurante_nome].present?
        @restaurante = Restaurante.find_by(nome: params[:restaurante_nome])
        @acessos = @restaurante ? @acessos.where(restaurante_id: @restaurante.id) : Acesso.none
      end

      if params[:catraca_nome].present?
        if @restaurante.present?
          @catraca = @restaurante.catracas.find_by(nome: params[:catraca_nome])
          if @catraca.nil? && Catraca.exists?(nome: params[:catraca_nome])
            @error_message = "A catraca #{params[:catraca_nome]} não pertence ao restaurante #{@restaurante.nome}"
            @acessos = Acesso.none
            return
          end
        else
          @catraca = Catraca.find_by(nome: params[:catraca_nome])
        end
        @acessos = @catraca ? @acessos.where(catraca_id: @catraca.id) : Acesso.none
      end

      @group_by = params[:group_by]
      if @group_by == "restaurante"
        @grouped_counts = @acessos.reorder(nil).joins(:restaurante).group("restaurantes.nome").count
      elsif @group_by == "catraca"
        @grouped_counts = @acessos.reorder(nil).joins(:catraca).group("catracas.nome").count
      end
    end
end
