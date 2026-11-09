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

- **Passos do Cucumber ainda não implementados não quebram o CI.** O Cucumber roda com `--no-strict`: cenários com passos indefinidos ou pendentes aparecem no log, mas o CI só falha quando um passo implementado falha. Hoje o CI mostra `82 scenarios (82 undefined)`, porque os step definitions ainda vão ser escritos.
- **Runner fixado em `ubuntu-24.04`.** O `ubuntu-latest` passou a ser o Ubuntu 26.04, que não oferece o Ruby 3.3.8. Para usar o `ubuntu-latest`, é preciso subir o Ruby do projeto para a versão 3.3 mais recente, em `.ruby-version` e no `Dockerfile`.
- **`db/schema.rb` versionado.** Sem ele, `bin/rails db:test:prepare` falha. O arquivo ainda está vazio porque não há migrations, e é atualizado sempre que alguém roda `bin/rails db:migrate`.

## Rodar localmente

```bash
bundle install
bin/rails db:test:prepare
bundle exec rspec
bundle exec cucumber --no-strict
bin/rubocop
```

Para corrigir automaticamente as ofensas do RuboCop que têm correção segura, use `bin/rubocop -a`.
