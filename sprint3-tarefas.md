# Sprint 3 — o que falta fazer

Checklist dos critérios mínimos da "Entrega da Terceira Sprint" (refatoração e documentação,
cap. 9 do ESaaS 1.2.1). Os números de partida estão em [`sprint3-baseline.md`](sprint3-baseline.md).

- [x] Instalar RubyCritic, SimpleCov e RDoc (`0fd049a`).
- [x] Medir o baseline (ABC/Flog, cobertura, % RDoc).

## Como a divisão funciona

O trabalho foi dividido **por área do sistema**, não por critério: cada pessoa é dona de um
conjunto de arquivos e faz nele os 4 critérios (refatorar, testar, sad path, RDoc). Assim
ninguém edita o mesmo arquivo que outra pessoa e os PRs não conflitam.

| Grupo | Área | Refatorações (Flog) | Arquivos para RDoc |
|---|---|---|---|
| 1 | Relatórios e gestão de restaurantes/catracas | 4 (155) | 8 |
| 2 | Catraca, terminal do operador e autenticação | 3 (85) | 16 |
| 3 | FastPass, turnos e sorteio | 4 (87) | 11 |
| 4 | Área do estudante: cardápio, recarga e extrato | 5 (109) | 11 |

O grupo 1 tem as refatorações mais pesadas e pouca documentação; o grupo 2 é o contrário.

### Fluxo

1. Cada pessoa cria uma branch a partir de `sprint3` (ex.: `sprint3-relatorios`) e abre PR para `sprint3`.
2. Antes de abrir o PR, rodar tudo e garantir que está verde:

   ```bash
   bin/docker-run bundle exec rspec                                  # + cobertura em coverage/
   bin/docker-run bundle exec cucumber --no-strict --no-snippets
   bin/docker-run bin/rubocop
   bin/docker-run bin/brakeman --no-pager -q
   bin/docker-run bundle exec flog -a -m app                         # Flog por método
   bin/docker-run bundle exec rdoc -C app/models app/controllers     # % documentado
   ```

3. Anotar os valores "depois" dos seus métodos e arquivos (vão para a wiki).

### Regras para todos

- **Não alterar nenhum `.feature`.** Sad path que faltar vai para o RSpec.
- Meta de ABC: nenhum método com Flog ≥ 20. Os que estão perto (≥ 18) também devem ser refatorados.
- Meta de cobertura: > 90% em cada model e controller do grupo.
- Seguir o MVC do `CLAUDE.md`: regra de negócio extraída de controller vai para model/PORO em `app/models`.
- Não mudar a assinatura pública de `HorarioEmMinutos.minutos_do` (usado por `Acesso`, `Sorteio`
  e `InscricaoFastpass`, de grupos diferentes).
- RDoc em **cada método**, com os 4 itens pedidos: descrição, argumentos, retorno (todas as
  possibilidades) e efeitos colaterais (redirect, escrita no banco, saldo...). Também um
  comentário de classe dizendo o que ela representa. Modelo:

  ```ruby
  # Confirma que o estudante passou pela catraca e debita a refeição do saldo.
  #
  # Argumentos:: nenhum.
  # Retorno:: +true+ quando a passagem é confirmada; +false+ quando o acesso
  #           não está liberado, o FastPass é inválido ou o saldo é insuficiente.
  # Efeitos colaterais:: com lock no acesso e no usuário, debita +valor_centavos+
  #                      do saldo, marca o FastPass como utilizado e o acesso como
  #                      confirmado; nas recusas, grava o status do motivo.
  def confirmar_passagem!
  ```

---

## Grupo 1 — Relatórios e gestão de restaurantes/catracas

Responsável: ______________________

### Refatoração (ABC)

- [ ] `AccessReportsController#load_report_data`: Flog **67.7** / ABC 48.35
      (`app/controllers/access_reports_controller.rb:30`). Também viola o MVC: mover filtros,
      agrupamento e validação para um PORO em `app/models` (ex.: `RelatorioAcessos`) com scopes.
- [ ] `AccessReportsController#export_pdf`: 19.7 (`:9`). Deve cair junto com o anterior.
- [ ] `OperationReportPdf#render`: **49.1** / 27.46 (`app/pdfs/operation_report_pdf.rb:10`).
      Quebrar em métodos privados (cabeçalho, tabela, totais), como em `ExtratoPdf`.
- [ ] `Admin::CatracasController#create`: 18.6 (`app/controllers/admin/catracas_controller.rb:5`).

### Testes e cobertura

