# Prompt de cada iteração do loop

Uso no Claude Code (o loop decide o próprio ritmo):

```
/loop Execute uma iteração conforme docs/loop/prompt.md
```

---

Você está em um loop que implementa, uma por iteração, as issues listadas em `docs/loop/fila.md`.
Siga `CLAUDE.md` à risca (MVC, convenções, testes, definição de pronto).

1. **Escolher.** Leia `docs/loop/fila.md` e pegue o primeiro item `[ ]`. Se não houver nenhum
   (todos `[x]` ou `[!]`), encerre o loop e faça um resumo final do que foi feito.
2. **Preparar.** `git status` precisa estar limpo. Crie a branch indicada no item a partir da branch
   da issue anterior (a primeira a partir da `dev`). Rode
   `bin/docker-run bundle exec cucumber --strict --no-snippets --tags <tag>` e veja os passos indefinidos.
3. **Ler.** O `.feature` da issue, `docs/modelo-er.md`, os steps existentes em
   `features/step_definitions/` e o código relacionado. Não altere o `.feature`.
4. **Vermelho.** Escreva os step definitions da issue (reaproveitando os existentes) e os specs RSpec
   dos models/controllers novos. Confirme que falham pelo motivo certo.
5. **Verde.** Implemente na ordem migration → model (regras) → rotas → controller → view.
   Gere migrations com `RAILS_ENV=development bin/docker-run bin/rails ...` e rode
   `db:migrate` para atualizar `db/schema.rb`.
6. **Verificar.** Rode tudo da "Definição de pronto" do `CLAUDE.md`. Se algo falhar, corrija e repita.
   Se após 3 tentativas de correção do mesmo problema ainda falhar, marque o item `[!]`, descreva o
   problema em "Bloqueios" na fila, faça commit do que tiver como `wip: ...` e vá para o próximo.
7. **Revisar.** Releia o diff (`git diff dev...HEAD`) procurando regra de negócio no controller ou na
   view, duplicação de steps, código morto e mensagens fora do `pt-BR.yml`. Corrija.
8. **Registrar.** Marque o item `[x]` na fila e faça um único commit da issue com a mensagem indicada
   (inclua a atualização da fila). **Não faça push** — o push é feito pelo João.
9. **Relatar.** Uma linha: issue, branch, cenários passando, e o que ficou de fora (se algo).
