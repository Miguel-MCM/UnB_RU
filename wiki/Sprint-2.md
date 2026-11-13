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

- **Passos do Cucumber ainda não implementados não quebram o CI.** O Cucumber roda com `--no-strict`: cenários com passos indefinidos ou pendentes aparecem no log, mas o CI só falha quando um passo implementado falha. Hoje o CI mostra `82 scenarios (75 undefined, 7 passed)`: só os cenários do cadastro de usuário e da recarga de saldo já têm step definitions.
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
