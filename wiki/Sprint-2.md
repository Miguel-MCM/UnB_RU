# Sprint 2 — Integração Contínua

Sistema de gerenciamento para o Restaurante Universitário da UnB.

- **Repositório principal:** [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU)
- **Fork do grupo:** [Miguel-MCM/UnB_RU](https://github.com/Miguel-MCM/UnB_RU)
- **Kanban:** [UnB RU](https://github.com/users/Miguel-MCM/projects/1/views/2)
- **Workflow:** [`.github/workflows/ci.yml`](https://github.com/Miguel-MCM/UnB_RU/blob/sprint2/.github/workflows/ci.yml)
- **Execuções:** [GitHub Actions](https://github.com/Miguel-MCM/UnB_RU/actions/workflows/ci.yml)

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

- **Passos do Cucumber ainda não implementados não quebram o CI.** O Cucumber roda com `--no-strict`: cenários com passos indefinidos ou pendentes aparecem no log, mas o CI só falha quando um passo implementado falha. Hoje o CI mostra `82 scenarios (58 undefined, 24 passed)`: só os cenários do cadastro de usuário, da recarga de saldo, do extrato e histórico, da autenticação do funcionário, da validação de entrada e da gestão de restaurantes e catracas já têm step definitions.
- **Runner fixado em `ubuntu-24.04`.** O `ubuntu-latest` passou a ser o Ubuntu 26.04, que não oferece o Ruby 3.3.8. Para usar o `ubuntu-latest`, é preciso subir o Ruby do projeto para a versão 3.3 mais recente, em `.ruby-version` e no `Dockerfile`.
- **`db/schema.rb` versionado.** Sem ele, `bin/rails db:test:prepare` falha. O arquivo é atualizado sempre que alguém roda `bin/rails db:migrate`.

## Rodar localmente

```bash
bundle install
bin/rails db:test:prepare
bundle exec rspec
bundle exec cucumber --no-strict
bin/rubocop
```

Para corrigir automaticamente as ofensas do RuboCop que têm correção segura, use `bin/rubocop -a`.

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

## Issue #11 — Validação de Entrada

- **Issue:** [#11 Validação de Entrada](https://github.com/Miguel-MCM/UnB_RU/issues/11) (no repositório principal, [#6](https://github.com/neatzzy/UnB_RU/issues/6))
- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Design:** frame "Terminal de Validação (US09, US10, US11)" do [Figma do projeto](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=1-314)

A issue foi desenvolvida por mim com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic, no mesmo processo das issues anteriores: TDD a partir dos cenários de `features/validacao_entrada.feature`, página no visual do Figma, branch própria, Pull Request contra a `sprint2` e card movido para In Progress. O prompt usado foi:

> Utilize TDD para desenvolver a issue #11
> Faça a página conforme o seguinte figma: https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=0-1&p=f&t=Z5Wstj7zb37w7TT8-0

O terminal em `/operador/terminal` recebe a identificação lida no QR Code. Com saldo suficiente, libera a catraca sem debitar; o débito só acontece quando a passagem é confirmada, e o botão "Confirmar passagem" faz o papel do sensor da catraca. Saldo insuficiente ou identificação desconhecida negam a entrada sem débito. O valor da refeição deixou de ser fixo: a tabela `tarifas` guarda o valor vigente, que vale R$ 4,50 enquanto nenhum outro for definido, e a recarga de saldo passou a usá-lo também.

Todo o código gerado pelo agente foi revisado por mim.

## Issue #13 — Gestão de Restaurantes e Catracas

- **Issue:** [#13 Gestão de Restaurantes e Catracas](https://github.com/Miguel-MCM/UnB_RU/issues/13) (no repositório principal, [#8](https://github.com/neatzzy/UnB_RU/issues/8))
- **Responsável:** Miguel ([@Miguel-MCM](https://github.com/Miguel-MCM))
- **Design:** frame "Gestão de Restaurantes e Catracas (US13)" do [Figma do projeto](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=1-3536)

A issue foi desenvolvida por mim com o [Cursor](https://cursor.com), usando o agente com o modelo **Claude Opus 5.5**, da Anthropic, no mesmo processo das issues anteriores: TDD a partir dos cenários de `features/gestao_restaurantes_catracas.feature`, página no visual do Figma, branch própria, Pull Request contra a `sprint2` e card movido para In Progress. O prompt usado foi:

> Utilize TDD para desenvolver a issue #13
> Faça a página conforme o seguinte figma: https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software?node-id=0-1&p=f&t=Z5Wstj7zb37w7TT8-0

O administrador é um funcionário com a marcação `administrador`, entra pelo mesmo login do operador e é levado para `/admin/restaurantes`, onde cadastra, renomeia e remove restaurantes e as catracas de cada um. Remover um restaurante remove também as catracas dele. A escolha do restaurante na Aplicação de Controle é a issue #10; os restaurantes e catracas cadastrados aqui são os que ela vai oferecer. Para testar localmente, `bin/rails db:seed` cria o administrador de matrícula `1083921` e senha `Admin123`.

Todo o código gerado pelo agente foi revisado por mim.
