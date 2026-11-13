# Fila do loop — Épico FastPass (#13)

Responsável: João Filipe. Cada iteração pega o **primeiro item com status `[ ]`**, implementa, e marca.
Status: `[ ]` a fazer · `[x]` feito · `[!]` bloqueado (ver "Bloqueios" no fim do arquivo).

As issues dependem umas das outras, por isso cada branch nasce da branch da issue anterior
(a primeira nasce da `dev`), formando uma cadeia — mesmo esquema usado pelo resto do grupo.

---

## [x] 1. Gestão de Turnos e Time-frames — issue #17

> **Feito.** 7/7 cenários; RSpec 132/0. Decisões: horários em minutos desde 00:00 (`*_min`,
> concern `HorarioEmMinutos`) para evitar fuso em colunas `time`; helper de teste
> `entrar_como_estudante` e ParameterType `{hora}` disponíveis para as próximas issues; página
> `/fastpass` (só leitura) pronta para receber a inscrição da #14.
> Limitação conhecida: a não sobreposição de turnos só é garantida na aplicação (sem constraint no
> banco) — aceitável porque só o administrador cadastra.

- Tag Cucumber: `@issue_bonus_1` — `features/gestao_de_turnos_bonus.feature` (7 cenários)
- Branch: `gestao-de-turnos` (a partir de `dev`)
- Commit: `feat: gestão de turnos e time-frames pelo administrador (#17)`
- Notas de design:
  - `Turno` belongs_to `Restaurante`; `nome` ("almoço", "jantar", "café da manhã"), `hora_inicio`,
    `hora_fim`, `duracao_time_frame_min` (nullable). No ER: TURNO.
  - `TimeFrame` belongs_to `Turno`; `numero`, `hora_inicio`, `hora_fim`. No ER: TIME_FRAME.
  - Regras no model: término > início; sem sobreposição com outro turno do mesmo restaurante
    (mensagem citando o turno conflitante); duração do time-frame ≤ duração do turno.
  - `Turno#dividir_em_time_frames!(minutos)` recria os time-frames numa transação; se a duração for
    inválida, não altera nada.
  - Admin: `Admin::TurnosController` aninhado em restaurantes. Estudante: uma página do FastPass que
    lista os time-frames do turno (base para a issue #14).

## [ ] 2. Inscrição Única no FastPass — issue #14

- Tag Cucumber: `@issue_bonus_4` — `features/inscricao_unica_FastPass_bonus.feature` (5 cenários)
- Branch: `inscricao-fastpass` (a partir de `gestao-de-turnos`)
- Commit: `feat: inscrição única no sorteio do FastPass (#14)`
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

## [ ] 3. Validação Rigorosa do FastPass — issue #16

- Tag Cucumber: `@issue_bonus_2` — `features/validacao_FastPass_bonus.feature` (7 cenários, 8 com o esquema)
- Branch: `validacao-fastpass` (a partir de `inscricao-fastpass`)
- Commit: `feat: validação rigorosa do FastPass na catraca (#16)`
- Notas de design:
  - Reaproveitar o fluxo de `Acesso` (leitura → `liberado` → `confirmar_passagem!` debita).
    Adicionar `modalidade` (`comum`, `fastpass`) e `inscricao_fastpass_id` opcional em `acessos`,
    e novos status de bloqueio (fora do time-frame, sem FastPass, FastPass já utilizado).
  - Janela inclusiva: `hora_inicio <= agora <= hora_fim` do time-frame sorteado.
  - Ao confirmar a passagem, marcar a inscrição como `utilizado` (bloqueia a 2ª entrada).
  - Terminal: uma "entrada do FastPass" no terminal do operador (botão/campo separado ou modo),
    sem quebrar os cenários de `@issue_6` (validação comum).
  - "Ponto de acesso configurado para o restaurante" é a issue #5 (não implementada e não é sua):
    o step só cria o restaurante; não implementar a #5.
  - Reaproveitar os steps de `validacao_entrada_steps.rb` (saldo, tarifa, liberação, débito).

## [ ] 4. Notificação de Sorteio — issue #15

- Tag Cucumber: `@issue_bonus_3` — `features/notificacoes_sorteio_bonus.feature` (5 cenários)
- Branch: `notificacao-sorteio` (a partir de `validacao-fastpass`)
- Commit: `feat: notificação do resultado do sorteio do FastPass (#15)`
- Notas de design:
  - `Notificacao` belongs_to `User` e `InscricaoFastpass`; `tipo` (`contemplado`, `nao_contemplado`),
    `mensagem`, `lida`; única por inscrição. No ER: NOTIFICACAO.
  - `Sorteio.notificar_pendentes!(agora = Time.current)`: notifica inscrições de turnos que começam
    em até 60 min e ainda não foram notificadas. Idempotente.
  - Disparo periódico: job `NotificarSorteiosJob` registrado em `config/recurring.yml` (Solid Queue).
    No Cucumber, "Quando o horário atual for HH:MM" = `travel_to` + chamar o método do model.
  - Estudante vê as notificações no portal (mensagem do contemplado cita o time-frame).

---

## Bloqueios

(O loop registra aqui o que impediu uma issue de ficar pronta.)
