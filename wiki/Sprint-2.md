# Sprint 2 — Features e Integração Contínua

Sistema de gerenciamento para o Restaurante Universitário da UnB.

- **Repositório principal:** [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU)
- **Fork do grupo:** [Miguel-MCM/UnB_RU](https://github.com/Miguel-MCM/UnB_RU)
- **Branch de entrega:** [`sprint2`](https://github.com/Miguel-MCM/UnB_RU/tree/sprint2)
- **Release:** [`Entrega-2`](https://github.com/Miguel-MCM/UnB_RU/releases/tag/Entrega-2)
- **Pull Request no repositório principal:** [neatzzy/UnB_RU#50](https://github.com/neatzzy/UnB_RU/pull/50)
- **Kanban:** [UnB RU](https://github.com/users/Miguel-MCM/projects/1/views/2)
- **Workflow:** [`.github/workflows/ci.yml`](https://github.com/Miguel-MCM/UnB_RU/blob/sprint2/.github/workflows/ci.yml)
- **Execuções:** [GitHub Actions](https://github.com/Miguel-MCM/UnB_RU/actions/workflows/ci.yml)
- **Publicação da Wiki:** [`.github/workflows/wiki.yml`](https://github.com/Miguel-MCM/UnB_RU/blob/sprint2/.github/workflows/wiki.yml)

## Como o CI foi feito

O CI foi configurado com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic. O agente partiu do workflow gerado pelo Rails, adicionou o job de testes, rodou RSpec, Cucumber e RuboCop localmente e acompanhou as execuções no GitHub Actions até todos os jobs passarem.

## Quando o CI roda

- Em todo Pull Request.
- Em push para a `main` e para qualquer branch que comece com `sprint` (por exemplo, `sprint2`).

## Jobs

| Job | O que faz |
|---|---|
| `test` | Prepara o banco de testes e roda RSpec e Cucumber |
| `lint` | Verifica o estilo do código Ruby com RuboCop (`rubocop-rails-omakase`) |
| `scan_ruby` | Procura vulnerabilidades no código com Brakeman e nas gems com bundler-audit |
| `scan_js` | Procura vulnerabilidades nas dependências JavaScript do importmap |

Todos os jobs usam o Ruby definido em `.ruby-version` (3.3.8), com as gems em cache.

## Decisões

- **Passos do Cucumber ainda não implementados não quebram o CI.** O Cucumber roda com `--no-strict`: cenários com passos indefinidos ou pendentes aparecem no log, mas o CI só falha quando um passo implementado falha. Em 13/11, antes da integração dos PRs de 15/11, o CI mostrava `82 scenarios (58 undefined, 24 passed)`. Com a integração dos PRs na `sprint2` e o épico FastPass (seções abaixo), todos os 82 cenários têm step definitions e passam inclusive com `--strict`.
- **Runner fixado em `ubuntu-24.04`.** O `ubuntu-latest` passou a ser o Ubuntu 26.04, que não oferece o Ruby 3.3.8. Para usar o `ubuntu-latest`, é preciso subir o Ruby do projeto para a versão 3.3 mais recente, em `.ruby-version` e no `Dockerfile`.
- **`db/schema.rb` versionado.** Sem ele, `bin/rails db:test:prepare` falha. O arquivo é atualizado sempre que alguém roda `bin/rails db:migrate`.
- **A Wiki acompanha a `sprint2`.** As páginas da Wiki ficam na pasta `wiki/` do repositório. Sempre que essa pasta muda na `sprint2`, o workflow `wiki.yml` copia as páginas para a Wiki do GitHub. Por isso, as páginas devem ser editadas na pasta `wiki/`, não direto na Wiki: uma edição feita só na Wiki é sobrescrita na próxima publicação. Quando o workflow chegar à `main`, ele também poderá ser rodado manualmente na aba Actions.
- **Modelos de domínio em português.** Quando a base de banco e autenticação do João Borges chegou à `sprint2`, ela trazia outra versão dos mesmos modelos, com nomes em inglês (`Restaurant`, `Turnstile`, `AccessLog`, `Recharge`). O grupo manteve os modelos das issues já implementadas (`User`, `Funcionario`, `Restaurante`, `Catraca`, `Acesso`, `Recarga`, `Tarifa`). Da base, ficaram as gems e rotas de PDF, cardápio, relatório e extrato, os passos de PDF do Cucumber e a tabela `menus`.

## Rodar localmente

```bash
bundle install
bin/rails db:test:prepare
bundle exec rspec
bundle exec cucumber --no-strict
bin/rubocop
```

Para corrigir automaticamente as ofensas do RuboCop que têm correção segura, use `bin/rubocop -a`.

## Features e responsáveis

Cada feature tem uma seção nesta página, em ordem de issue. A tag do Cucumber segue a numeração do repositório principal, a mesma do arquivo `.feature`.

| Issue no fork | Issue no repositório principal | Feature | Responsável | Tag do Cucumber |
|---|---|---|---|---|
| [#6](https://github.com/Miguel-MCM/UnB_RU/issues/6) | [#1](https://github.com/neatzzy/UnB_RU/issues/1) | Cadastro de Usuário | Miguel | `@issue_1` |
| [#7](https://github.com/Miguel-MCM/UnB_RU/issues/7) | [#2](https://github.com/neatzzy/UnB_RU/issues/2) | Recarga de Saldo | Miguel | `@issue_2` |
| [#8](https://github.com/Miguel-MCM/UnB_RU/issues/8) | [#3](https://github.com/neatzzy/UnB_RU/issues/3) | Extrato e Histórico | Miguel | `@issue_3` |
| [#9](https://github.com/Miguel-MCM/UnB_RU/issues/9) | [#4](https://github.com/neatzzy/UnB_RU/issues/4) | Autenticação do Funcionário | Miguel | `@issue_4` |
| [#10](https://github.com/Miguel-MCM/UnB_RU/issues/10) | [#5](https://github.com/neatzzy/UnB_RU/issues/5) | Configuração de Ponto de Acesso | João Filipe | `@issue_5` |
| [#11](https://github.com/Miguel-MCM/UnB_RU/issues/11) | [#6](https://github.com/neatzzy/UnB_RU/issues/6) | Validação de Entrada | Miguel | `@issue_6` |
| [#12](https://github.com/Miguel-MCM/UnB_RU/issues/12) | [#7](https://github.com/neatzzy/UnB_RU/issues/7) | Histórico Local da Catraca | Matheus | `@issue_7` |
| [#13](https://github.com/Miguel-MCM/UnB_RU/issues/13) | [#8](https://github.com/neatzzy/UnB_RU/issues/8) | Gestão de Restaurantes e Catracas | Miguel | `@issue_8` |
| [#14](https://github.com/Miguel-MCM/UnB_RU/issues/14) | [#9](https://github.com/neatzzy/UnB_RU/issues/9) | Relatório Global de Acessos | João Borges | `@issue_9` |
| [#15](https://github.com/Miguel-MCM/UnB_RU/issues/15) | [#10](https://github.com/neatzzy/UnB_RU/issues/10) | Cardápio da Refeição Atual | João Borges | `@issue_10` |
| [#16](https://github.com/Miguel-MCM/UnB_RU/issues/16) | [#11](https://github.com/neatzzy/UnB_RU/issues/11) | Exportação em PDF do Histórico do Estudante | João Borges | `@issue_11` |
| [#17](https://github.com/Miguel-MCM/UnB_RU/issues/17) | [#12](https://github.com/neatzzy/UnB_RU/issues/12) | Exportação em PDF do Relatório de Operação | João Borges | `@issue_12` |
| [#19](https://github.com/Miguel-MCM/UnB_RU/issues/19) | [#14](https://github.com/neatzzy/UnB_RU/issues/14) | Inscrição Única no FastPass (bônus) | João Filipe | `@issue_bonus_4` |
| [#20](https://github.com/Miguel-MCM/UnB_RU/issues/20) | [#15](https://github.com/neatzzy/UnB_RU/issues/15) | Notificação de Sorteio (bônus) | João Filipe | `@issue_bonus_3` |
| [#21](https://github.com/Miguel-MCM/UnB_RU/issues/21) | [#16](https://github.com/neatzzy/UnB_RU/issues/16) | Validação Rigorosa do FastPass (bônus) | João Filipe | `@issue_bonus_2` |
| [#22](https://github.com/Miguel-MCM/UnB_RU/issues/22) | [#17](https://github.com/neatzzy/UnB_RU/issues/17) | Gestão de Turnos e Time-frames (bônus) | João Filipe | `@issue_bonus_1` |

As issues #19 a #22 formam o épico bônus FastPass ([#18](https://github.com/Miguel-MCM/UnB_RU/issues/18) no fork, [#13](https://github.com/neatzzy/UnB_RU/issues/13) no repositório principal).

## Issue #6 — Cadastro de Usuário

- **Issue:** [#6 Cadastro de Usuário](https://github.com/Miguel-MCM/UnB_RU/issues/6) (no repositório principal, [#1](https://github.com/neatzzy/UnB_RU/issues/1))
- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Design:** [Figma do projeto](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=0-1&p=f&t=Z5Wstj7zb37w7TT8-0)

A issue foi desenvolvida por mim com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic, em TDD: primeiro os step definitions do Cucumber para os cenários de `features/cadastro_de_usuario.feature`, depois as specs do RSpec do modelo e das requisições, e só então o código que as faz passar. O primeiro prompt enviado ao agente foi:

> Utilize TDD para desenvolver a issue #6
> Faça a página conforme o seguinte figma: https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=0-1&p=f&t=Z5Wstj7zb37w7TT8-0

Todo o código gerado pelo agente foi revisado por mim.

## Issue #7 — Recarga de Saldo

- **Issue:** [#7 Recarga de Saldo](https://github.com/Miguel-MCM/UnB_RU/issues/7) (no repositório principal, [#2](https://github.com/neatzzy/UnB_RU/issues/2))
- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Design:** frame "Recarga de Saldo (US03)" do [Figma do projeto](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=1-1097)

A issue foi desenvolvida por mim com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic, no mesmo processo da issue #6: TDD a partir dos cenários de `features/recarga_de_saldo.feature`, página no visual do Figma, branch própria, Pull Request contra a `sprint2` e card movido para In Progress. O primeiro prompt enviado ao agente, na mesma conversa da issue #6, foi:

> Agora faça o mesmo processo de implementação para a issue 7

Como os cenários pedem um estudante autenticado, a issue também trouxe o login do estudante em `/login`, com matrícula e senha. O pagamento é simulado: o QR Code e o código PIX copia e cola são gerados pela aplicação, mas nenhum banco aceita pagá-los.

Todo o código gerado pelo agente foi revisado por mim.

## Issue #8 — Extrato e Histórico

- **Issue:** [#8 Extrato e Histórico](https://github.com/Miguel-MCM/UnB_RU/issues/8) (no repositório principal, [#3](https://github.com/neatzzy/UnB_RU/issues/3))
- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Design:** frame "Extrato de Refeições (US04)" do [Figma do projeto](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=1-2330)

A issue foi desenvolvida por mim com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic, no mesmo processo das issues anteriores: TDD a partir dos cenários de `features/extrato_e_historico.feature`, página no visual do Figma, branch própria, Pull Request contra a `sprint2` e card movido para In Progress. O prompt usado foi:

> Agora implemente a issue 8

O extrato fica em `/extrato`, nas rotas que já estavam reservadas na `sprint2`. Mostra o total gasto, as refeições e o total recarregado no mês, e lista as refeições debitadas e as recargas, com filtro por período e por tipo de refeição. "Exportar PDF" baixa o extrato com os filtros aplicados, gerado com a gem `prawn`, e "Imprimir" abre a impressão do navegador. Para filtrar pelo tipo de refeição, cada passagem pela catraca passou a guardar se foi café da manhã, almoço ou jantar, conforme o horário da leitura.

Todo o código gerado pelo agente foi revisado por mim.

## Issue #9 — Autenticação do Funcionário

- **Issue:** [#9 Autenticação do Funcionário](https://github.com/Miguel-MCM/UnB_RU/issues/9) (no repositório principal, [#4](https://github.com/neatzzy/UnB_RU/issues/4))
- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Design:** frame "Autenticação Operacional (US07)" do [Figma do projeto](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=1-3165)

A issue foi desenvolvida por mim com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic, no mesmo processo das issues #6 e #7: TDD a partir dos cenários de `features/autenticacao_do_funcionario.feature`, página no visual do Figma, branch própria, Pull Request contra a `sprint2` e card movido para In Progress. O primeiro prompt enviado ao agente, na mesma conversa das issues anteriores, foi:

> Agora faça de novo pára a 9

O login do operador fica em `/operador/login` e, depois de autenticado, leva ao terminal de catraca em `/operador/terminal`. Por enquanto essa página só confirma que o terminal foi liberado; a leitura do QR Code e o débito da refeição são da issue #11. Os operadores não se cadastram pelo site: para testar localmente, `bin/rails db:seed` cria o operador de matrícula `1984201` e senha `Operador123`.

Todo o código gerado pelo agente foi revisado por mim.

## Issue #10 — Configuração de Ponto de Acesso

- **Issue:** [#10 Configuração de Ponto de Acesso](https://github.com/Miguel-MCM/UnB_RU/issues/10) (no repositório principal, [#5](https://github.com/neatzzy/UnB_RU/issues/5))
- **Responsável:** João Filipe ([@joaofiulipe](https://github.com/joaofiulipe)). A issue não tinha responsável no grupo (na Sprint 1, a especificação foi do Miguel); eu a implementei para fechar a entrega e porque a validação do FastPass (#21) depende dela.
- **Código:** sem PR próprio. Commit [278e308](https://github.com/Miguel-MCM/UnB_RU/commit/278e308b99cb265e783e8966dd5712e500f3a348) na branch `feat/ponto-de-acesso`, a primeira de uma cadeia (`feat/ponto-de-acesso` → `feat/validacao-fastpass` → `feat/notificacao-sorteio`) que vai para a `sprint2` junto com esta documentação.

Desenvolvi esta issue e as do épico FastPass (#18 no fork, #13 no repositório principal) com o [Claude Code](https://claude.com/claude-code), pela extensão do VS Code, usando o modelo **Claude Opus 5.5**, da Anthropic, num loop de desenvolvimento. A fila de trabalho fica em [`docs/loop/fila.md`](https://github.com/Miguel-MCM/UnB_RU/blob/sprint2/docs/loop/fila.md): uma issue por item, com a tag do Cucumber, a branch, a mensagem do commit e as notas de design. O único prompt que eu envio é:

> /loop Execute uma iteração conforme docs/loop/prompt.md

A cada iteração, o loop segue [`docs/loop/prompt.md`](https://github.com/Miguel-MCM/UnB_RU/blob/sprint2/docs/loop/prompt.md): pega o primeiro item pendente da fila, cria a branch e só orquestra, delegando o trabalho a quatro agentes definidos em [`.claude/agents/`](https://github.com/Miguel-MCM/UnB_RU/tree/sprint2/.claude/agents):

| Agente | O que faz |
|---|---|
| `especificador` | Lê o `.feature`, o diagrama ER, os steps e o código existentes e devolve um plano MVC (passos novos e reaproveitados, migrations, models, rotas, telas e mensagens), sem escrever código |
| `implementador` | BDD/TDD: escreve os step definitions e as specs, confirma que falham pelo motivo certo e implementa na ordem migration → model → rotas → controller → view até a tag passar |
| `testador` | Roda RSpec, Cucumber (`--strict` na tag e o conjunto completo, para pegar regressões), RuboCop e Brakeman, e confere se as migrations, rodadas do zero, geram o `db/schema.rb` commitado |
| `revisor-mvc` | Revisa o diff de forma independente: bugs, segurança, MVC e convenções. Itens bloqueantes voltam ao implementador, seguidos de nova rodada do testador |

As regras do projeto (MVC, nomes em português, dinheiro em centavos, mensagens no `pt-BR.yml` e definição de pronto) ficam no [`CLAUDE.md`](https://github.com/Miguel-MCM/UnB_RU/blob/sprint2/CLAUDE.md), que todos os agentes seguem. Como eu não tinha Ruby instalado na máquina, tudo roda no container do projeto, pelo script `bin/docker-run`. Ao fim de cada issue, o loop marca o item na fila com uma nota das decisões tomadas e faz um único commit, sem push.

**Solução.** Depois do login, se há restaurantes cadastrados, o operador é levado direto à seleção do restaurante em `/operador/ponto_de_acesso`, que lista os restaurantes cadastrados. A escolha fica na sessão (`session[:restaurante_id]`) e convive com a escolha da catraca do histórico local (#12): escolher uma catraca também define o restaurante, e trocar de restaurante descarta a catraca de outro. Sem restaurante escolhido, o terminal e as leituras redirecionam para a seleção. O topo do terminal mostra o restaurante configurado, com o link "Trocar restaurante". Cada `Acesso` registra o restaurante selecionado, e o model valida que a catraca pertence a ele.

Decisão: a seleção só é exigida quando existe algum restaurante cadastrado (`Restaurante.selecao_obrigatoria?`). Assim os cenários anteriores, que operam o terminal sem restaurantes (validação de entrada, autenticação do funcionário), continuam valendo sem mudança.

**Testes.** Os 4 cenários de `@issue_5` (`features/configuracao_ponto_acesso.feature`) passam com `--strict`, nos passos de `features/step_definitions/configuracao_ponto_acesso_steps.rb`. No RSpec, criei `spec/requests/operador/pontos_de_acesso_spec.rb` e ampliei `spec/models/acesso_spec.rb`, `spec/models/restaurante_spec.rb` e `spec/requests/autenticacao_operador_spec.rb`. Ao fim da issue: 225 exemplos, 0 falhas.

## Issue #11 — Validação de Entrada

- **Issue:** [#11 Validação de Entrada](https://github.com/Miguel-MCM/UnB_RU/issues/11) (no repositório principal, [#6](https://github.com/neatzzy/UnB_RU/issues/6))
- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Design:** frame "Terminal de Validação (US09, US10, US11)" do [Figma do projeto](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=1-314)

A issue foi desenvolvida por mim com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic, no mesmo processo das issues anteriores: TDD a partir dos cenários de `features/validacao_entrada.feature`, página no visual do Figma, branch própria, Pull Request contra a `sprint2` e card movido para In Progress. O prompt usado foi:

> Utilize TDD para desenvolver a issue #11
> Faça a página conforme o seguinte figma: https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=0-1&p=f&t=Z5Wstj7zb37w7TT8-0

O terminal em `/operador/terminal` recebe a identificação lida no QR Code. Com saldo suficiente, libera a catraca sem debitar; o débito só acontece quando a passagem é confirmada, e o botão "Confirmar passagem" faz o papel do sensor da catraca. Saldo insuficiente ou identificação desconhecida negam a entrada sem débito. O valor da refeição deixou de ser fixo: a tabela `tarifas` guarda o valor vigente, que vale R$ 4,50 enquanto nenhum outro for definido, e a recarga de saldo passou a usá-lo também.

Todo o código gerado pelo agente foi revisado por mim.

## Issue #12 — Histórico Local da Catraca

- **Issue:** [#12 Histórico Local da Catraca](https://github.com/Miguel-MCM/UnB_RU/issues/12) (no repositório principal, [#7](https://github.com/neatzzy/UnB_RU/issues/7))
- **Responsável:** Matheus ([@Matheusindio](https://github.com/Matheusindio))
- **Código:** [PR #36](https://github.com/Miguel-MCM/UnB_RU/pull/36), integrado na `sprint2` no merge [4a709d3](https://github.com/Miguel-MCM/UnB_RU/commit/4a709d3e7ae83a4ee6b043dd608df9ca1fedaccf)

**Solução.** Cada `Acesso` passou a registrar a catraca em que a leitura foi feita (migration `AddCatracaToAcessos`). A catraca gerenciada pelo operador é informada pelo parâmetro `catraca_id` (por exemplo, `/operador/historico?catraca_id=1`) e fica guardada na sessão, junto com o restaurante dela. A página `/operador/historico`, no link "Histórico Local" do cabeçalho do operador, lista os acessos dessa catraca, do mais recente para o mais antigo, com horário, matrícula, estudante, valor e status. Acessos de outras catracas não aparecem, e uma catraca sem acessos mostra a lista vazia. O terminal de validação também mostra a catraca selecionada e passa a listar o histórico dela.

**Testes.** Os 3 cenários de `@issue_7` (`features/historico_local_catraca.feature`) passam com `--strict`, nos passos de `features/step_definitions/historico_local_catraca_steps.rb`. No RSpec: `spec/requests/operador/historico_spec.rb`, e casos novos em `spec/models/acesso_spec.rb` e `spec/models/catraca_spec.rb`.

## Issue #13 — Gestão de Restaurantes e Catracas

- **Issue:** [#13 Gestão de Restaurantes e Catracas](https://github.com/Miguel-MCM/UnB_RU/issues/13) (no repositório principal, [#8](https://github.com/neatzzy/UnB_RU/issues/8))
- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Design:** frame "Gestão de Restaurantes e Catracas (US13)" do [Figma do projeto](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=1-3536)

A issue foi desenvolvida por mim com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic, no mesmo processo das issues anteriores: TDD a partir dos cenários de `features/gestao_restaurantes_catracas.feature`, página no visual do Figma, branch própria, Pull Request contra a `sprint2` e card movido para In Progress. O prompt usado foi:

> Utilize TDD para desenvolver a issue #13
> Faça a página conforme o seguinte figma: https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=0-1&p=f&t=Z5Wstj7zb37w7TT8-0

O administrador é um funcionário com a marcação `administrador`, entra pelo mesmo login do operador e é levado para `/admin/restaurantes`, onde cadastra, renomeia e remove restaurantes e as catracas de cada um. Remover um restaurante remove também as catracas dele. A escolha do restaurante na Aplicação de Controle é a issue #10; os restaurantes e catracas cadastrados aqui são os que ela vai oferecer. Para testar localmente, `bin/rails db:seed` cria o administrador de matrícula `1083921` e senha `Admin123`.

Todo o código gerado pelo agente foi revisado por mim.

## Issue #14 — Relatório Global de Acessos

- **Issue:** [#14 Relatório Global de Acessos](https://github.com/Miguel-MCM/UnB_RU/issues/14) (no repositório principal, [#9](https://github.com/neatzzy/UnB_RU/issues/9))
- **Responsável:** João Borges ([@joaopedroborges2005](https://github.com/joaopedroborges2005))
- **Código:** [PR #31](https://github.com/Miguel-MCM/UnB_RU/pull/31), integrado na `sprint2` no merge [759c4e3](https://github.com/Miguel-MCM/UnB_RU/commit/759c4e308b5998614e218e155a7bcb715195b61a)

**Solução.** O relatório fica em `/relatorio_acessos` e é restrito ao administrador. Ele lista os acessos de todos os restaurantes, com restaurante, catraca, matrícula, status e data, e permite filtrar por restaurante e por catraca e agrupar a contagem de acessos por restaurante ou por catraca. Um restaurante sem acessos mostra a lista vazia, e filtrar por uma catraca que não pertence ao restaurante escolhido mostra o aviso "A catraca … não pertence ao restaurante …". Cada `Acesso` passou a registrar também o restaurante (migration `AddRestauranteAndCatracaToAcessos`).

**Testes.** Os 7 cenários de `@issue_9` (`features/relatorio_global_acessos.feature`) passam com `--strict`, nos passos de `features/step_definitions/relatorio_global_acessos_steps.rb`. No RSpec: `spec/requests/access_reports_spec.rb`.

## Issue #15 — Cardápio da Refeição Atual

- **Issue:** [#15 Cardápio da refeição atual](https://github.com/Miguel-MCM/UnB_RU/issues/15) (no repositório principal, [#10](https://github.com/neatzzy/UnB_RU/issues/10))
- **Responsável:** João Borges ([@joaopedroborges2005](https://github.com/joaopedroborges2005))
- **Código:** [PR #30](https://github.com/Miguel-MCM/UnB_RU/pull/30), integrado na `sprint2` no merge [38370c5](https://github.com/Miguel-MCM/UnB_RU/commit/38370c5323cb3ce1bde5d8350aca2eea2964759a)

**Solução.** A página `/cardapio_atual`, para o estudante autenticado, mostra o cardápio da refeição que está sendo servida no momento: café da manhã (7:00 às 9:30), almoço (11:00 às 14:30) ou jantar (17:00 às 19:30). O almoço mostra as três opções de prato principal (padrão, ovolactovegetariana e vegana) e os acompanhamentos; o café da manhã mostra as opções de complemento e a opção extra, só quando houver; o jantar inclui a sopa e a torrada. Fora do horário das refeições, a página avisa "Não há refeição sendo servida no momento"; quando o cardápio do dia não foi cadastrado, avisa que ele não está disponível. Os cardápios ficam no model `Menu`, um por dia e refeição.

**Testes.** Os 11 cenários de `@issue_10` (`features/cardapio_refeicao_atual.feature`, contando os exemplos do esquema do cenário) passam com `--strict`, nos passos de `features/step_definitions/issue_15_cardapio_steps.rb`. No RSpec: `spec/models/menu_spec.rb` e `spec/requests/menus_spec.rb`.

## Issue #16 — Exportação em PDF do Histórico do Estudante

- **Issue:** [#16 Exportação em PDF do Histórico do Estudante](https://github.com/Miguel-MCM/UnB_RU/issues/16) (no repositório principal, [#11](https://github.com/neatzzy/UnB_RU/issues/11))
- **Responsável:** João Borges ([@joaopedroborges2005](https://github.com/joaopedroborges2005))
- **Código:** [PR #35](https://github.com/Miguel-MCM/UnB_RU/pull/35), integrado na `sprint2` no merge [181256a](https://github.com/Miguel-MCM/UnB_RU/commit/181256a99763465b8e52f015663e2b94e665eb24)

**Solução.** O botão "Exportar PDF" do extrato (`/extrato`, issue #8) baixa o extrato e o histórico de refeições em PDF, com os totais do período e só os lançamentos do próprio estudante, respeitando os filtros de período e tipo de refeição aplicados na tela. Quando não há lançamentos para os filtros, o PDF não é gerado e a página avisa "Não há registros para exportar.". Na integração, o PDF passou a ser gerado pela mesma implementação do extrato da issue #8 (`ExtratoPdf`); da branch desta issue ficaram os passos do Cucumber, o spec de request e a regra do extrato vazio (detalhes na seção "Integração da sprint2").

**Testes.** Os 5 cenários de `@issue_11` (`features/exportacao_pdf_historico_estudante.feature`) passam com `--strict`, nos passos de `features/step_definitions/historico_estudante_pdf_steps.rb`. No RSpec: `spec/requests/extrato_pdf_spec.rb` e casos novos em `spec/models/extrato_spec.rb`.

## Issue #17 — Exportação em PDF do Relatório de Operação

- **Issue:** [#17 Exportação em PDF do Relatório de Operação](https://github.com/Miguel-MCM/UnB_RU/issues/17) (no repositório principal, [#12](https://github.com/neatzzy/UnB_RU/issues/12))
- **Responsável:** João Borges ([@joaopedroborges2005](https://github.com/joaopedroborges2005))
- **Código:** [PR #34](https://github.com/Miguel-MCM/UnB_RU/pull/34), integrado na `sprint2` no merge [5558c10](https://github.com/Miguel-MCM/UnB_RU/commit/5558c105f13b731a5e8be5e48994b294e3677290)

**Solução.** No relatório global de acessos (`/relatorio_acessos`, issue #14), o administrador exporta em PDF os acessos listados, com os filtros de restaurante e catraca aplicados. O PDF, gerado com a gem `prawn` pela classe `OperationReportPdf`, traz restaurante, catraca, matrícula, status e data de cada acesso e o total exportado. Sem acessos para exportar, o PDF não é gerado e a página avisa "Não há dados para exportar".

**Testes.** Os 3 cenários de `@issue_12` (`features/exportacao_pdf_relatorio_operacao.feature`) passam com `--strict`, nos passos de `features/step_definitions/relatorio_operacao_pdf_steps.rb`. No RSpec: `spec/requests/operation_report_pdf_spec.rb`.

## Issue #19 — Inscrição Única no FastPass

- **Issue:** [#19 Inscrição Única no FastPass](https://github.com/Miguel-MCM/UnB_RU/issues/19) (no repositório principal, [#14](https://github.com/neatzzy/UnB_RU/issues/14))
- **Responsável:** João Filipe ([@joaofiulipe](https://github.com/joaofiulipe))
- **Código:** sem PR próprio. Commit [78c29ee](https://github.com/Miguel-MCM/UnB_RU/commit/78c29eea4837aed8cb33f3b087cb07876364ce0b), integrado na `sprint2` com a #22 no merge [b7c9981](https://github.com/Miguel-MCM/UnB_RU/commit/b7c998116cb7177805c182129b2838e36708db40)

A issue foi desenvolvida no mesmo loop da issue #10, com o mesmo prompt e os mesmos agentes. Nesta iteração, o testador passou também a rodar as migrations do zero, sem o `db/schema.rb`, para conferir que elas geram o schema commitado.

**Solução.** Na página "FastPass", cada time-frame tem o botão "Inscrever-se", e a página indica em qual time-frame o estudante está inscrito. Os models são `Sorteio` (um por turno e dia de refeição, com status `aberto`, `encerrado` ou `realizado`) e `InscricaoFastpass` (estudante, sorteio e time-frame, com status `inscrito`, `sorteado`, `nao_sorteado` ou `utilizado`). O índice único `[user_id, sorteio_id]` garante um único time-frame por turno, e o model recusa, com mensagem, a inscrição com sorteio encerrado, a segunda inscrição no mesmo turno e um time-frame de outro turno. A inscrição é gratuita: não mexe no saldo.

Decisão: o sorteio do dia nasce `aberto` sob demanda, na primeira inscrição (`Sorteio.do_dia!`). A inscrição trava o turno (`with_lock`), e redividir um turno que já tem inscrições é recusado. O encerramento das inscrições ficou só no model, sem tela; na #20 ele passou a acontecer quando o sorteio é realizado. O algoritmo do sorteio com peso "Pity" e o bloqueio de 24h do ER ficaram fora do escopo.

**Testes.** Os 5 cenários de `@issue_bonus_4` (`features/inscricao_unica_FastPass_bonus.feature`) passam com `--strict`, nos passos de `features/step_definitions/inscricao_unica_fastpass_steps.rb`. No RSpec, criei `spec/models/sorteio_spec.rb`, `spec/models/inscricao_fastpass_spec.rb` e `spec/requests/inscricoes_fastpass_spec.rb`, e ampliei `spec/models/turno_spec.rb` e `spec/requests/fastpass_spec.rb`. Ao fim da issue: 152 exemplos, 0 falhas.

## Issue #20 — Notificação de Sorteio

- **Issue:** [#20 Notificação de Sorteio](https://github.com/Miguel-MCM/UnB_RU/issues/20) (no repositório principal, [#15](https://github.com/neatzzy/UnB_RU/issues/15))
- **Responsável:** João Filipe ([@joaofiulipe](https://github.com/joaofiulipe))
- **Código:** sem PR próprio. Commit [b57bf15](https://github.com/Miguel-MCM/UnB_RU/commit/b57bf15ded73032e6f47daaaf9b9e83e67b86666) na branch `feat/notificacao-sorteio`, criada a partir de `feat/validacao-fastpass`

A issue foi desenvolvida no mesmo loop da issue #10, com o mesmo prompt e os mesmos agentes.

**Solução.** Uma hora antes do início de cada turno, `Sorteio.notificar_pendentes!` marca o sorteio do dia como `realizado`, o que encerra as inscrições, e cria uma `Notificacao` de "contemplado" ou "não contemplado" para cada inscrição com resultado. A mensagem do contemplado informa o time-frame. O método roda a cada minuto pelo job `NotificarSorteiosJob`, agendado no Solid Queue (`config/recurring.yml`, em development e production). O estudante vê as notificações na nova página "Notificações" do portal.

Decisões: o envio é idempotente, com um índice único por inscrição em `notificacoes`, então rodar o job várias vezes não repete o aviso. Um erro num turno é reportado (`Rails.error.report`) e não impede os demais. Realizar o sorteio no T-60 resolveu a pendência deixada pela #19, que permitia se inscrever num turno que já tinha passado. O algoritmo que escolhe os sorteados (peso "Pity") continua fora do escopo: o job só notifica inscrições que já têm resultado (`sorteado`, `nao_sorteado` ou `utilizado`). As inscrições ainda `inscrito` não são notificadas, e nos testes o resultado é definido pelos passos do Cucumber.

**Testes.** Os 5 cenários de `@issue_bonus_3` (`features/notificacoes_sorteio_bonus.feature`) passam com `--strict`, nos passos de `features/step_definitions/notificacoes_sorteio_steps.rb`. No RSpec, criei `spec/models/notificacao_spec.rb`, `spec/jobs/notificar_sorteios_job_spec.rb` e `spec/requests/notificacoes_spec.rb`, e ampliei `spec/models/sorteio_spec.rb` e `spec/models/inscricao_fastpass_spec.rb`. Com esta issue, todos os cenários do projeto passam: o Cucumber completo fica em 82/82 com `--strict` (rodado duas vezes, sem instabilidade) e o RSpec em 276 exemplos, 0 falhas.

## Issue #21 — Validação Rigorosa do FastPass

- **Issue:** [#21 Validação Rigorosa FastPass](https://github.com/Miguel-MCM/UnB_RU/issues/21) (no repositório principal, [#16](https://github.com/neatzzy/UnB_RU/issues/16))
- **Responsável:** João Filipe ([@joaofiulipe](https://github.com/joaofiulipe))
- **Código:** sem PR próprio. Commit [9304c36](https://github.com/Miguel-MCM/UnB_RU/commit/9304c36d40c175c8d6e1d5f5e7f6454628b4afe5) na branch `feat/validacao-fastpass`, criada a partir de `feat/ponto-de-acesso`

A issue foi desenvolvida no mesmo loop da issue #10, com o mesmo prompt e os mesmos agentes.

**Solução.** O terminal do operador ganhou o quadro "Entrada do FastPass", separado da leitura comum, com o botão "Validar FastPass". A leitura reaproveita o fluxo do `Acesso` da validação de entrada (#11): a leitura só libera a catraca, e o débito acontece quando a passagem é confirmada. A entrada é liberada só para o estudante sorteado num turno do restaurante do ponto de acesso (#10), dentro da janela do time-frame e com saldo suficiente. Os bloqueios novos são status do `Acesso`: `fora_do_time_frame` (chegou antes ou depois do time-frame; o terminal avisa que o estudante deve voltar para o final da fila), `sem_fastpass` (não foi sorteado) e `fastpass_utilizado` (segunda entrada). A tabela `acessos` ganhou `modalidade` (`comum` ou `fastpass`) e `inscricao_fastpass_id`. Ao confirmar a passagem, o débito e a marcação da inscrição como `utilizado` acontecem na mesma transação, com travas no acesso, na inscrição e no saldo.

Decisões: a janela é inclusiva nos dois limites (`HorarioEmMinutos#cobre?`), como pede o esquema do cenário. Quando o estudante tem mais de uma inscrição contemplada no dia, `InscricaoFastpass.contemplada_de` escolhe a do time-frame do momento, depois a do turno do momento e, por fim, a de horário mais próximo, para que quem chega fora do time-frame seja identificado como tal. O revisor-mvc encontrou um bloqueante: a nova FK de `acessos` para a inscrição não tinha regra de exclusão, e remover um restaurante ou um usuário com acesso pelo FastPass dava erro 500. A correção foi `dependent: :nullify` no model e `on_delete: :nullify` na FK, preservando o histórico de acessos.

**Testes.** Os 8 cenários de `@issue_bonus_2` (`features/validacao_FastPass_bonus.feature`: 7 cenários, um deles um esquema com dois exemplos) passam com `--strict`, nos passos de `features/step_definitions/validacao_fastpass_steps.rb`. No RSpec, criei `spec/requests/operador/acessos_fastpass_spec.rb` e ampliei `spec/models/acesso_spec.rb`, `spec/models/inscricao_fastpass_spec.rb` e `spec/models/time_frame_spec.rb`. Ao fim da issue: 251 exemplos, 0 falhas.

## Issue #22 — Gestão de Turnos e Time-frames

- **Issue:** [#22 Gestão de Turnos e Time-frames](https://github.com/Miguel-MCM/UnB_RU/issues/22) (no repositório principal, [#17](https://github.com/neatzzy/UnB_RU/issues/17)), do épico FastPass ([#18](https://github.com/Miguel-MCM/UnB_RU/issues/18); no principal, [#13](https://github.com/neatzzy/UnB_RU/issues/13))
- **Responsável:** João Filipe ([@joaofiulipe](https://github.com/joaofiulipe))
- **Código:** sem PR próprio. Commit [4f592cf](https://github.com/Miguel-MCM/UnB_RU/commit/4f592cf4ab87563e93083179500a5b17f08ca810), integrado na `sprint2` com a #19 no merge [b7c9981](https://github.com/Miguel-MCM/UnB_RU/commit/b7c998116cb7177805c182129b2838e36708db40)

A issue foi a primeira do loop descrito na issue #10: o mesmo prompt `/loop Execute uma iteração conforme docs/loop/prompt.md`, com o Claude Code e o modelo **Claude Opus 5.5**, passando pelo especificador, implementador, testador e revisor-mvc.

**Solução.** Na lista de restaurantes do administrador, o botão "Turnos" abre a tela de turnos do restaurante, onde ele cadastra um turno (nome, início e término) e divide o turno em time-frames de N minutos. Os models são `Turno` (pertence a `Restaurante`) e `TimeFrame` (pertence a `Turno`, numerado). As regras ficam no model: o término precisa ser depois do início; um turno não pode se sobrepor a outro do mesmo restaurante, e a mensagem cita o turno conflitante; a duração do time-frame não pode passar da duração do turno. `Turno#dividir_em_time_frames!` recria os time-frames com o turno travado e, se a duração for inválida, não altera nada. Para o estudante, a página "FastPass" do portal lista os time-frames de cada turno.

Decisão: os horários são guardados em minutos desde a meia-noite (colunas `hora_inicio_min` e `hora_fim_min`, concern `HorarioEmMinutos`), e não em colunas `time`, para não depender de fuso horário. A não sobreposição de turnos só é garantida pela aplicação, sem constraint no banco, o que é aceitável porque só o administrador cadastra turnos. A issue também deixou para as seguintes o helper de teste `entrar_como_estudante` e o parâmetro `{hora}` do Cucumber.

**Testes.** Os 7 cenários de `@issue_bonus_1` (`features/gestao_de_turnos_bonus.feature`) passam com `--strict`, nos passos de `features/step_definitions/gestao_de_turnos_steps.rb`. No RSpec, criei `spec/models/turno_spec.rb`, `spec/models/time_frame_spec.rb`, `spec/requests/admin/turnos_spec.rb`, `spec/requests/admin/time_frames_spec.rb` e `spec/requests/fastpass_spec.rb`, e ampliei `spec/models/restaurante_spec.rb`. Ao fim da issue: 132 exemplos, 0 falhas.

## Integração da sprint2

Antes das issues #10, #21 e #20, integrei na `sprint2` os PRs abertos do grupo e as duas primeiras issues do FastPass, e atualizei o puma por causa de alertas do bundler-audit, resolvendo os conflitos com o mesmo Claude Code. As decisões estão nas mensagens dos commits:

| Commit | O que entrou | Decisões |
|---|---|---|
| [4a709d3](https://github.com/Miguel-MCM/UnB_RU/commit/4a709d3e7ae83a4ee6b043dd608df9ca1fedaccf) | PR #36: histórico local da catraca (#12) | — |
| [22274cd](https://github.com/Miguel-MCM/UnB_RU/commit/22274cd1e7c399d3d60b72b36793d57cc7e382ca) | PR #32: extrato e histórico (#8) | Conflito no `Acesso` com o PR #36: o acesso passou a registrar a catraca e a refeição |
| [b7c9981](https://github.com/Miguel-MCM/UnB_RU/commit/b7c998116cb7177805c182129b2838e36708db40) | FastPass: #22 e #19 | Trouxe o diagrama ER, o `CLAUDE.md`, os agentes do loop e os scripts `bin/docker-run` e `bin/docker-dev`; conflito no menu do estudante (Extrato e FastPass); `db/schema.rb` regenerado |
| [759c4e3](https://github.com/Miguel-MCM/UnB_RU/commit/759c4e308b5998614e218e155a7bcb715195b61a) | PR #31: relatório global de acessos (#14) | A migration do relatório cria só `restaurante_id`, porque `catraca_id` já vinha do PR #36. Remover catraca ou restaurante anula a referência nos acessos (`nullify`) em vez de apagá-los, para não perder o histórico usado pelo extrato |
| [5558c10](https://github.com/Miguel-MCM/UnB_RU/commit/5558c105f13b731a5e8be5e48994b294e3677290) | PR #34: PDF do relatório de operação (#17) | — |
| [38370c5](https://github.com/Miguel-MCM/UnB_RU/commit/38370c5323cb3ce1bde5d8350aca2eea2964759a) | PR #30: cardápio da refeição atual (#15) | Removida a migration `CreateMenus` duplicada da branch (duas migrations com o mesmo nome impedem o `db:migrate`). O passo "que o estudante está autenticado" só era definido se um grep, rodado no carregamento, não o achasse em outro arquivo; o grep casava com o passo da recarga e o passo nunca existia. Agora ele é definido direto, com o helper `entrar_como_estudante` |
| [93fdf56](https://github.com/Miguel-MCM/UnB_RU/commit/93fdf565aa778027099fe4c56b7558b59d340ee7) | puma 8.1.1 | O puma 8.0.2 tinha 7 alertas do bundler-audit, que fariam o job `scan_ruby` do CI falhar |
| [181256a](https://github.com/Miguel-MCM/UnB_RU/commit/181256a99763465b8e52f015663e2b94e665eb24) | PR #35: PDF do histórico do estudante (#16) | Mantida a implementação do extrato do PR #32 como a única do `/extrato`. Da branch da #16 ficaram os passos do Cucumber e o spec de request (renomeado para `spec/requests/extrato_pdf_spec.rb`), adaptados a ela, e saíram o controller, a view e o PDF duplicados. Regra nova: sem lançamentos para os filtros, o PDF não é gerado e aparece "Não há registros para exportar.". Saíram também o passo duplicado de "acessou a seção de Extrato" e o bloco que definia passos via grep, e as datas fixas dos testes passaram a usar a data corrente |

Depois da integração, o Cucumber completo da `sprint2` passou com `--strict` nos 65 cenários que já tinham passos, e os 17 restantes eram as issues #10, #21 e #20, implementadas em seguida.
