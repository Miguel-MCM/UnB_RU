# UnB RU — regras do projeto

Sistema do Restaurante Universitário da UnB. Rails 8.1, SQLite, Hotwire (Turbo + Stimulus), importmap.
Issues: https://github.com/Miguel-MCM/UnB_RU/issues (numeração do fork; no repositório principal neatzzy/UnB_RU os números são outros) — especificações BDD em `features/*.feature` (`# language: pt`).

## Arquitetura (MVC — obrigatório)

- **Model** (`app/models`): toda regra de negócio. Validações, cálculos, transições de estado e
  operações que alteram mais de um registro ficam em métodos do model, com `!` quando persistem
  (ex.: `Acesso.registrar_leitura!`, `Acesso#confirmar_passagem!`, `User#recarregar!`).
  Use `transaction` / `with_lock` quando mexer em saldo ou em mais de uma tabela.
  Se uma regra envolver vários models e não couber naturalmente em nenhum, crie um PORO em
  `app/models` (como `LoginOperador`) — não crie `app/services`.
- **Controller** (`app/controllers`): só recebe parâmetros (`params.expect`), chama o model e
  redireciona/renderiza. Sem regra de negócio, sem cálculo, sem query complexa (use scopes).
  - Área do estudante: controllers na raiz, `before_action :require_login`.
  - Terminal de catraca: `Operador::` (herda `Operador::BaseController`).
  - Administração: `Admin::` (herda `Admin::BaseController`).
  - Autenticação vem do concern `Authentication` (`current_user`, `current_funcionario`).
- **View** (`app/views`): ERB sem lógica de negócio. Reaproveite `shared/_field`, `layouts/_flash`,
  o helper `icon(...)` e as classes CSS existentes (`card`, `button button--primary`, ...).

## Convenções

- Domínio em **português**: models, tabelas, colunas, rotas e mensagens (`Restaurante`, `Catraca`,
  `Acesso`, `hora_inicio`). Exceção: `User` (já existente).
- Dinheiro sempre em **centavos inteiros** (`*_centavos`), nunca float/decimal.
- Status e tipos com `enum` de string (veja `Acesso`).
- Mensagens de erro de validação em `config/locales/pt-BR.yml`, não hardcoded no model.
- O modelo de dados alvo está em `docs/modelo-er.md`. Siga-o, adaptando aos nomes que já existem no
  código (ex.: no código, funcionário é o model `Funcionario`, não um `papel` em `User`).
- Uma migration por mudança de schema; sempre commitar o `db/schema.rb` atualizado.

## Testes

Não há Ruby instalado na máquina: tudo roda no container oficial via `bin/docker-run`
(gems no volume Docker `unb_ru_bundle`; `RAILS_ENV` padrão é `test`).

```bash
bin/docker-run bash -c "bundle install --quiet && bin/rails db:test:prepare"
bin/docker-run bundle exec rspec
bin/docker-run bundle exec cucumber --strict --no-snippets --tags @issue_bonus_1   # uma issue
bin/docker-run bundle exec cucumber --no-strict --no-snippets                      # tudo (pendentes não falham)
bin/docker-run bin/rubocop
bin/docker-run bin/brakeman --no-pager -q
RAILS_ENV=development bin/docker-run bin/rails generate migration CreateTurnos ...
RAILS_ENV=development bin/docker-run bin/rails db:migrate   # atualiza db/schema.rb
```

- **Cucumber** (`features/step_definitions/<nome_da_feature>_steps.rb`): testa pela interface
  (Capybara), como os steps existentes. **Não altere os `.feature`** — eles são a especificação
  entregue na Sprint 1. Antes de criar um step, procure um equivalente em `features/step_definitions/`
  e reaproveite. Helpers de login em `features/support/autenticacao.rb`; parâmetro `{reais}` em
  `features/support/parametros.rb`. Para controlar o relógio use `travel_to`.
- **RSpec**: `spec/models/<model>_spec.rb` para cada model novo e `spec/requests/` para cada controller novo.

## Definição de pronto (por issue)

1. Todos os cenários da tag da issue passam com `--strict`.
2. RSpec inteiro verde; nenhum cenário que passava antes quebrou.
3. RuboCop sem ofensas e Brakeman sem alertas.
4. Código respeita as regras MVC acima.
5. Commit no padrão do repositório: `feat: <descrição> (#N)` em português.
