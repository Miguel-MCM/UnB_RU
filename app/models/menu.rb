# Representa o cardápio de uma refeição servida em uma data específica do RU.
class Menu < ApplicationRecord
  # Tipos de refeição suportados pelo sistema.
  MEAL_TYPES = %w[cafe_da_manha almoco jantar].freeze

  # Faixas de horário (em minutos a partir da meia-noite) de cada refeição.
  MEAL_WINDOWS = {
    "cafe_da_manha" => (7 * 60)..((9 * 60) + 30),
    "almoco" => (11 * 60)..((14 * 60) + 30),
    "jantar" => (17 * 60)..((19 * 60) + 30)
  }.freeze

  # Rótulos legíveis em português para exibição dos tipos de refeição.
  MEAL_LABELS = {
    "cafe_da_manha" => "café da manhã",
    "almoco" => "almoço",
    "jantar" => "jantar"
  }.freeze

  # Arquivo com o cardápio da semana, por dia (<tt>segunda-feira</tt>, ...) e refeição.
  ARQUIVO_CARDAPIO = Rails.root.join("cardapio.json")

  # Nome do dia no arquivo, indexado por +Date#wday+ (domingo = 0).
  DIAS_DA_SEMANA = %w[domingo segunda-feira terca-feira quarta-feira quinta-feira sexta-feira sabado].freeze

  validates :served_on, :meal_type, :standard_dish, :ovolacto_dish, :vegan_dish, presence: true
  validates :meal_type, inclusion: { in: MEAL_TYPES }

  # Determina qual tipo de refeição está sendo servido no instante informado.
  #
  # Argumentos::
  #   +time+:: (+Time+, padrão +Time.current+) instante de referência para verificar a faixa horária.
  # Retorno:: +String+ com o identificador do turno (+cafe_da_manha+, +almoco+ ou +jantar+)
  #           ou +nil+ quando o horário está fora do funcionamento das refeições.
  # Efeitos colaterais:: nenhum.
  def self.current_meal_type(time = Time.current)
    minutes = (time.hour * 60) + time.min
    MEAL_WINDOWS.find { |_type, range| range.cover?(minutes) }&.first
  end

  # Traduz o identificador interno do tipo de refeição para o rótulo em português.
  #
  # Argumentos::
  #   +meal_type+:: (+String+) identificador do turno (+cafe_da_manha+, +almoco+ ou +jantar+).
  # Retorno:: +String+ com o nome legível do turno ou +nil+ se o tipo for desconhecido.
  # Efeitos colaterais:: nenhum.
  def self.meal_label(meal_type)
    MEAL_LABELS[meal_type]
  end

  # Cardápio de uma refeição em uma data. Quando não há registro e a geração
  # automática está ligada (<tt>config.x.cardapio.gerar_do_json</tt>), cria o
  # cardápio da data a partir de ARQUIVO_CARDAPIO.
  #
  # Argumentos:: +data+ (Date) e +tipo+ (String): um de MEAL_TYPES.
  # Retorno:: o Menu, ou +nil+ quando não existe e não pôde ser gerado.
  # Efeitos colaterais:: com a geração ligada, pode gravar os cardápios do dia
  #                      (ver .gerar_do_json!).
  def self.do_dia(data, tipo)
    find_by(served_on: data, meal_type: tipo) ||
      (find_by(served_on: data, meal_type: tipo) if gerar_do_json?(data))
  end

  # Cria os cardápios dos próximos dias a partir do arquivo da semana. Não
  # altera cardápios que já existem (edições feitas no banco são preservadas).
  #
  # Argumentos:: +a_partir_de+ (Date, padrão hoje), +dias+ (Integer, padrão 7) e
  #              +arquivo+ (Pathname, padrão ARQUIVO_CARDAPIO).
  # Retorno:: quantidade de cardápios criados.
  # Efeitos colaterais:: grava um Menu por refeição ainda sem cardápio na data.
  #                      Arquivo ausente ou dia sem refeições não criam nada.
  def self.gerar_do_json!(a_partir_de = Date.current, dias: 7, arquivo: ARQUIVO_CARDAPIO)
    return 0 unless File.exist?(arquivo)

    semana = JSON.parse(File.read(arquivo))
    (a_partir_de...(a_partir_de + dias)).sum do |data|
      (semana[DIAS_DA_SEMANA[data.wday]] || {}).slice(*MEAL_TYPES).count do |tipo, refeicao|
        criar_do_json(data, tipo, refeicao)
      end
    end
  end

  # Indica se a geração automática está ligada e gera o cardápio da data.
  #
  # Argumentos:: +data+ (Date).
  # Retorno:: +true+ quando a geração está ligada, +false+ caso contrário.
  # Efeitos colaterais:: com a geração ligada, chama .gerar_do_json! para o dia.
  def self.gerar_do_json?(data)
    return false unless Rails.configuration.x.cardapio.gerar_do_json

    gerar_do_json!(data, dias: 1)
    true
  end
  private_class_method :gerar_do_json?

  # Cria o cardápio de uma refeição, se ainda não existir.
  #
  # Argumentos:: +data+ (Date), +tipo+ (String) e +refeicao+ (Hash do arquivo).
  # Retorno:: +true+ quando criou; +false+ quando já existia.
  # Efeitos colaterais:: grava um Menu.
  def self.criar_do_json(data, tipo, refeicao)
    menu = find_or_create_by!(served_on: data, meal_type: tipo) { |novo| novo.assign_attributes(atributos_do_json(tipo, refeicao)) }
    menu.previously_new_record?
  end
  private_class_method :criar_do_json

  # Converte uma refeição do arquivo nos campos do Menu.
  #
  # Argumentos:: +tipo+ (String) e +refeicao+ (Hash).
  # Retorno:: Hash de atributos. O café da manhã usa os "complementos"; almoço e
  #           jantar, os pratos principais, as saladas, a sopa e a torrada.
  # Efeitos colaterais:: nenhum.
  def self.atributos_do_json(tipo, refeicao)
    if tipo == "cafe_da_manha"
      { standard_dish: refeicao["complemento_padrao"], ovolacto_dish: refeicao["complemento_ovolactovegetariano"],
        vegan_dish: refeicao["complemento_vegetariano_estrito"], extra_option: refeicao["opcao_extra"] }
    else
      { standard_dish: refeicao["prato_principal_padrao"], ovolacto_dish: refeicao["prato_principal_ovolactovegetariano"],
        vegan_dish: refeicao["prato_principal_vegetariano_estrito"], salads: listar(refeicao.values_at("salada_1", "salada_2")),
        garnish: refeicao["guarnicao"], side_dishes: listar(refeicao["acompanhamentos"]), dessert: refeicao["sobremesa"],
        beverage: refeicao["bebida"], soup: refeicao["sopa"], has_toast: refeicao["torrada"].present? }
    end
  end
  private_class_method :atributos_do_json

  # Junta itens em texto corrido ("a, b e c").
  #
  # Argumentos:: +itens+ (Array ou +nil+).
  # Retorno:: String, ou +nil+ quando não há itens.
  # Efeitos colaterais:: nenhum.
  def self.listar(itens)
    Array(itens).compact_blank.to_sentence(words_connector: ", ", two_words_connector: " e ", last_word_connector: " e ").presence
  end
  private_class_method :listar
end
