/*
drop table if exists analise_risco.ids;
drop table if exists analise_risco.dados_mutuarios;
drop table if exists analise_risco.emprestimos;
drop table if exists analise_risco.historicos_banco;
*/

use analise_risco;

-- Entender quais informações o conjunto de dados possui
select * from analise_risco.dados_mutuarios;
select * from analise_risco.emprestimos;
select * from analise_risco.historicos_banco;
select * from analise_risco.ids;

-- Analisar quais os tipos de dados
describe analise_risco.dados_mutuarios;
describe analise_risco.emprestimos;
describe analise_risco.historicos_banco;
describe analise_risco.ids;

-- Renomeando as colunas
alter table analise_risco.dados_mutuarios
	rename column person_id to id_solicitante,
	rename column person_age to idade_solicitante,
	rename column person_income to salario_solicitante,
	rename column person_home_ownership to situacao_propriedade,
	rename column person_emp_length to tempo_trabalhado
;

alter table analise_risco.emprestimos
	rename column loan_id to id_emprestimo,
    rename column loan_intent to motivo,
    rename column loan_grade to pontuacao,
    rename column loan_amnt to valor_solicitado,
    rename column loan_int_rate to taxa_juros,
    rename column loan_status to flag_inadimplencia,
    rename column loan_percent_income to percentual_renda
;

alter table analise_risco.historicos_banco
	rename column cb_id to id_historico,
    rename column cb_person_default_on_file to flag_inadimplencia_hist,
    rename column cb_person_cred_hist_length to anos_primeira_solicitacao
;

alter table analise_risco.ids
	rename column person_id to id_solicitante,
    rename column loan_id to id_emprestimo,
    rename column cb_id to id_historico
;

-- Contagens
select count(0) from analise_risco.dados_mutuarios;
select count(0) from analise_risco.emprestimos;
select count(0) from analise_risco.historicos_banco;
select count(0) from analise_risco.ids;


-- Analisar quais os tipos de dados e corrigir inconsistências
-- Dados mutuarios 
select max(id_solicitante), min(id_solicitante), count(id_solicitante), count(distinct id_solicitante) from analise_risco.dados_mutuarios; -- Tem dados de solicitantes ruins!
select * from analise_risco.dados_mutuarios where id_solicitante is null;
select * from analise_risco.dados_mutuarios where id_solicitante = ' ';
-- Entendendo que todo solicitante deve possuir um id irei retirar esses registros.
delete from analise_risco.dados_mutuarios where id_solicitante = ' ';
select * from analise_risco.dados_mutuarios;
describe analise_risco.dados_mutuarios;
select min(idade_solicitante), max(idade_solicitante) from analise_risco.dados_mutuarios; -- Possi idades estranhas :S
select idade_solicitante, count(0) from analise_risco.dados_mutuarios group by idade_solicitante order by idade_solicitante desc;
select * from analise_risco.dados_mutuarios where coalesce(salario_solicitante, 0) = 0;
select salario_solicitante, count(0) from analise_risco.dados_mutuarios group by salario_solicitante order by salario_solicitante;
select * from analise_risco.dados_mutuarios where salario_solicitante is null;
select situacao_propriedade, count(0) from analise_risco.dados_mutuarios group by situacao_propriedade;
select tempo_trabalhado, count(0) from analise_risco.dados_mutuarios group by tempo_trabalhado;
select * from analise_risco.dados_mutuarios where COALESCE(idade_solicitante, 99) < coalesce(tempo_trabalhado, 0);

-- Emprestimos
select * from analise_risco.emprestimos;
describe analise_risco.emprestimos;
select count(0), count(id_emprestimo), count(distinct id_emprestimo), max(id_emprestimo), min(id_emprestimo) from analise_risco.emprestimos;
select motivo, count(0) from analise_risco.emprestimos group by motivo;
select pontuacao, count(0) from analise_risco.emprestimos group by pontuacao;
select MAX(valor_solicitado), min(valor_solicitado), avg(valor_solicitado) from analise_risco.emprestimos;
select * from analise_risco.emprestimos where valor_solicitado is null;
select MIN(taxa_juros), max(taxa_juros), avg(taxa_juros) from analise_risco.emprestimos;
select * from analise_risco.emprestimos where taxa_juros is null;
select flag_inadimplencia, count(0) from analise_risco.emprestimos group by flag_inadimplencia;

-- Histórico bancos
select * from analise_risco.historicos_banco;
select count(id_historico), count(distinct id_historico), count(0) from analise_risco.historicos_banco;
select flag_inadimplencia_hist, count(0) from analise_risco.historicos_banco GROUP BY flag_inadimplencia_hist;
select MIN(anos_primeira_solicitacao), max(anos_primeira_solicitacao), avg(anos_primeira_solicitacao) from analise_risco.historicos_banco;
select * from analise_risco.historicos_banco order by anos_primeira_solicitacao ;

-- ID
select * from analise_risco.ids where id_solicitante is null;
select * from analise_risco.ids where id_emprestimo is null;
select * from analise_risco.ids where id_historico is null;
select * from analise_risco.ids order by id_historico;

