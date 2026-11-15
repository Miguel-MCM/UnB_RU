# Prompt de cada iteração do loop

Uso no Claude Code (o loop decide o próprio ritmo):

```
/loop Execute uma iteração conforme docs/loop/prompt.md
```

O loop principal só **orquestra**; o trabalho é feito pelos agentes em `.claude/agents/`:
`especificador` → `implementador` → `testador` → `revisor-mvc` → (correções) → commit.
Se um agente não estiver disponível pelo nome (agentes novos só carregam ao iniciar a sessão),
lance um agente genérico passando o conteúdo do arquivo `.claude/agents/<nome>.md` como instruções.

---

Você está em um loop que implementa, uma por iteração, as issues listadas em `docs/loop/fila.md`.
As regras do projeto estão em `CLAUDE.md`.

0. **Documentação.** Item sem tag Cucumber (ex.: Wiki/ER) não usa especificador nem testador:
   o `implementador` escreve, o `revisor-mvc` confere fatos e links contra o código e o git log.
1. **Escolher.** Leia `docs/loop/fila.md` e pegue o primeiro item `[ ]`. Se não houver nenhum
   (todos `[x]` ou `[!]`), encerre o loop e faça um resumo final.
2. **Preparar.** `git status` precisa estar limpo. Crie (ou use, se já existir sem commits) a branch
   indicada no item, a partir da branch indicada no próprio item.
3. **Especificar.** Chame o `especificador` com o número da issue, a tag e o item da fila.
   Leia o plano; se ele apontar ambiguidade que muda o comportamento, decida pela leitura mais
   literal do `.feature` e registre a decisão.
4. **Implementar.** Chame o `implementador` passando o plano completo, a tag e a branch.
5. **Testar.** Chame o `testador` com a tag. Se **NÃO PRONTO**, devolva as falhas ao `implementador`
   e teste de novo.
6. **Revisar.** Chame o `revisor-mvc` pedindo a revisão do diff da issue (contra a branch de onde ela nasceu) mais as mudanças não
   commitadas. Itens **[bloqueante]** voltam para o `implementador`, seguidos de nova rodada do
   `testador`. Itens **[sugestão]**: aplique os baratos e registre os demais na fila.
7. **Limite.** Se após 3 rodadas de correção o testador ainda disser NÃO PRONTO (ou o revisor ainda
   tiver bloqueantes), marque o item `[!]`, descreva o motivo em "Bloqueios" na fila, faça commit como
   `wip: ...` e passe para o próximo.
8. **Registrar.** Marque o item `[x]` na fila (com uma linha de notas: decisões e sugestões não
   aplicadas) e faça um único commit da issue com a mensagem indicada no item. **Não faça push.**
9. **Relatar.** Uma linha: issue, branch, cenários passando, rodadas de correção e o que ficou de fora.
