require "rails_helper"

RSpec.describe RelatorioAcessos, type: :model do
  let(:admin) { Funcionario.create!(nome: "Admin RU", matricula: "100200300", password: "Password123", administrador: true) }
  let(:darcy) { Restaurante.create!(nome: "Darcy Ribeiro") }
  let(:gama) { Restaurante.create!(nome: "Gama") }
  let(:entrada1) { darcy.catracas.create!(nome: "Entrada 1") }
  let(:entrada2) { darcy.catracas.create!(nome: "Entrada 2") }
  let(:catraca_gama) { gama.catracas.create!(nome: "Catraca Gama") }

  before do
    [ [ darcy, entrada1 ], [ darcy, entrada2 ], [ gama, catraca_gama ] ].each_with_index do |(restaurante, catraca), i|
      Acesso.create!(funcionario: admin, restaurante:, catraca:, identificacao: "23100000#{i}", status: :confirmado, valor_centavos: 450)
    end
  end

  def relatorio(**filtros)
    described_class.new(**filtros)
  end

  describe "sem filtro" do
    it "lista todos os acessos, do mais recente para o mais antigo" do
      expect(relatorio.acessos.map(&:identificacao)).to eq(%w[231000002 231000001 231000000])
      expect(relatorio).not_to be_vazio
      expect(relatorio.erro).to be_nil
    end

    it "trata parâmetros vazios como ausência de filtro" do
      expect(relatorio(restaurante_nome: "", catraca_nome: "").acessos.count).to eq(3)
    end
  end

  describe "filtro por restaurante" do
    it "mostra só os acessos do restaurante" do
      r = relatorio(restaurante_nome: "Darcy Ribeiro")

      expect(r.acessos.count).to eq(2)
      expect(r.restaurante).to eq(darcy)
    end

    it "fica vazio quando o restaurante não existe" do
      r = relatorio(restaurante_nome: "Inexistente")

      expect(r).to be_vazio
      expect(r.restaurante).to be_nil
      expect(r.erro).to be_nil
    end

    it "fica vazio quando o restaurante não tem acessos" do
      Restaurante.create!(nome: "Planaltina")

      expect(relatorio(restaurante_nome: "Planaltina")).to be_vazio
    end
  end

  describe "filtro por catraca" do
    it "busca a catraca em todos os restaurantes quando não há restaurante" do
      expect(relatorio(catraca_nome: "Catraca Gama").acessos.map(&:catraca)).to eq([ catraca_gama ])
    end

    it "combina restaurante e catraca" do
      expect(relatorio(restaurante_nome: "Darcy Ribeiro", catraca_nome: "Entrada 2").acessos.count).to eq(1)
    end

    it "fica vazio, sem erro, quando a catraca não existe" do
      r = relatorio(catraca_nome: "Fantasma")

      expect(r).to be_vazio
      expect(r.erro).to be_nil
    end

    it "fica vazio, sem erro, quando a catraca não existe no restaurante filtrado" do
      r = relatorio(restaurante_nome: "Darcy Ribeiro", catraca_nome: "Fantasma")

      expect(r).to be_vazio
      expect(r.erro).to be_nil
    end

    it "informa erro quando a catraca pertence a outro restaurante" do
      r = relatorio(restaurante_nome: "Gama", catraca_nome: "Entrada 1")

      expect(r.erro).to eq("A catraca Entrada 1 não pertence ao restaurante Gama")
      expect(r).to be_vazio
    end

    it "fica vazio quando o restaurante não existe, mesmo com catraca existente" do
      expect(relatorio(restaurante_nome: "Inexistente", catraca_nome: "Entrada 1")).to be_vazio
    end
  end

  describe "#impedimento_de_exportacao" do
    it "é nil quando há acessos" do
      expect(relatorio.impedimento_de_exportacao).to be_nil
    end

    it "avisa quando não há dados" do
      expect(relatorio(restaurante_nome: "Inexistente").impedimento_de_exportacao).to eq("Não há dados para exportar")
    end

    it "devolve o erro do filtro" do
      expect(relatorio(restaurante_nome: "Gama", catraca_nome: "Entrada 1").impedimento_de_exportacao)
        .to eq("A catraca Entrada 1 não pertence ao restaurante Gama")
    end
  end

  describe "#totais_agrupados" do
    it "agrupa por restaurante" do
      expect(relatorio(agrupar_por: "restaurante").totais_agrupados).to eq("Darcy Ribeiro" => 2, "Gama" => 1)
    end

    it "agrupa por catraca" do
      expect(relatorio(agrupar_por: "catraca").totais_agrupados).to eq("Entrada 1" => 1, "Entrada 2" => 1, "Catraca Gama" => 1)
    end

    it "respeita os filtros" do
      expect(relatorio(restaurante_nome: "Gama", agrupar_por: "catraca").totais_agrupados).to eq("Catraca Gama" => 1)
    end

    it "é nil sem agrupamento ou com agrupamento desconhecido" do
      expect(relatorio.totais_agrupados).to be_nil
      expect(relatorio(agrupar_por: "status").totais_agrupados).to be_nil
    end

    it "é nil quando o filtro tem erro" do
      expect(relatorio(restaurante_nome: "Gama", catraca_nome: "Entrada 1", agrupar_por: "catraca").totais_agrupados).to be_nil
    end
  end
end
