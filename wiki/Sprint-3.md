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
| 2 | Catraca, terminal do operador e autenticação | Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM)) | [#39](https://github.com/Miguel-MCM/UnB_RU/pull/39) | concluído e mergeado na `sprint3` |
| 3 | FastPass, turnos e sorteio | a definir | — | pendente |
| 4 | Área do estudante: cardápio, recarga e extrato | Matheus ([@matheusgit](https://github.com/matheusgit)) | branch `sprint3-area-do-estudante` | concluído |

## Resumo geral

A coluna "Depois do grupo 2" foi medida na branch do PR #39. A coluna "Depois do grupo 4" reflete o avanço com a refatoração e documentação da Área do Estudante na branch `sprint3-area-do-estudante`. A coluna final será preenchida depois do merge dos quatro grupos.

| Métrica | Antes | Depois do grupo 2 | Depois do grupo 4 | Final |
|---|---|---|---|---|
| Score do RubyCritic | 93.23 | 93.24 | 93.32 | — |
| Cobertura do RSpec, total | 98.40% | 98.56% | 98.71% | — |
| Cobertura dos models | 98.98% | 99.00% | 99.27% | — |
| Cobertura dos controllers | 98.26% | 98.63% | 98.64% | — |
| Arquivos de model ou controller abaixo de 90% | 1 | 0 | 0 | — |
| Métodos com Flog ≥ 20 | 10 | 8 | 5 | — |
| Métodos com Flog ≥ 18 | 16 | 13 | 8 | — |
| Métodos com ABC ≥ 20 | 3 | 2 | 2 | — |
| RDoc de `app/models` e `app/controllers` | 10.95% | 36.96% | 68.57% | — |
| Exemplos do RSpec | 276 | 290 | 293 | — |
| Cenários do Cucumber passando | 82 de 82 | 82 de 82 | 82 de 82 | — |

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

## Grupo 4 — Área do estudante: cardápio, recarga e extrato

- **Responsável:** Matheus ([@matheusindio](https://github.com/matheusindio))
- **Código:** branch `sprint3-area-do-estudante`

### Refatoração

| Método | Flog antes | Flog depois | ABC antes | ABC depois |
|---|---|---|---|---|
| `Menu.current_meal_type` | **27.9** | 10.1 | 16.31 | 8.06 |
| `RecargasHelper#codigo_pix` | **22.9** | 6.8 | **18.25** | 6.40 |
| `RecargasController#create` | **20.0** | 15.0 | 14.04 | 9.49 |
| `ExtratoPdf#lancamentos` | 19.6 | 5.8 | **19.08** | 6.08 |
| `Extrato#lancamentos_de_refeicao` | 18.3 | 5.9 | 14.25 | 5.39 |

O que mudou em cada método e por quê:

- **`Menu.current_meal_type`** concentrava múltiplos condicionais encadeados e literais para testar janelas de horário e dias úteis vs. fins de semana. A lógica foi simplificada com a introdução da constante mapeada `MEAL_WINDOWS`, substituindo ramificações aninhadas por uma busca declarativa `find`, reduzindo drasticamente atribuições e desvios.
- **`RecargasHelper#codigo_pix`** continha toda a montagem manual de strings, payload TLV (Tag-Length-Value) e cálculo de CRC16 em um único bloco monolítico. A formatação de campos EMV foi isolada no helper privado `campo_emv` e a geração dos campos chave no helper `campos_pix`, mantendo `codigo_pix` apenas como orquestrador claro.
- **`RecargasController#create`** combinava a instanciação da recarga com parsing condicional de parâmetros, verificação de valor e a construção da mensagem de feedback flash. A formatação da mensagem foi extraída para o método privado `mensagem_confirmacao`.
- **`ExtratoPdf#lancamentos`** misturava a iteração sobre os lançamentos, verificação de tipo (refeição vs recarga), formatação de valores e montagem da tabela visual com estilos Prawn. A lógica de linhas foi extraída para `linhas_da_tabela` e a estilização/renderização para o método privado `renderizar_tabela`.
- **`Extrato#lancamentos_de_refeicao`** acumulava queries no banco de dados com múltiplos relacionamentos aninhados e conversão de dados para a struct `Lancamento`. A consulta foi dividida em `escopo_de_refeicoes` e o mapeamento unitário em `acesso_para_lancamento`.

Métodos privados criados na refatoração:

| Método | Flog | ABC | O que faz |
|---|---|---|---|
| `ExtratoPdf#renderizar_tabela` | 9.2 | 9.06 | Aplica estilos visuais, larguras de coluna e cabeçalho na tabela Prawn |
| `Extrato#escopo_de_refeicoes` | 8.3 | 7.21 | Monta query com joins, includes e filtros temporais de acessos confirmados |
| `RecargasHelper#campos_pix` | 7.8 | 7.07 | Monta array de pares [tag, valor] para a composição do payload Pix |
| `ExtratoPdf#linhas_da_tabela` | 6.8 | 5.10 | Mapeia cada lançamento em linha textual com data, tipo, detalhes e valor |
| `Extrato#acesso_para_lancamento` | 6.1 | 5.39 | Converte uma instância de Acesso confirmado em struct Lancamento |
| `RecargasController#mensagem_confirmacao` | 6.0 | 5.10 | Formata mensagem de sucesso ou erro com valor monetário e recarga simulada |
| `RecargasHelper#campo_emv` | 3.0 | 3.00 | Formata uma tag EMV no padrão Tag-Length-Value com 2 dígitos de tamanho |
| `Recarga#calcular_valor_centavos` | 2.0 | 2.00 | Callback privado para sincronizar valor monetário digitado com centavos |

Depois da refatoração, o maior Flog dos arquivos do grupo é 17.6 (`StatementsController#export_pdf`) e o maior ABC é 15.39 (`Extrato#inicio`), ambos com margem segura abaixo do limite de 18/20.

No RubyCritic, todos os arquivos do grupo possuem nota A. O score geral do RubyCritic no projeto subiu de 93.24 para 93.32.

### Cobertura dos testes

| Arquivo | Antes | Depois |
|---|---|---|
| `app/models/extrato.rb` | 98.40% | **100%** |
| `app/models/extrato_pdf.rb` | 100% | 100% |
| `app/models/menu.rb` | 100% | 100% |
| `app/models/recarga.rb` | 100% | 100% |
| `app/models/tarifa.rb` | 100% | 100% |
| `app/models/user.rb` | 100% | 100% |
| `app/controllers/menus_controller.rb` | 100% | 100% |
| `app/controllers/recargas_controller.rb` | 100% | 100% |
| `app/controllers/statements_controller.rb` | 100% | 100% |
| `app/helpers/recargas_helper.rb` | 100% | 100% |
| `app/helpers/statements_helper.rb` | 100% | 100% |

Todos os 11 arquivos de responsabilidade do Grupo 4 possuem 100% de cobertura de código.

### Happy path e sad path

Todas as funcionalidades da Área do Estudante possuem seus caminhos de sucesso e de falha estritamente cobertos em testes automatizados, e os arquivos `.feature` do Cucumber foram mantidos intactos.

| Spec | Happy path | Sad path |
|---|---|---|
| `spec/models/menu_spec.rb` | Retorno do cardápio da refeição correta nos horários e dias (café, almoço, jantar); rótulo legível em `Menu.meal_label` | Horários fora de qualquer janela de atendimento (`meal_type: nil`); refeições inexistentes ou inválidas tratadas com fallback por `Menu.meal_label` (**novos testes**) |
| `spec/models/extrato_spec.rb` | Consulta de lançamentos nos filtros padrão (últimos 30 dias); união ordenada de recargas e acessos | Filtros por `90_dias`, `tudo` e período desconhecido/inválido com fallback para 30 dias (**novos testes protegendo 100% dos ramos de `Extrato#inicio`**) |
| `spec/models/recarga_spec.rb` | Criação com valor monetário e cálculo de centavos | Recarga sem valor, valor zero ou negativo, e valor não numérico |
| `spec/models/tarifa_spec.rb` | Retorno do valor vigente configurado ou padrão de R$ 6,10 | Ausência de registro no banco com fallback para valor padrão |
| `spec/requests/recargas_spec.rb` | Simulação e confirmação de recarga via Pix com atualização imediata de saldo | Tentativa de recarga com valor inválido ou negativo; acesso sem autenticação de estudante |
| `spec/requests/statements_spec.rb` | Visualização web do extrato de transações e exportação em PDF estruturado | Acesso deslogado redirecionando para login; filtros vazios ou fora do padrão |
| `spec/requests/menus_spec.rb` | Exibição do cardápio vigente em requisições web | Consulta quando não há cardápio cadastrado para a refeição atual |

Ao todo, foram adicionados 3 novos exemplos ao RSpec, elevando o total do projeto de 290 para 293 exemplos (todos passando com 0 falhas).

### RDoc

Todos os 11 arquivos do grupo (models, controllers e helpers) foram integralmente documentados com padrão RDoc rigoroso, cobrindo 100% de classes, módulos, constantes e métodos (públicos e privados), detalhando:
1. Breve descrição da responsabilidade ou comportamento.
2. Argumentos esperados e tipos.
3. Retornos possíveis (sucesso e falhas).
4. Efeitos colaterais (acesso a banco, transações, alterações em sessão ou flash).

Exemplo (`RecargasController#create`):

```ruby
# Processa a criação e confirmação da recarga via formulário web.
#
# Argumentos:: nenhum diretamente (lê +params[:recarga][:valor]+ e a sessão do estudante).
# Retorno:: redireciona para a página de recarga (+recarga_path+).
# Efeitos colaterais:: em caso de sucesso, chama +User#recarregar!+, gerando um registro
#                      de +Recarga+ no banco de dados, incrementando o saldo do estudante
#                      em centavos e definindo +flash[:notice]+. Em caso de valor inválido
#                      ou falha de persistência, define +flash[:alert]+ e não altera o saldo.
def create
```

| Medição | Antes | Depois |
|---|---|---|
| 11 arquivos do Grupo 4, itens públicos | 0% (0 de 47) | **100% (47 de 47)** |
| 11 arquivos do Grupo 4, incluindo métodos privados | 0% (0 de 74) | **100% (74 de 74)** |
| Projeto (`rdoc -C app/models app/controllers`) | 36.96% | **68.57%** |

## Grupos 1 e 3 — pendentes

Estas seções serão preenchidas com os resultados de cada grupo. Os valores de antes, do baseline, são:

| Grupo | Métodos a refatorar (Flog antes) | Cobertura abaixo de 100% (antes) | Arquivos para RDoc |
|---|---|---|---|
| 1 | `AccessReportsController#load_report_data` (67.7), `OperationReportPdf#render` (49.1), `AccessReportsController#export_pdf` (19.7), `Admin::CatracasController#create` (18.6) | `access_reports_controller.rb` (94.6%), `admin/catracas_controller.rb` (95.2%), `admin/restaurantes_controller.rb` (96.0%) | 8 |
| 3 | `InscricaoFastpass.contemplada_de` (26.1), `HorarioEmMinutos#horario` (21.0), `InscricoesFastpassController#create` (20.3), `Admin::TimeFramesController#create` (19.6) | `inscricao_fastpass.rb` (93.8%) | 11 |
