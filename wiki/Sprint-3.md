# Sprint 3 — Refatoração e Documentação

O foco desta sprint é refatorar e documentar o código, seguindo o capítulo 9 do livro ESaaS (edição 1.2.1). Esta página registra o que foi refatorado e compara as métricas antes e depois.

- **Branch de entrega:** [`sprint3`](https://github.com/Miguel-MCM/UnB_RU/tree/sprint3)
- **Kanban:** [UnB RU](https://github.com/users/Miguel-MCM/projects/1/views/2)
- **Baseline:** [`docs/sprint3-baseline.md`](https://github.com/Miguel-MCM/UnB_RU/blob/sprint3/docs/sprint3-baseline.md), medido no commit `de86247` (o fim da Sprint 2)

## Critérios e ferramentas

| Critério | Meta | Ferramenta | Comando |
|---|---|---|---|
| Complexidade por método | ABC < 20 em todo método; refatorar também os que estão perto (≥ 18) | [RubyCritic](https://github.com/whitesmith/rubycritic) (Flog) e RuboCop (`Metrics/AbcSize`) | `bin/docker-run bundle exec rubycritic app --no-browser -p tmp/rubycritic` e `bin/docker-run bundle exec flog -a -m app` |
| Cobertura dos testes | > 90% em cada model e controller | [SimpleCov](https://github.com/simplecov-ruby/simplecov) | `bin/docker-run bundle exec rspec` (relatório em `coverage/`) |
| Happy path e sad path | Os dois em cada funcionalidade, sem alterar os `.feature` | RSpec e Cucumber | `bin/docker-run bundle exec rspec` e `bin/docker-run bundle exec cucumber --no-strict --no-snippets` |
| Documentação | Em cada método: descrição, argumentos, retorno (todas as possibilidades) e efeitos colaterais | [RDoc](https://github.com/ruby/rdoc) | `bin/docker-run bundle exec rdoc -C app/models app/controllers` |

O RubyCritic mede a complexidade de cada método com o **Flog**, uma pontuação baseada em ABC (atribuições, desvios e condições) que também pesa chamadas e blocos. As tabelas trazem também o **ABC** propriamente dito, calculado pelo RuboCop (`Metrics/AbcSize`, `√(A² + B² + C²)`). Os comandos rodam no container do projeto, pelo `bin/docker-run`.

## Divisão do trabalho

O trabalho foi dividido por área do sistema: cada grupo é dono de um conjunto de arquivos e aplica neles os quatro critérios, para que dois grupos não editem o mesmo arquivo.

| Grupo | Área | Responsável | Pull Request | Situação |
|---|---|---|---|---|
| 1 | Relatórios e gestão de restaurantes e catracas | a definir | — | pendente |
| 2 | Catraca, terminal do operador e autenticação | Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM)) | [#39](https://github.com/Miguel-MCM/UnB_RU/pull/39) | concluído, aguardando merge |
| 3 | FastPass, turnos e sorteio | a definir | — | pendente |
| 4 | Área do estudante: cardápio, recarga e extrato | a definir | — | pendente |

## Resumo geral

A coluna "Depois do grupo 2" foi medida na branch do PR #39. A coluna final será preenchida depois do merge dos quatro grupos.

| Métrica | Antes | Depois do grupo 2 | Final |
|---|---|---|---|
| Score do RubyCritic | 93.23 | 93.24 | — |
| Cobertura do RSpec, total | 98.40% | 98.56% | — |
| Cobertura dos models | 98.98% | 99.00% | — |
| Cobertura dos controllers | 98.26% | 98.63% | — |
| Arquivos de model ou controller abaixo de 90% | 1 | 0 | — |
| Métodos com Flog ≥ 20 | 10 | 8 | — |
| Métodos com Flog ≥ 18 | 16 | 13 | — |
| Métodos com ABC ≥ 20 | 3 | 2 | — |
| RDoc de `app/models` e `app/controllers` | 10.95% | 36.96% | — |
| Exemplos do RSpec | 276 | 290 | — |
| Cenários do Cucumber passando | 82 de 82 | 82 de 82 | — |

O score do RubyCritic é uma média por arquivo e quase não se move até que os métodos mais complexos, que são dos grupos 1, 3 e 4, sejam refatorados.

## Grupo 2 — Catraca, terminal do operador e autenticação

- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Código:** [PR #39](https://github.com/Miguel-MCM/UnB_RU/pull/39), branch `sprint3-catraca`

### Refatoração

| Método | Flog antes | Flog depois | ABC antes | ABC depois |
|---|---|---|---|---|
| `Acesso#confirmar_passagem!` | **42.5** | 5.8 | **26.93** | 4.47 |
| `Operador::AcessosController#create` | **23.2** | 15.7 | 18.14 | 13.08 |
| `Operador::TerminalController#show` | 19.2 | 16.9 | 16.19 | 13.96 |
| `Operador::PontosDeAcessoController#update` | 17.9 | 8.1 | 15.43 | 7.07 |

O que mudou em cada método e por quê:

- **`Acesso#confirmar_passagem!`** era o método mais complexo do grupo: num único bloco, travava o acesso, checava o FastPass, travava o estudante, conferia o saldo, debitava e atualizava três registros, com quatro saídas diferentes. Agora ele só encadeia três perguntas: o acesso está liberado, o FastPass ainda vale e o débito foi feito. Cada passo virou um método privado. O comportamento e as travas (`with_lock`) continuam os mesmos.
- **`Operador::AcessosController#create`** decidia qual modalidade de entrada usar, o que é regra da leitura e, pelo MVC do projeto, pertence ao model. A normalização ("fastpass" ou, para qualquer outro valor, "comum") foi para `Acesso.registrar_leitura!`. O controller passou a só montar o ponto de acesso (operador, restaurante e catraca) e redirecionar.
- **`Operador::TerminalController#show`** montava a consulta das últimas leituras com `includes`, `order` e `limit`. A consulta virou o scope `Acesso.recentes`, reaproveitado pelo histórico local, e o limite virou a constante `ULTIMOS_ACESSOS`.
- **`Operador::PontosDeAcessoController#update`** estava a 0.1 do limite de 18. A gravação do ponto de acesso na sessão foi para o método privado `configurar_ponto_de_acesso`.

Métodos privados criados na refatoração:

| Método | Flog | ABC | O que faz |
|---|---|---|---|
| `Acesso#fastpass_valido_na_passagem?` | 11.4 | 10.44 | Trava a inscrição e confere se ela continua sorteada; senão, grava o motivo |
| `Acesso#debitar_passagem!` | 6.1 | 5.10 | Trava o estudante e escolhe entre efetivar ou recusar |
| `Acesso#saldo_cobre_passagem?` | 4.8 | 3.16 | Compara o saldo com o valor da leitura |
| `Acesso#efetivar_passagem!` | 11.1 | 9.06 | Debita o saldo, marca o FastPass como utilizado e confirma o acesso |
| `Acesso#recusar_por_saldo!` | 1.0 | 1.00 | Grava o status `saldo_insuficiente` |
| `Acesso.modalidade_da_leitura` | 5.3 | 4.12 | Normaliza a modalidade da leitura |
| `Operador::AcessosController#ponto_de_acesso` | 3.0 | 3.00 | Junta operador, restaurante e catraca da sessão |
| `Operador::PontosDeAcessoController#configurar_ponto_de_acesso` | 12.2 | 10.49 | Grava o restaurante na sessão e descarta a catraca de outro restaurante |

Depois da refatoração, o maior Flog dos arquivos do grupo é 16.9 e o maior ABC é 15.81 (`Operador::SessionsController#create`, que não precisou mudar).

No RubyCritic, os arquivos do grupo continuaram com nota A, e quase todos perderam code smells. O `acesso.rb` continua com nota C: a complexidade total do arquivo subiu de 102.8 para 106.2, porque a lógica foi distribuída em mais métodos, e os code smells foram de 11 para 12. O aumento vem do aviso `MissingSafeMethod` do Reek, que acusa métodos com `!` sem uma versão sem `!`. Os métodos privados novos seguem a convenção do projeto de usar `!` em métodos que gravam no banco.

### Cobertura dos testes

| Arquivo | Antes | Depois |
|---|---|---|
| `app/controllers/operador/historicos_controller.rb` | **87.50%** | 100% |
| `app/models/acesso.rb` | 100% | 100% |
| `app/models/funcionario.rb` | 100% | 100% |
| `app/models/login_operador.rb` | 100% | 100% |
| `app/models/concerns/autenticavel.rb` | 100% | 100% |
| `app/controllers/concerns/authentication.rb` | 100% | 100% |
| `app/controllers/application_controller.rb` | 100% | 100% |
| `app/controllers/sessions_controller.rb` | 100% | 100% |
| `app/controllers/users_controller.rb` | 100% | 100% |
| `app/controllers/operador/base_controller.rb` | 100% | 100% |
| `app/controllers/operador/acessos_controller.rb` | 100% | 100% |
| `app/controllers/operador/passagens_controller.rb` | 100% | 100% |
| `app/controllers/operador/pontos_de_acesso_controller.rb` | 100% | 100% |
| `app/controllers/operador/sessions_controller.rb` | 100% | 100% |
| `app/controllers/operador/terminal_controller.rb` | 100% | 100% |
| `app/helpers/operador_helper.rb` | 100% | 100% |

O `historicos_controller.rb` era o único arquivo de model ou controller do projeto abaixo de 90%: o caso em que nenhuma catraca foi escolhida não era testado.

### Happy path e sad path

Os sad paths que faltavam foram escritos antes da refatoração, para protegê-la. Os `.feature` não foram alterados.

| Spec | Happy path | Sad path |
|---|---|---|
| `spec/models/acesso_spec.rb` | Leitura liberada e passagem confirmada, na entrada comum e no FastPass | Já existiam: estudante desconhecido, saldo insuficiente, passagem já confirmada, FastPass fora do time-frame, não sorteado, de outro restaurante ou utilizado. **Novos:** FastPass usado entre a leitura e a passagem; saldo que caiu numa passagem pelo FastPass (a inscrição continua sorteada) |
| `spec/requests/validacao_entrada_spec.rb` | Leitura, passagem e débito | Já existiam: leitura vazia, saldo insuficiente, estudante desconhecido, débito duplo, leitura de outro operador. **Novos:** passagem de uma leitura inexistente (404); passagem sem operador logado |
| `spec/requests/operador/historico_spec.rb` | Acessos da catraca escolhida | Já existiam: catraca sem acessos, sem login. **Novos:** sem catraca escolhida; catraca inexistente |
| `spec/requests/autenticacao_spec.rb` | Login e logout do estudante | Já existia: senha errada. **Novos:** matrícula sem conta; campos em branco |
| `spec/requests/cadastro_spec.rb` | Cadastro do estudante | Já existiam: senhas diferentes, matrícula repetida. **Novos:** campos obrigatórios em branco; letras na matrícula |
| `spec/models/funcionario_spec.rb` | Funcionário válido e login | Já existiam: campos obrigatórios, matrícula repetida, senha errada. **Novos:** matrícula inexistente; matrícula ou senha ausentes; funcionário com leituras não pode ser removido |
| `spec/requests/autenticacao_operador_spec.rb`, `spec/models/login_operador_spec.rb`, `spec/requests/operador/pontos_de_acesso_spec.rb` e `spec/requests/operador/acessos_fastpass_spec.rb` | Login do operador, escolha do ponto de acesso e leitura do FastPass | Já cobriam campos em branco, credenciais erradas, sessão de estudante no terminal, restaurante inexistente (404), leitura sem restaurante escolhido e modalidade inválida |

Ao todo, o grupo acrescentou 14 exemplos ao RSpec, contando um do scope novo `Acesso.recentes`.

### RDoc

Os 16 arquivos do grupo ganharam um comentário de classe ou módulo e, em cada método, público ou privado, a descrição, os argumentos, o retorno com todas as possibilidades e os efeitos colaterais (redirecionamentos, gravações no banco, alterações de saldo e de sessão). Exemplo:

```ruby
# Confirma que o estudante passou pela catraca e debita a refeição do saldo.
#
# Argumentos:: nenhum.
# Retorno:: +true+ quando a passagem é confirmada; +false+ quando o acesso não
#           está liberado (bloqueado ou já confirmado), o FastPass deixou de
#           valer ou o saldo ficou insuficiente desde a leitura.
# Efeitos colaterais:: com lock no acesso, na inscrição do FastPass e no
#                      estudante, debita +valor_centavos+ do saldo, marca o
#                      FastPass como utilizado e o acesso como +confirmado+.
#                      Nas recusas, grava no acesso o status do motivo
#                      (+sem_fastpass+, +fastpass_utilizado+ ou +saldo_insuficiente+)
#                      e não altera o saldo.
def confirmar_passagem!
```

| Medição | Antes | Depois |
|---|---|---|
| 16 arquivos do grupo, itens públicos | 5% (2 de 40) | 100% (41 de 41) |
| 16 arquivos do grupo, com os métodos privados | 5% (3 de 56) | 100% (65 de 65) |
| Projeto (`rdoc -C app/models app/controllers`) | 10.95% | 36.96% |

### Ruby 3.3.14

Durante a sprint saiu o Brakeman 8.1.1, que acusa uma vulnerabilidade crítica de execução remota de código no Ruby 3.3.8 (CVE-2026-132825). Como o `bin/brakeman` exige a versão mais recente da gem, o job `scan_ruby` do CI falharia em qualquer PR. O PR #39 sobe o Ruby do projeto para 3.3.14 (`.ruby-version` e `Dockerfile`), o Brakeman para 8.1.1 e o Puma para 8.1.2, que corrige dois alertas do `bundler-audit`.

## Grupos 1, 3 e 4 — pendentes

Estas seções serão preenchidas com os resultados de cada grupo. Os valores de antes, do baseline, são:

| Grupo | Métodos a refatorar (Flog antes) | Cobertura abaixo de 100% (antes) | Arquivos para RDoc |
|---|---|---|---|
| 1 | `AccessReportsController#load_report_data` (67.7), `OperationReportPdf#render` (49.1), `AccessReportsController#export_pdf` (19.7), `Admin::CatracasController#create` (18.6) | `access_reports_controller.rb` (94.6%), `admin/catracas_controller.rb` (95.2%), `admin/restaurantes_controller.rb` (96.0%) | 8 |
| 3 | `InscricaoFastpass.contemplada_de` (26.1), `HorarioEmMinutos#horario` (21.0), `InscricoesFastpassController#create` (20.3), `Admin::TimeFramesController#create` (19.6) | `inscricao_fastpass.rb` (93.8%) | 11 |
| 4 | `Menu.current_meal_type` (27.9), `RecargasHelper#codigo_pix` (22.9), `RecargasController#create` (20.0), `ExtratoPdf#lancamentos` (19.6), `Extrato#lancamentos_de_refeicao` (18.3) | `extrato.rb` (98.4%) | 11 |
