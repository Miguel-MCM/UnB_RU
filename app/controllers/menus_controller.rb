# Controlador responsável pela exibição do cardápio da refeição em andamento para o estudante.
class MenusController < ApplicationController
  before_action :require_login

  # Carrega o turno da refeição atual e o respectivo cardápio do dia para exibição.
  #
  # Argumentos:: nenhum (utiliza o horário e a data correntes).
  # Retorno:: +nil+ (renderiza a view +menus/current+).
  # Efeitos colaterais:: define +@current_meal_type+, +@meal_label+ e +@menu+ para a view;
  #                      redireciona para o login se o estudante não estiver autenticado.
  def current
    @current_meal_type = Menu.current_meal_type(Time.current)
    return if @current_meal_type.nil?

    @meal_label = Menu.meal_label(@current_meal_type)
    @menu = Menu.find_by(served_on: Date.current, meal_type: @current_meal_type)
  end
end
