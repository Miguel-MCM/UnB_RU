# Fila do loop — Épico FastPass (#18)

Responsável: João Filipe. Cada iteração pega o **primeiro item com status `[ ]`**, implementa, e marca.
Status: `[ ]` a fazer · `[x]` feito · `[!]` bloqueado (ver "Bloqueios" no fim do arquivo).

As issues dependem umas das outras, por isso cada branch nasce da branch da issue anterior,
formando uma cadeia. A integração do grupo é a `sprint2`: a partir do item 3, a cadeia nasce da
`origin/sprint2` (os itens 1 e 2 já foram integrados nela em 181256a).

Atenção: as tags `@issue_N` dos `.feature` usam a numeração do repositório principal (neatzzy);
a numeração do fork aparece no título de cada item.

**Regressão:** Cucumber completo 82/82 com --strict (após a #20; baseline da sprint2 em 181256a
era 65); RSpec 276 exemplos, 0 falhas.

---

## [x] 1. Gestão de Turnos e Time-frames — issue #22

> **Feito.** 7/7 cenários; RSpec 132/0. Decisões: horários em minutos desde 00:00 (`*_min`,
> concern `HorarioEmMinutos`) para evitar fuso em colunas `time`; helper de teste
> `entrar_como_estudante` e ParameterType `{hora}` disponíveis para as próximas issues; página
> `/fastpass` (só leitura) pronta para receber a inscrição da #19.
> Limitação conhecida: a não sobreposição de turnos só é garantida na aplicação (sem constraint no
> banco) — aceitável porque só o administrador cadastra.

- Tag Cucumber: `@issue_bonus_1` — `features/gestao_de_turnos_bonus.feature` (7 cenários)
- Branch: `feat/gestao-de-turnos` (a partir de `dev`)
- Commit: `feat: gestão de turnos e time-frames pelo administrador (#22)`
- Notas de design:
  - `Turno` belongs_to `Restaurante`; `nome` ("almoço", "jantar", "café da manhã"), `hora_inicio`,
    `hora_fim`, `duracao_time_frame_min` (nullable). No ER: TURNO.
  - `TimeFrame` belongs_to `Turno`; `numero`, `hora_inicio`, `hora_fim`. No ER: TIME_FRAME.
  - Regras no model: término > início; sem sobreposição com outro turno do mesmo restaurante
    (mensagem citando o turno conflitante); duração do time-frame ≤ duração do turno.
  - `Turno#dividir_em_time_frames!(minutos)` recria os time-frames numa transação; se a duração for
    inválida, não altera nada.
  - Admin: `Admin::TurnosController` aninhado em restaurantes. Estudante: uma página do FastPass que
    lista os time-frames do turno (base para a issue #19).

## [x] 2. Inscrição Única no FastPass — issue #19

> **Feito.** 5/5 cenários; RSpec 152/0. Decisões: o `Sorteio` do dia nasce `aberto` sob demanda
> (`Sorteio.do_dia!`); encerrar só pelo model (`encerrar!`, sem tela); redividir um turno com
> inscrições é recusado; inscrição trava o turno (`with_lock`). Steps reaproveitáveis: "que o
> estudante ["matrícula"] está inscrito no time-frame das X às Y do <turno>" (cria o estudante se
> não existir) e "que o turno X do restaurante Y está dividido em time-frames de N minutos".
> Pendente para a #20: hoje dá para se inscrever num turno que já passou (o sorteio do dia nasce
> aberto) — encerrar as inscrições quando o sorteio for realizado (T-60) resolve.

- Tag Cucumber: `@issue_bonus_4` — `features/inscricao_unica_FastPass_bonus.feature` (5 cenários)
- Branch: `feat/inscricao-fastpass` (a partir de `feat/gestao-de-turnos`)
- Commit: `feat: inscrição única no sorteio do FastPass (#19)`
- Notas de design:
  - `Sorteio` belongs_to `Turno`; `data_refeicao`, `status` (`aberto`, `encerrado`, `realizado`);
    único por `[turno_id, data_refeicao]`. No ER: SORTEIO.
  - `InscricaoFastpass` belongs_to `User`, `Sorteio`, `TimeFrame`; `status` (`inscrito`, `sorteado`,
    `nao_sorteado`, `utilizado`); índice único `[user_id, sorteio_id]` → um time-frame por turno.
    No ER: FASTPASS_INSCRICAO.
  - Inscrição não mexe em saldo. Recusa com mensagem se o sorteio não estiver `aberto`.
  - Estudante autenticado: criar step "que o estudante {string} está autenticado" (login pela tela,
    como em `features/support/autenticacao.rb`).
  - Fora do escopo: algoritmo de sorteio com peso "Pity" e bloqueio de 24h do ER.

