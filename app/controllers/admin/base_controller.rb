module Admin
  class BaseController < Operador::BaseController
    before_action :require_administrador
  end
end
