from fastapi import FastAPI
import pandas as pd

app = FastAPI()

# Importação dos modelos
one_hot_encoder = pd.read_pickle('../modelos/ohe.pkl')
scaler = pd.read_pickle('../modelos/scaler.pkl')
gbc = pd.read_pickle('../modelos/gbc_boost.pkl')

# Criação da URL de requisição
@app.get('/modelo/idade={idade}&salario={salario}&propriedade={propriedade}&tempo_trabalho={tempo_trabalho}&motivo={motivo}&pontuacao={pontuacao}&valor_solicitado={valor_solicitado}&taxa_juros={taxa_juros}&anos_prim={anos_prim}&inad_hist={inad_hist}')


# Função que retorna o resultado do modelo
def teste_idade(idade, salario, propriedade, tempo_trabalho, motivo, pontuacao, valor_solicitado,
                taxa_juros, anos_prim, inad_hist):
    parametros = {
        'idade_solicitante': [float(idade)],
        'salario_solicitante': [float(salario)],
        'situacao_propriedade': [propriedade],
        'tempo_trabalhado': [float(tempo_trabalho)],
        'motivo': [motivo],
        'pontuacao': [pontuacao],
        'valor_solicitado': [float(valor_solicitado)],
        'taxa_juros': [float(taxa_juros)],
        'anos_primeira_solicitacao': [float(anos_prim)],
        'flag_inadimplencia_hist': [inad_hist]
    }

    dados = pd.DataFrame(parametros)
    # Transforma as colunas
    dados = pd.DataFrame(one_hot_encoder.transform(dados), columns=one_hot_encoder.get_feature_names_out())
    # Aplica a normalização das escalas
    dados = pd.DataFrame(scaler.transform(dados), columns=one_hot_encoder.get_feature_names_out())

    return {
        'resultado': gbc.predict(dados)[0],
        'probabilidade_nao': gbc.predict_proba(dados).tolist()[0][0],
        'probabilidade_sim': gbc.predict_proba(dados).tolist()[0][1]
    }