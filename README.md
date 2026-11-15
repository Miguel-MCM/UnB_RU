# UnB RU

Sistema de gerenciamento para o Restaurante Universitário da UnB, desenvolvido pelo Grupo 4 na disciplina de Engenharia de Software. O estudante cria a conta, recarrega o saldo e acompanha o extrato; o operador valida a entrada na catraca e debita a refeição; o administrador cadastra restaurantes, catracas e turnos e consulta o relatório de acessos.

- **Repositório principal:** [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU)
- **Documentação das features e responsáveis:** [Wiki](https://github.com/Miguel-MCM/UnB_RU/wiki)
- **Kanban:** [UnB RU](https://github.com/users/Miguel-MCM/projects/1/views/2)
- **Design:** [Figma](https://www.figma.com/design/Clozp7Rj1jOBz6l7LoT44t/UnB-RU---Engenharia-de-Software)

## Funcionalidades

### Portal do Estudante

| Funcionalidade | Endereço |
|---|---|
| Cadastro com nome, matrícula e senha | `/cadastro` |
| Login do estudante | `/login` |
| Recarga de saldo por pacote ou quantidade, via PIX (QR Code e copia e cola) ou cartão de crédito. O pagamento é simulado | `/recarga` |
| Extrato do mês, histórico de refeições e recargas com filtros, exportação em PDF e impressão | `/extrato` |
| Cardápio da refeição que está sendo servida | `/cardapio_atual` |
| FastPass: inscrição num time-frame do turno e notificações do resultado do sorteio | `/fastpass` e `/notificacoes` |

### Aplicação de Controle (operador)

| Funcionalidade | Endereço |
|---|---|
| Login do operador com matrícula SIAPE ou usuário SIGAA | `/operador/login` |
| Escolha do restaurante gerenciado (ponto de acesso) | `/operador/ponto_de_acesso` |
| Terminal de validação: lê a identificação, libera a catraca quando há saldo e debita a refeição na passagem; também valida a entrada do FastPass | `/operador/terminal` |
| Histórico local dos acessos da catraca gerenciada | `/operador/historico` |

### Administração

| Funcionalidade | Endereço |
|---|---|
| Cadastro, edição e remoção de restaurantes e catracas | `/admin/restaurantes` |
| Turnos de cada restaurante e divisão em time-frames do FastPass | botão "Turnos" em `/admin/restaurantes` |
| Relatório global de acessos com filtros por restaurante e catraca, agrupamento e exportação em PDF | `/relatorio_acessos` |

## Como rodar

### Com Ruby instalado

Requisitos: Ruby 3.3.8 (ver `.ruby-version`) e Bundler. A aplicação usa Rails 8.1 com SQLite, então não precisa de servidor de banco.

```bash
bundle install
bin/rails db:prepare   # cria o banco e roda as migrations
bin/rails db:seed      # cria o operador e o administrador de teste
bin/dev                # servidor em http://localhost:3000
```

### Com Docker, sem Ruby na máquina

```bash
bin/docker-dev                      # instala as gems, prepara o banco, roda os seeds e sobe o servidor em http://localhost:3000
bin/docker-run bundle exec rspec    # roda qualquer comando do projeto dentro do container
```

### Contas de teste

O `bin/rails db:seed` cria estas contas no ambiente de desenvolvimento:

| Perfil | Matrícula | Senha | Entrada |
|---|---|---|---|
| Operador | `1984201` | `Operador123` | `/operador/login` |
| Administrador | `1083921` | `Admin123` | `/operador/login` |

Estudantes não vêm nos seeds: crie a conta em `/cadastro` e faça uma recarga para ter saldo.

## Testes e qualidade

```bash
bin/rails db:test:prepare
bundle exec rspec          # testes unitários e de requisição em spec/
bundle exec cucumber       # cenários BDD em features/
bin/rubocop                # lint
```

Para rodar os cenários de uma única história, use a tag do arquivo `.feature`, por exemplo `bundle exec cucumber --tags @issue_6`. As tags seguem a numeração das issues do [repositório principal](https://github.com/neatzzy/UnB_RU/issues), não a das issues do fork; a correspondência está na [Wiki](https://github.com/Miguel-MCM/UnB_RU/wiki).

O CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) roda RSpec, Cucumber, RuboCop, Brakeman e bundler-audit em todo Pull Request e em todo push para a `main` e para as branches `sprint*`.
