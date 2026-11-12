module Operador
  class BaseController < ApplicationController
    layout "operador"

    before_action :require_operador
  end
end
