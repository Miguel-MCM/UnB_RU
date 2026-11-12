class MenusController < ApplicationController
  before_action :require_authentication

  def current
    @current_meal_type = Menu.current_meal_type(Time.current)
    return if @current_meal_type.nil?

    @meal_label = Menu.meal_label(@current_meal_type)
    @menu = Menu.find_by(served_on: Date.current, meal_type: @current_meal_type)
  end
end