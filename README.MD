# UnB RU

---

Sistema de gerenciamento para o Restaurante Universitário da UnB.

# Repositório forked

https://github.com/neatzzy/UnB_RU/issues

# Ambiente de desenvolvimento

Requisitos: Ruby 3.3.8 (ver `.ruby-version`) e Bundler. A aplicação usa Rails 8.1 com SQLite.

```bash
bundle install
bin/rails db:prepare
bin/dev                  # servidor em http://localhost:3000
```

# Testes

```bash
bundle exec cucumber                  # cenários BDD em features/
bundle exec cucumber --tags @issue_6  # uma história específica
bundle exec rspec                     # testes unitários em spec/
bin/rubocop                           # lint
```
