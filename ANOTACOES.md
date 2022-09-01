# Anotações de aprendizados

Utilizarei este espaço como notas sobre situações que tive dificuldades e como as resolvi

## Semana 1

### DUMP
A base de dados pode ser encontrada em script/dump-analise_risco-202207271411.sql que está em um formato _DUMP_. Aqui já começamos os trabalhos de pesquisa pois eu não havia trabalhado com um DUMP de SQL ainda, para resolver usei [este artigo da Alura](https://www.alura.com.br/artigos/restaurar-backup-banco-de-dados-mysql) que explica como realizar a importação.

### ERROR 1175

Apesar de já trabalhar com banco de dados (Oracle e SQL Server) eu não tinha me deparado com a situação que o erro 1175 do MySQL apresentava. Basicamente eu não podia excluir os registros de uma tabela sem indicar uma coluna chave.

A questão é que eu precisava justamente excluir registros duplicados de uma coluna que posteriormente seria a coluna chave.

Pra resolver, depois de uma rápida pesquisa, tive que utilizar o comando abaixo para desabilitar esta 'mensagem de segurança'

```sql
SET SQL_SAFE_UPDATES = 0
```

