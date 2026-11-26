# Helpers da tela do cardápio da refeição atual.
module MenusHelper
  # Rótulo (selo) e texto de cada opção de prato, por refeição. O café da manhã
  # chama as opções de "complemento"; almoço e jantar, de "opção".
  PRATOS = {
    "cafe_da_manha" => [
      [ "Padrão", "Complemento padrão", :standard_dish ],
      [ "Ovolactovegetariano", "Complemento ovolactovegetariano", :ovolacto_dish ],
      [ "Vegetariano Estrito", "Complemento vegetariano estrito", :vegan_dish ]
    ],
    "almoco" => [
      [ "Padrão", "Opção padrão", :standard_dish ],
      [ "Ovolactovegetariana", "Opção ovolactovegetariana", :ovolacto_dish ],
      [ "Vegetariana Estrita", "Opção vegetariana estrita", :vegan_dish ]
    ],
    "jantar" => [
      [ "Padrão", "Opção padrão", :standard_dish ],
      [ "Ovolactovegetariana", "Opção ovolactovegetariana", :ovolacto_dish ],
      [ "Vegetariana Estrita", "Opção vegetariana estrita", :vegan_dish ]
    ]
  }.freeze

  # Pratos principais do cardápio, um por modalidade.
  #
  # Argumentos:: +tipo+ (String): refeição (<tt>cafe_da_manha</tt>, <tt>almoco</tt> ou <tt>jantar</tt>)
  #              e +menu+ (Menu).
  # Retorno:: Array de <tt>[selo, "Opção padrão: Frango"]</tt>.
  # Efeitos colaterais:: nenhum.
  def pratos_do_cardapio(tipo, menu)
    PRATOS.fetch(tipo).map { |selo, rotulo, campo| [ selo, "#{rotulo}: #{menu.public_send(campo)}" ] }
  end

  # Segundo bloco do cardápio (guarnições do almoço, sopa do jantar).
  #
  # Argumentos:: +tipo+ (String) e +menu+ (Menu).
  # Retorno:: <tt>[título, linhas]</tt>; +nil+ no café da manhã, que não tem segundo bloco.
  # Efeitos colaterais:: nenhum.
  def complementos_do_cardapio(tipo, menu)
    case tipo
    when "almoco"
      [ "Guarnição e Acompanhamentos",
        [ "Saladas: #{menu.salads}", "Guarnição: #{menu.garnish}", "Acompanhamentos: #{menu.side_dishes}",
          "Sobremesa: #{menu.dessert}", "Bebida: #{menu.beverage}" ] ]
    when "jantar"
      [ "Sopa e Acompanhamentos", [ "Sopa: #{menu.soup}", ("Acompanha: Torrada" if menu.has_toast) ].compact ]
    end
  end
end
