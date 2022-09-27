![Status](https://img.shields.io/badge/status-Em%20desenvolvimento-green?style=plastic)
[![Commits semanais](https://img.shields.io/github/commit-activity/w/exata0mente/alura_cash?style=plastic)](https://github.com/exata0mente/alura_cash/pulse)


# Challenge: Data Science Alura 2

Neste repositório postarei o meu progresso no 2º Challenge de Data Science da Alura. Se desejar, o meu progresso no 1ª Challenge pode ser encontrado [aqui](https://github.com/exata0mente/alura-voz)

## O desafio

Fui contratado cientista de dados para trabalhar em um banco digital internacional chamado **Alura Cash**. Na primeira reunião do meu novo trabalho, a diretoria financeira informa que, recorrentemente, **estão surgindo pessoas inadimplentes após a liberação de créditos**. Portanto, é solicitada uma solução para que seja possível **diminuir as perdas financeiras** por conta de pessoas mutuarias que não quitam suas dívidas.

É então sugerido um estudo das informações financeiras e de solicitação de empréstimo para encontrar padrões que possam indicar uma possível inadimplência.

Desse modo, solicito um conjunto de dados que contenha as informações de clientes, da solicitação de empréstimo, do histórico de crédito, bem como se a pessoa mutuaria é inadimplente ou não. Com esses dados, consigo modelar um classificador capaz de encontrar potenciais clientes inadimplentes e solucionar o problema do Alura Cash.

O desafio será dividio em 4 partes (semanas):
1. [**Tratamento de dados: entendendo como tratar dados com SQL**](#parte-1-tratamento-de-dados-entendendo-como-tratar-dados-com-SQL)

Abaixo destaco os pontos importantes de cada uma das etapas e os 'perrengues' vou deixar em minhas [anotações](ANOTACOES.md).

## Etapas

### Parte 1: Tratamento de dados: entendendo como tratar dados com SQL

#### Ferramentas utilizadas

- `MySQL`

#### Os dados brutos

A base de dados pode ser encontrada em script/dump-analise_risco-202207271411.sql que está em um formato _DUMP_. 

O dicionário de dados pode ser consultado [aqui](https://github.com/Mirlaa/Challenge-Data-Science-1ed/blob/main/Dados/README.md).

#### O desenvolvimento

Após carregado o arquivo _DUMP_, optei por traduzir as colunas e os conteúdos e realizar pequenos tratamentos nos dados. Minha ideia nessa fase é apenas deixar os dados devidamente disponíveis para a etapa seguinte.

Realizei então:
- Tradução das colunas
- Tradução dos conteúdos
- Limpeza dos campos elegíveis a chave primária
- Adequação dos tamanhos dos campos de algumas tabelas
- Criação das chaves primárias e estrangeiras (apesar de não ser estritamente necessária)
- Exportar o arquivo como CSV para uso posterior

Aqui precisei tomar uma decisão sobre alguns campos categóricos com valores nulos.

Na tabela `dados_mutuarios` há uma coluna com nome `situacao_propriedade` que possuia várias situações entre elas a opção _Outros_. Aqui eu decidi então classificar os campos faltantes como _Outros_ e assim manter estes registros utilizáveis.

O mesmo eu fiz para a tabela `emprestimos` coluna `motivo`. Aqui porém não havia a opção _Outros_ então decidi criar essa classificação para esses valores faltantes.

#### Resultados

O script de tratamento, a _view_ resultante e o arquivo gerado podem ser consultados na pasta de [dados](dados/)

### Parte 2 - Aprendendo com os dados: criando um modelo de previsão de inadimplência

Tendo a base pronta para uso, retirei da base de estudos os registros que possuiam valores nulo e/ou outliers. Estes registros separo em uma base apartada para utilizar como mais um avaliador do modelo (a ideia é preencher os campos nulos, premissas ainda a definir, e testar o modelo). 
Identificamos uma correlação de inadimplência com as variáveis de situação da propriedade (Alugada), taxa de juros (quanto maior a taxa, maior a correlação) e classificações baixas (sendo A a mais alta e G a mais baixa).
Antes da construção do modelo, decidimos normalizar os dados pois há grandes diferenças nos campos que referem-se a valores financeiros como salário e valor de empréstimo solicitado. A normalização se fez necessária para não enviesarmos o algoritmo.

Feito isso, testamos 3 algoritmos de *machine learning*: *Random Forest, Gradient Boost, Logistic Regression*

O que apresentou melhor resultado foi o *Gradient Boost*. Todos os modelos gerados foram salvos no diretório de [modelos](modelos/)



