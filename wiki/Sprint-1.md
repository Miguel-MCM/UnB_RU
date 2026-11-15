# Sprint 1 — Especificação BDD

Sistema de gerenciamento para o Restaurante Universitário da UnB.

- **Repositório principal:** [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU)
- **Fork do grupo:** [Matheusindio/UnB_RU](https://github.com/Matheusindio/UnB_RU)
- **Branch de entrega:** [`sprint1`](https://github.com/Matheusindio/UnB_RU/tree/sprint1)
- **Release:** [`Release`](https://github.com/Matheusindio/UnB_RU/releases/tag/Release)

## Objetivo da sprint

Estudar as histórias de usuário descritas nas issues do repositório principal e especificar os testes de aceitação de cada uma como cenários BDD com Cucumber, em Gherkin (`# language: pt`).

## Equipe

| Membro | GitHub | Responsabilidade |
|---|---|---|
| Matheus | [@Matheusindio](https://github.com/Matheusindio) | Issues #1 a #4 |
| Miguel | [@Miguel-MCM](https://github.com/Miguel-MCM) | Issues #5 a #8 |
| João Borges | — | Issues #9 a #12 |
| João Filipe | [@joaofiulipe](https://github.com/joaofiulipe) | Issues bônus #14 a #17 |

**Monitores:** Élvis e Rafael

## Histórias especificadas

Cada arquivo `.feature` está marcado com a tag da issue correspondente (`@issue_N`). Os arquivos das histórias bônus também têm a tag `@bonus`.

| Issue | História | Prioridade | Arquivo | Cenários |
|---|---|---|---|---|
| [#1](https://github.com/neatzzy/UnB_RU/issues/1) | Cadastro de Usuário | MVP | `cadastro_de_usuario.feature` | 3 |
| [#2](https://github.com/neatzzy/UnB_RU/issues/2) | Recarga de Saldo | MVP | `recarga_de_saldo.feature` | 4 |
| [#3](https://github.com/neatzzy/UnB_RU/issues/3) | Extrato e Histórico | — | `extrato_e_historico.feature` | 3 |
| [#4](https://github.com/neatzzy/UnB_RU/issues/4) | Autenticação do Funcionário | MVP | `autenticacao_do_funcionario.feature` | 3 |
| [#5](https://github.com/neatzzy/UnB_RU/issues/5) | Configuração de Ponto de Acesso | — | `configuracao_ponto_acesso.feature` | 4 |
| [#6](https://github.com/neatzzy/UnB_RU/issues/6) | Validação de Entrada | MVP | `validacao_entrada.feature` | 5 |
| [#7](https://github.com/neatzzy/UnB_RU/issues/7) | Histórico Local da Catraca | — | `historico_local_catraca.feature` | 3 |
| [#8](https://github.com/neatzzy/UnB_RU/issues/8) | Gestão de Restaurantes e Catracas | MVP | `gestao_restaurantes_catracas.feature` | 6 |
| [#9](https://github.com/neatzzy/UnB_RU/issues/9) | Relatório Global de Acessos | — | `relatorio_global_acessos.feature` | 7 |
| [#10](https://github.com/neatzzy/UnB_RU/issues/10) | Cardápio da Refeição Atual | — | `cardapio_refeicao_atual.feature` | 9 |
| [#11](https://github.com/neatzzy/UnB_RU/issues/11) | Exportação em PDF do Histórico do Estudante | — | `exportacao_pdf_historico_estudante.feature` | 5 |
| [#12](https://github.com/neatzzy/UnB_RU/issues/12) | Exportação em PDF do Relatório de Operação | — | `exportacao_pdf_relatorio_operacao.feature` | 3 |

### Épico bônus: FastPass ([#13](https://github.com/neatzzy/UnB_RU/issues/13))

| Issue | História | Arquivo | Cenários |
|---|---|---|---|
| [#14](https://github.com/neatzzy/UnB_RU/issues/14) | Inscrição Única no FastPass | `inscricao_unica_FastPass_bonus.feature` | 5 |
| [#15](https://github.com/neatzzy/UnB_RU/issues/15) | Notificação de Sorteio | `notificacoes_sorteio_bonus.feature` | 5 |
| [#16](https://github.com/neatzzy/UnB_RU/issues/16) | Validação Rigorosa do FastPass | `validacao_FastPass_bonus.feature` | 7 |
| [#17](https://github.com/neatzzy/UnB_RU/issues/17) | Gestão de Turnos e Time-frames | `gestao_de_turnos_bonus.feature` | 7 |

**Total:** 16 funcionalidades e 79 cenários, dos quais 55 são das issues regulares e 24 são bônus.

## Organização do repositório

```
features/   # especificações BDD (.feature), uma por história de usuário
scripts/    # script de criação de usuários aleatórios (fornecido pelo repositório principal)
cardapio.json
```

## Fluxo de trabalho

1. Cada membro criou uma branch `especificacoes-bdd-<nome>` para as issues sob sua responsabilidade.
2. As branches foram integradas na branch `sprint1` por meio de Pull Requests no fork.
3. A tag de Release foi criada e um Pull Request da `sprint1` foi aberto no repositório principal.

## Executar e filtrar os cenários

Nesta sprint entregamos só as especificações. As definições de passos (step definitions) ficam para as próximas sprints. Para listar os cenários e ver os passos ainda não implementados:

```bash
cucumber --dry-run                 # todos os cenários
cucumber --tags @issue_6           # uma história específica
cucumber --tags "not @bonus"       # apenas as histórias regulares
```
