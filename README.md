# Finanças pessoais

Aplicativo Flutter para acompanhar entradas, despesas, extrato e relatórios
financeiros.

## Como executar

Com um emulador Android iniciado ou um aparelho conectado:

```powershell
flutter pub get
flutter run
```

## Armazenamento local

As transações são armazenadas em um banco SQLite (`personal_finance.db`) no
armazenamento privado do aplicativo. O app carrega os dados ao iniciar e grava
cada inclusão ou exclusão no banco; não é necessária conexão com a internet.

Na primeira inicialização, o banco recebe transações de demonstração. Elas são
inseridas uma única vez e não voltam a aparecer caso sejam excluídas.

Como o banco fica no armazenamento privado do app, desinstalar o aplicativo ou
limpar os dados dele nas configurações do Android também apaga as transações.
Esta versão não sincroniza nem faz backup em nuvem.

## Verificações

```powershell
flutter analyze
flutter test
```
