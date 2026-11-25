# Área administrativa (restaurantes, catracas, turnos e janelas de horário), restrita a
# funcionários administradores.
module Admin
  # Base da área administrativa: herda a autenticação de funcionário do terminal
  # (+Operador::BaseController+) e restringe tudo a administradores.
  #
  # Quem não é administrador é redirecionado para o terminal com o alerta
  # "Área restrita a administradores." (ver Authentication#require_administrador).
  class BaseController < Operador::BaseController
    before_action :require_administrador
  end
end
