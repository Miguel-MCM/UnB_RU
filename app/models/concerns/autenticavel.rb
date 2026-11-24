# Login por matrícula e senha, compartilhado por User (estudante) e
# Funcionario (operador e administrador). O model que inclui o concern precisa
# ter as colunas +matricula+ e +password+.
module Autenticavel
  extend ActiveSupport::Concern

  class_methods do
    # Procura o registro pela matrícula e confere a senha.
    #
    # Argumentos::
    #   +matricula+ (String ou +nil+):: matrícula digitada; espaços nas pontas são ignorados.
    #   +password+ (String ou +nil+):: senha digitada.
    # Retorno:: o registro quando a matrícula existe e a senha confere; +nil+
    #           quando a matrícula não existe, a senha está errada ou algum
    #           dos dois vem vazio.
    # Efeitos colaterais:: nenhum. A senha é comparada em tempo constante
    #                      (+secure_compare+).
    def autenticar(matricula, password)
      registro = find_by(matricula: matricula.to_s.strip)
      registro if registro && ActiveSupport::SecurityUtils.secure_compare(registro.password, password.to_s)
    end
  end
end
