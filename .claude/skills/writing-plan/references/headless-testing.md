# Teste de componente headless ≠ rodar o app

Referência canônica desta skill sobre o que uma verificação pode e não pode fazer.

**Rodar o app (proibido em qualquer passo do plano):** subir emulador, simulador, dispositivo físico, browser real, servidor local, suíte E2E/instrumentada, tirar screenshots ou simular interação manual. O teste funcional/visual de ponta a ponta é do usuário, feito manualmente após a entrega.

**Teste de componente headless (permitido e preferido):** montar a árvore de UI no test harness da própria stack, sem device. Valida render e interação sem executar o app.

Verificações se limitam, portanto, a análise estática, build/compile e testes que rodam no harness — unitários e de componente/widget headless.

## Detecção da capacidade

Inspecione o manifesto de dependências do projeto (`pubspec.yaml`, `package.json`, `build.gradle`, `Package.swift`…) antes de decidir. Só inclua a fase de teste de componente se houver um framework de teste headless de UI já disponível no projeto.

Se a stack não tiver esse framework, ou você não conseguir confirmá-lo pelas dependências, trate a mudança como UI-only sem testes — nunca rode o app para compensar a ausência de testes.

## Equivalências por stack

Tabela de apoio, não exaustiva: uma stack ausente daqui pode perfeitamente ter teste headless de UI — o critério é o que as dependências do projeto mostram.

| Stack | Teste de componente headless (usar) | Exige device (NÃO usar aqui) |
|-------|-------------------------------------|------------------------------|
| Flutter | `flutter test` — widget tests (`testWidgets`, `WidgetTester`) | `integration_test` |
| React / React Native | Testing Library + Jest/Vitest (jsdom) | Detox, Cypress/Playwright |
| Vue | Vue Test Utils + Vitest/Jest | Cypress/Playwright |
| Angular | TestBed + Jest/Karma | Protractor, Cypress |
| Android nativo | Compose + Robolectric (`createComposeRule`) | `androidTest` / Espresso |
| SwiftUI | ViewInspector / snapshot tests | XCUITest |
