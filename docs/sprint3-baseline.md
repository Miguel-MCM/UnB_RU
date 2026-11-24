# Sprint 3 — baseline antes da refatoração

Medido em 2026-11-24 no commit `de86247` (branch `sprint3`), via `bin/docker-run`.
É a coluna "antes" da tabela do relatório da Sprint 3.

```bash
bin/docker-run bundle exec rspec                                   # SimpleCov -> coverage/
bin/docker-run bundle exec rubycritic app --no-browser -p tmp/rubycritic
bin/docker-run bundle exec flog -a -m app                          # score por método (o que o RubyCritic usa)
bin/docker-run bundle exec rdoc -C app/models app/controllers      # % documentado
```

## Resumo

| Métrica | Antes |
|---|---|
| RubyCritic score | 93.23 |
| Cobertura RSpec total | 98.40% (739/751) |
| Cobertura models / controllers | 98.98% / 98.26% |
| Métodos com Flog ≥ 20 | 10 |
| Métodos com ABC (RuboCop) ≥ 20 | 3 |
| RDoc (models + controllers) | 10.95% documentado (68 de 79 métodos sem doc) |

## Complexidade por método (≥ 18)

Flog é a métrica de complexidade por método do RubyCritic (baseada em ABC).
ABC é o `Metrics/AbcSize` do RuboCop (`√(A² + B² + C²)`).

| Método | Arquivo | Flog | ABC |
|---|---|---|---|
| `AccessReportsController#load_report_data` | app/controllers/access_reports_controller.rb:30 | **67.7** | **48.35** |
| `OperationReportPdf#render` | app/pdfs/operation_report_pdf.rb:10 | **49.1** | **27.46** |
| `Acesso#confirmar_passagem!` | app/models/acesso.rb:97 | **42.5** | **26.93** |
| `Menu.current_meal_type` | app/models/menu.rb:7 | **27.9** | 16.31 |
| `InscricaoFastpass.contemplada_de` | app/models/inscricao_fastpass.rb:34 | **26.1** | 19.34 |
| `Operador::AcessosController#create` | app/controllers/operador/acessos_controller.rb:5 | **23.2** | 18.14 |
| `RecargasHelper#codigo_pix` | app/helpers/recargas_helper.rb:6 | **22.9** | 18.25 |
| `HorarioEmMinutos#horario` | app/models/concerns/horario_em_minutos.rb:42 | **21.0** | — |
| `InscricoesFastpassController#create` | app/controllers/inscricoes_fastpass_controller.rb:4 | **20.3** | 16.25 |
| `RecargasController#create` | app/controllers/recargas_controller.rb:11 | **20.0** | 14.04 |
| `AccessReportsController#export_pdf` | app/controllers/access_reports_controller.rb:9 | 19.7 | 15.33 |
| `ExtratoPdf#lancamentos` | app/models/extrato_pdf.rb:38 | 19.6 | 19.08 |
| `Admin::TimeFramesController#create` | app/controllers/admin/time_frames_controller.rb:3 | 19.6 | 15.17 |
| `Operador::TerminalController#show` | app/controllers/operador/terminal_controller.rb:5 | 19.2 | 16.19 |
| `Admin::CatracasController#create` | app/controllers/admin/catracas_controller.rb:5 | 18.6 | 14.18 |
| `Extrato#lancamentos_de_refeicao` | app/models/extrato.rb:93 | 18.3 | 14.25 |

## Cobertura abaixo de 100% (models e controllers)

Todos os outros arquivos de `app/models` e `app/controllers` estão com 100%.

| Arquivo | Cobertura | Linhas sem cobertura |
|---|---|---|
| app/controllers/operador/historicos_controller.rb | **87.5%** | 10 |
| app/models/inscricao_fastpass.rb | 93.8% | 55, 56, 65 |
| app/controllers/access_reports_controller.rb | 94.6% | 13, 14 |
| app/controllers/admin/catracas_controller.rb | 95.2% | 23 |
| app/controllers/admin/restaurantes_controller.rb | 96.0% | 10 |
| app/models/extrato.rb | 98.4% | 85 |