## [x] 3. Configuração de Ponto de Acesso — issue #10

> **Feito.** 4/4 cenários; regressão 69/69 com --strict; RSpec 225/0. A seleção de restaurante só é
> exigida quando há restaurantes (`Restaurante.selecao_obrigatoria?`); fica em `session[:restaurante_id]`
> e escolher a catraca define o restaurante. Login do operador vai direto à seleção quando ela é
> exigida. `Acesso` valida que a catraca pertence ao restaurante. Passo para a #21: "que o ponto de
> acesso está configurado para o restaurante X". Não aplicado: os passos de associação do acesso ao
> restaurante conferem pelo banco (o operador não tem tela que mostre isso).

- Tag Cucumber: `@issue_5` — `features/configuracao_ponto_acesso.feature` (4 cenários)
- Branch: `feat/ponto-de-acesso` (a partir de `origin/sprint2`)
- Commit: `feat: configuração do ponto de acesso pelo funcionário (#10)`
- Notas de design:
  - Não tinha responsável no grupo (na Sprint 1 a especificação foi do Miguel); implementada para
    fechar a entrega e porque a #21 depende dela.
  - O terminal já guarda a catraca escolhida em `session[:catraca_id]` (histórico local, #12/PR #36:
    `Operador::TerminalController`, `Operador::HistoricosController`, `current_catraca`). Leia esse
    código antes: a seleção do restaurante deve conviver com a da catraca, sem duplicar.
  - Após o login do operador, se não houver restaurante escolhido, pedir a seleção (lista dos
    restaurantes cadastrados). Guardar em sessão (`session[:restaurante_id]`), com um helper
    `current_restaurante` no concern de autenticação ou no `Operador::BaseController`.
  - Bloquear as operações de controle de acesso (leitura no terminal) sem restaurante escolhido,
    redirecionando para a seleção. Cuidado para não quebrar os cenários de `@issue_6`
    (validação de entrada), `@issue_7` (histórico local) e `@issue_9` (relatório).
  - `Acesso.registrar_leitura!` já aceita `restaurante:` (relatório #14): passar o restaurante da
    sessão; `Acesso` deve ficar associado ao restaurante selecionado.

## [x] 4. Validação Rigorosa do FastPass — issue #21

> **Feito.** 8/8 cenários; regressão 69/69; RSpec 251/0. Entrada do FastPass no terminal
> (`modalidade=fastpass` no mesmo POST de leitura); regras em `Acesso` (status `sem_fastpass`,
> `fora_do_time_frame`, `fastpass_utilizado`), escolha da inscrição em `InscricaoFastpass.contemplada_de`
> e janela inclusiva em `HorarioEmMinutos#cobre?`. Débito e inscrição `utilizado` na mesma transação
> da confirmação. Revisor achou 1 bloqueante (FK sem regra de exclusão → 500 ao remover restaurante
> ou usuário com acesso FastPass), corrigido com `dependent: :nullify` + `on_delete: :nullify`.
> Não aplicado: relatórios mostram o status cru (pré-existente). Passo reaproveitável pela #20:
> "que o estudante "X" (não )?foi sorteado para o FastPass do <turno>[ no time-frame das A às B]".

- Tag Cucumber: `@issue_bonus_2` — `features/validacao_FastPass_bonus.feature` (7 cenários, 8 com o esquema)
- Branch: `feat/validacao-fastpass` (a partir de `feat/ponto-de-acesso`)
- Commit: `feat: validação rigorosa do FastPass na catraca (#21)`
- Notas de design:
  - Reaproveitar o fluxo de `Acesso` (leitura → `liberado` → `confirmar_passagem!` debita).
    Adicionar `modalidade` (`comum`, `fastpass`) e `inscricao_fastpass_id` opcional em `acessos`,
    e novos status de bloqueio (fora do time-frame, sem FastPass, FastPass já utilizado).
  - Janela inclusiva: `hora_inicio <= agora <= hora_fim` do time-frame sorteado.
  - Ao confirmar a passagem, marcar a inscrição como `utilizado` (bloqueia a 2ª entrada).
  - Terminal: uma "entrada do FastPass" no terminal do operador (botão/campo separado ou modo),
    sem quebrar os cenários de `@issue_6` (validação comum).
  - "Ponto de acesso configurado para o restaurante" usa a seleção de restaurante da #10 (item 3):
    reaproveite os passos dela.
  - O `Acesso` já tem `refeicao`, `catraca` e `restaurante` (PRs #32, #36, #31): use-os.
  - Reaproveitar os steps de `validacao_entrada_steps.rb` (saldo, tarifa, liberação, débito).

## [x] 5. Notificação de Sorteio — issue #20

> **Feito.** 5/5 cenários; Cucumber completo 82/82 com --strict (rodado 2x, sem flakiness); RSpec
> 276/0. `Sorteio.notificar_pendentes!` (job `NotificarSorteiosJob`, a cada minuto em production e
> development) realiza o sorteio no T-60 — o que encerra as inscrições (pendência herdada da #19) —
> e cria uma `Notificacao` por inscrição com resultado (índice único, idempotente). Inscrições ainda
> "inscrito" não são notificadas (Pity fora do escopo). Página "Notificações" no portal. Erro num
> turno não trava os outros (Rails.error.report). Não aplicado: steps também conferem o banco;
> savepoint só seria necessário em PostgreSQL.

- Tag Cucumber: `@issue_bonus_3` — `features/notificacoes_sorteio_bonus.feature` (5 cenários)
- Branch: `feat/notificacao-sorteio` (a partir de `feat/validacao-fastpass`)
- Commit: `feat: notificação do resultado do sorteio do FastPass (#20)`
- Notas de design:
  - `Notificacao` belongs_to `User` e `InscricaoFastpass`; `tipo` (`contemplado`, `nao_contemplado`),
    `mensagem`, `lida`; única por inscrição. No ER: NOTIFICACAO.
  - `Sorteio.notificar_pendentes!(agora = Time.current)`: notifica inscrições de turnos que começam
    em até 60 min e ainda não foram notificadas. Idempotente.
  - Disparo periódico: job `NotificarSorteiosJob` registrado em `config/recurring.yml` (Solid Queue).
    No Cucumber, "Quando o horário atual for HH:MM" = `travel_to` + chamar o método do model.
  - Estudante vê as notificações no portal (mensagem do contemplado cita o time-frame).
  - Herdado da #19: realizar o sorteio (status `realizado`) no T-60 deve encerrar as inscrições;
    validar/ocultar a inscrição em turno que já começou. Testar os status `sorteado`/`nao_sorteado`.

## [x] 6. Wiki e diagrama ER — documentação da entrega

> **Feito.** `wiki/Sprint-2.md`: seções das issues #10, #22, #19, #21 e #20 e da integração da
> sprint2. `docs/modelo-er.md`: diagrama refeito a partir do `db/schema.rb` (13 tabelas) e lista de
> diferenças em relação ao modelo original. Revisor conferiu hashes, issues, números e o diagrama;
> 2 fatos errados e links para branches corrigidos antes do commit.

- Sem tag Cucumber (só documentação). Branch: `docs/wiki-fastpass` (a partir de `feat/notificacao-sorteio`).
- Commit: `docs: registra o FastPass e a #10 na wiki e atualiza o diagrama ER`
- `wiki/Sprint-2.md`: uma seção por issue (#10, #22, #19, #21, #20), no mesmo formato das seções
  existentes (#6 a #13 e as do João): link da issue no fork e no repositório principal, link do PR
  (a integração foi feita direto na `sprint2`; cite os commits), solução adotada, testes (RSpec e
  Cucumber, com números), e o relato de uso de IA — Claude Code (modelo Claude Opus 5.5) com o loop
  de `docs/loop/` e os agentes de `.claude/agents/` (especificador, implementador, testador,
  revisor-mvc), citando o prompt do loop. Registrar também as decisões da integração da `sprint2`
  (mensagens dos merges em `origin/sprint2`).
- `docs/modelo-er.md`: atualizar para o schema real (`db/schema.rb`): tabela `menus` (cardápio), as
  colunas `restaurante_id`, `catraca_id` e `refeicao` em `acessos`, e as tabelas do FastPass como
  implementadas (`turnos`, `time_frames`, `sorteios`, `inscricoes_fastpass`, `notificacoes`, horários
  em minutos). Marcar o que do ER original ficou fora do escopo (ex.: Pity, bloqueio de 24h).

---

## Bloqueios

(O loop registra aqui o que impediu uma issue de ficar pronta.)