- [ ] `spec/models/` para o PORO novo do relatório.
- [ ] Criar `spec/requests/admin/catracas_spec.rb` (hoje só coberto indiretamente).
- [ ] Cobrir `access_reports_controller.rb` linhas 13-14 (94.6%).
- [ ] Cobrir `admin/catracas_controller.rb` linha 23 (95.2%).
- [ ] Cobrir `admin/restaurantes_controller.rb` linha 10 (96.0%).

### Sad path

- [ ] `gestao_restaurantes_catracas.feature` só tem cenários de sucesso. Garantir no RSpec
      (`admin/restaurantes_spec.rb` e `admin/catracas_spec.rb`): cadastro com campos inválidos,
      acesso sem ser administrador, registro inexistente.
- [ ] Conferir sad path em `access_reports_spec.rb`, `operation_report_pdf_spec.rb`,
      `restaurante_spec.rb`, `catraca_spec.rb`.

### RDoc

- [ ] `app/controllers/access_reports_controller.rb`
- [ ] `app/controllers/admin/base_controller.rb`
- [ ] `app/controllers/admin/catracas_controller.rb`
- [ ] `app/controllers/admin/restaurantes_controller.rb`
- [ ] `app/models/restaurante.rb`
- [ ] `app/models/catraca.rb` (só comentário de classe)
- [ ] `app/pdfs/operation_report_pdf.rb`
- [ ] `app/helpers/application_helper.rb` (helper `icon` e afins, usados por todos)

---

## Grupo 2 — Catraca, terminal do operador e autenticação

Responsável: ______________________

### Refatoração (ABC)

- [ ] `Acesso#confirmar_passagem!`: Flog **42.5** / ABC 26.93 (`app/models/acesso.rb:97`).
      Extrair a checagem do FastPass e o débito do saldo em métodos privados.
- [ ] `Operador::AcessosController#create`: **23.2** / 18.14
      (`app/controllers/operador/acessos_controller.rb:5`).
- [ ] `Operador::TerminalController#show`: 19.2 (`app/controllers/operador/terminal_controller.rb:5`).

### Testes e cobertura

- [ ] **`operador/historicos_controller.rb`: 87.5%, linha 10 sem cobertura.** Único arquivo do
      projeto abaixo da meta: obrigatório.
- [ ] Conferir que os specs de `Acesso` cobrem todos os ramos de `confirmar_passagem!` depois
      da refatoração (não liberado, FastPass inválido, saldo insuficiente, sucesso).

### Sad path

- [ ] Conferir sad path em `validacao_entrada_spec.rb`, `autenticacao_spec.rb`,
      `autenticacao_operador_spec.rb`, `cadastro_spec.rb`, `operador/*_spec.rb`,
      `acesso_spec.rb`, `funcionario_spec.rb`, `login_operador_spec.rb`.

### RDoc

- [ ] `app/models/acesso.rb`
- [ ] `app/models/funcionario.rb` (só comentário de classe)
- [ ] `app/models/login_operador.rb`
- [ ] `app/models/concerns/autenticavel.rb`
- [ ] `app/controllers/concerns/authentication.rb`
- [ ] `app/controllers/application_controller.rb`
- [ ] `app/controllers/sessions_controller.rb`
- [ ] `app/controllers/users_controller.rb`
- [ ] `app/controllers/operador/base_controller.rb`
- [ ] `app/controllers/operador/acessos_controller.rb`
- [ ] `app/controllers/operador/historicos_controller.rb`
- [ ] `app/controllers/operador/passagens_controller.rb`
- [ ] `app/controllers/operador/pontos_de_acesso_controller.rb`
- [ ] `app/controllers/operador/sessions_controller.rb`
- [ ] `app/controllers/operador/terminal_controller.rb`
- [ ] `app/helpers/operador_helper.rb`

---

## Grupo 3 — FastPass, turnos e sorteio

Responsável: ______________________

### Refatoração (ABC)

- [ ] `InscricaoFastpass.contemplada_de`: Flog **26.1** / ABC 19.34 (`app/models/inscricao_fastpass.rb:34`).
- [ ] `HorarioEmMinutos#horario`: **21.0** (`app/models/concerns/horario_em_minutos.rb:42`).
      Não mudar a assinatura de `minutos_do` (ver regras).
- [ ] `InscricoesFastpassController#create`: **20.3** / 16.25
      (`app/controllers/inscricoes_fastpass_controller.rb:4`).
- [ ] `Admin::TimeFramesController#create`: 19.6 (`app/controllers/admin/time_frames_controller.rb:3`).

### Testes e cobertura

- [ ] Cobrir `inscricao_fastpass.rb` linhas 55, 56 e 65 (93.8%).

### Sad path

- [ ] `spec/requests/fastpass_spec.rb`: só tem "exige login"; adicionar outro caso de erro
      (ex.: nenhum turno disponível).
