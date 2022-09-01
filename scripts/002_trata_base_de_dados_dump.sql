use analise_risco;

set SQL_SAFE_UPDATES = 0;
set AUTOCOMMIT = 0;

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

alter table analise_risco.id
	rename column person_id to id_solicitante,
    rename column loan_id to id_emprestimo,
    rename column cb_id to id_historico
;

-- Vou retirar os dados que não me permite definir a coluna chave
delete from analise_risco.dados_mutuarios where coalesce(id_solicitante, ' ') = ' ';
commit;

-- Definio a coluna chave para servir de relacionamento com as outras tabelas
alter table analise_risco.dados_mutuarios add constraint pk_mutuarios primary key (id_solicitante);
alter table analise_risco.emprestimos add constraint pk_emprestimos primary key (id_emprestimo);
alter table analise_risco.historicos_banco add constraint pk_historico_banco PRIMARY KEY(id_historico);

-- Altero os tipos dessa tabela relacional para ficar do mesmo tipo das tabelas que serão cruzadas
alter table analise_risco.id  
	modify id_solicitante varchar(16),
	modify id_emprestimo varchar(16),
    modify id_historico varchar(16)
;

-- Defino as relações desta tabela
alter table analise_risco.id 
	add constraint fk_id_hist_solicitante FOREIGN KEY(id_solicitante) references analise_risco.dados_mutuarios(id_solicitante),
	add constraint fk_id_hist_emprestimo  FOREIGN KEY(id_emprestimo) references analise_risco.emprestimos(id_emprestimo),
    add constraint fk_id_hist_historico   FOREIGN KEY(id_historico) references analise_risco.historicos_banco(id_historico)
;

/* Limpeza e tratamento dos dados */

-- Tradução dos conteúdos para melhor entendimento
alter table analise_risco.dados_mutuarios MODIFY situacao_propriedade varchar(20); -- Aumento o tamanho aceito desta coluna para poder traduzir

update analise_risco.dados_mutuarios set situacao_propriedade = 'Alugada' where situacao_propriedade = 'Rent';
update analise_risco.dados_mutuarios set situacao_propriedade = 'Própria' where situacao_propriedade = 'Own';
update analise_risco.dados_mutuarios set situacao_propriedade = 'Hipotecada' where situacao_propriedade = 'Mortgage';
update analise_risco.dados_mutuarios set situacao_propriedade = 'Outros' where situacao_propriedade= 'Other';
update analise_risco.dados_mutuarios set situacao_propriedade = 'Outros' where COALESCE(situacao_propriedade, '') = ''; -- Decido jogar os valores 
commit;

update analise_risco.emprestimos set motivo = 'Pessoal' where motivo = 'Personal';
update analise_risco.emprestimos set motivo = 'Educativo' where motivo = 'Education';
update analise_risco.emprestimos set motivo = 'Médico' where motivo = 'Medical';
update analise_risco.emprestimos set motivo = 'Empreendimento' where motivo = 'Venture';
update analise_risco.emprestimos set motivo = 'Melhora do lar' where motivo = 'Homeimprovement';
update analise_risco.emprestimos set motivo = 'Pagamento de débitos' where motivo = 'Debtconsolidation';
update analise_risco.emprestimos set motivo = 'Outros' where COALESCE(motivo, '') ='';
commit;

update analise_risco.historicos_banco set flag_inadimplencia_hist = '1' where flag_inadimplencia_hist = 'Y';
update analise_risco.historicos_banco set flag_inadimplencia_hist = '0' where flag_inadimplencia_hist = 'N';
commit;

-- Estou criando uma view para as alterações realizadas nas tabelas domínio sejam refletidas automáticamente neste relacionamento
create or replace view analise_risco.base_emprestimo_analise as
select 
	cad.id_solicitante,
    emp.id_emprestimo,
    hist.id_historico,
    cad.idade_solicitante, 
    case when cad.salario_solicitante is null then round(emp.valor_solicitado / emp.percentual_renda, 0) else cad.salario_solicitante end as salario_solicitante, 
    cad.situacao_propriedade, cad.tempo_trabalhado,
    emp.motivo, emp.pontuacao, 
    case when emp.valor_solicitado is null then round(cad.salario_solicitante * percentual_renda, 0) else emp.valor_solicitado end as valor_solicitado, 
    emp.taxa_juros, emp.percentual_renda, emp.flag_inadimplencia,
    hist.anos_primeira_solicitacao, 
    case when coalesce(hist.flag_inadimplencia_hist, '') = '' then emp.flag_inadimplencia else hist.flag_inadimplencia_hist end as flag_inadimplencia_hist
from
	analise_risco.id id
inner join
	analise_risco.dados_mutuarios cad on (cad.id_solicitante = id.id_solicitante)
inner join
	analise_risco.emprestimos emp on (emp.id_emprestimo = id.id_emprestimo)
inner join
	analise_risco.historicos_banco hist on (hist.id_historico = id.id_historico)
-- order by 16 desc
;

-- Para identificar o diretório de exportação do MySQL
show variables like '%secure%';
    
-- Exportação da base
select 'id_solicitante', 'id_emprestimo', 'id_historico', 'idade_solicitante', 'salario_solicitante', 'situacao_propriedade', 'tempo_trabalhado', 'motivo', 'pontuacao', 'valor_solicitado', 'taxa_juros', 'percentual_renda', 'flag_inadimplencia', 'anos_primeira_solicitacao', 'flag_inadimplencia_hist'
union all
select * 
from analise_risco.base_emprestimo_analise into outfile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\base_emprestimo_analise.csv'
fields TERMINATED BY ';' enclosed by '"' lines TERMINATED BY '\n';

