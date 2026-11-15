module Autenticavel
  extend ActiveSupport::Concern

  class_methods do
    def autenticar(matricula, password)
      registro = find_by(matricula: matricula.to_s.strip)
      registro if registro && ActiveSupport::SecurityUtils.secure_compare(registro.password, password.to_s)
    end
  end
end