- [ ] `spec/models/notificacao_spec.rb`: conferir.
- [ ] Conferir `inscricoes_fastpass_spec.rb`, `notificacoes_spec.rb`, `admin/turnos_spec.rb`,
      `admin/time_frames_spec.rb`, `operador/acessos_fastpass_spec.rb`, `sorteio_spec.rb`,
      `turno_spec.rb`, `time_frame_spec.rb`, `inscricao_fastpass_spec.rb`.

### RDoc

- [ ] `app/models/inscricao_fastpass.rb`
- [ ] `app/models/sorteio.rb`
- [ ] `app/models/turno.rb`
- [ ] `app/models/time_frame.rb` (só comentário de classe)
- [ ] `app/models/notificacao.rb` (só comentário de classe)
- [ ] `app/models/concerns/horario_em_minutos.rb`
- [ ] `app/controllers/fastpass_controller.rb`
- [ ] `app/controllers/inscricoes_fastpass_controller.rb`
- [ ] `app/controllers/notificacoes_controller.rb`
- [ ] `app/controllers/admin/turnos_controller.rb`
- [ ] `app/controllers/admin/time_frames_controller.rb`

---

## Grupo 4 — Área do estudante: cardápio, recarga e extrato

Responsável: ______________________

### Refatoração (ABC)

- [ ] `Menu.current_meal_type`: Flog **27.9** / ABC 16.31 (`app/models/menu.rb:7`).
- [ ] `RecargasHelper#codigo_pix`: **22.9** / 18.25 (`app/helpers/recargas_helper.rb:6`).
- [ ] `RecargasController#create`: **20.0** / 14.04 (`app/controllers/recargas_controller.rb:11`).
- [ ] `ExtratoPdf#lancamentos`: 19.6 / 19.08 (`app/models/extrato_pdf.rb:38`).
- [ ] `Extrato#lancamentos_de_refeicao`: 18.3 (`app/models/extrato.rb:93`).

### Testes e cobertura

- [ ] Cobrir `extrato.rb` linha 85 (98.4%).

### Sad path

- [ ] `extrato_e_historico.feature` só tem cenários de sucesso. Garantir em `extrato_spec.rb`
      (model e request): estudante não logado, período inválido (data final antes da inicial),
      filtro sem resultados.
- [ ] `recarga_de_saldo.feature` só tem cenários de sucesso. `recarga_spec.rb` já testa
      quantidade inválida; conferir método de pagamento inválido.
- [ ] `spec/models/tarifa_spec.rb`: conferir.
- [ ] Conferir `menus_spec.rb`, `menu_spec.rb`, `extrato_pdf_spec.rb`, `user_spec.rb`, `recarga_spec.rb` (model).

### RDoc

- [ ] `app/models/extrato.rb` (20 métodos: o maior arquivo)
- [ ] `app/models/extrato_pdf.rb`
- [ ] `app/models/menu.rb`
- [ ] `app/models/recarga.rb` (só comentário de classe)
- [ ] `app/models/tarifa.rb`
- [ ] `app/models/user.rb`
- [ ] `app/controllers/menus_controller.rb`
- [ ] `app/controllers/recargas_controller.rb`
- [ ] `app/controllers/statements_controller.rb`
- [ ] `app/helpers/recargas_helper.rb`
- [ ] `app/helpers/statements_helper.rb`

---

## Fechamento e entregáveis (todos, depois do merge dos 4 PRs)

Responsável pela consolidação: ______________________

- [ ] Rodar RubyCritic, Flog, SimpleCov e RDoc de novo na `sprint3` com tudo mergeado e conferir:
  - [ ] nenhum método com Flog ≥ 20;
  - [ ] todo model e controller com cobertura > 90%;
  - [ ] RDoc perto de 100% (hoje 10.95%).
- [ ] Cucumber completo: todos os cenários que passavam antes continuam passando.
- [ ] **Pull Request** da `sprint3` com o código final.
- [ ] **Arquivo `.txt`** com o link do repositório e nome + matrícula de cada integrante.
- [ ] **`wiki/Sprint-3.md`** no GitHub (e link na `wiki/Home.md`). Cada grupo manda as linhas
      dos seus arquivos; a consolidação monta:
  - [ ] o que foi refatorado e por quê (método a método);
  - [ ] **tabela antes × depois** do Flog/ABC dos métodos refatorados;
  - [ ] **tabela antes × depois** da cobertura de cada model e controller;
  - [ ] % documentado pelo RDoc antes × depois;
  - [ ] score geral do RubyCritic antes × depois (93.23 → ?).
- [ ] Confirmar o prazo real (o PDF diz 17/02/2025).
