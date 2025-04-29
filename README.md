# 🚗 Simulador de Controle de Velocidade de Veículo com Controladores PID, Proporcional e On-Off

Este projeto consiste em um **simulador de veículos desenvolvido em Scilab**, com o objetivo de apoiar o ensino da disciplina de **Controle de Processos**, especialmente no estudo e análise de controladores como o **PID**, **Proporcional** e **On-Off**.

## 🎯 Objetivo

Proporcionar uma ferramenta interativa que auxilie alunos e professores a compreenderem o comportamento dinâmico de sistemas controlados, permitindo a análise de diferentes estratégias de controle e seus efeitos sobre o desempenho do sistema.

## ⚙️ Funcionalidades

- 💡 Simulação da dinâmica de um veículo com:
  - Controle de velocidade
  - Parâmetros ajustáveis (massa, potência, arrasto, etc.)
- 🎮 Escolha entre diferentes tipos de controladores:
  - On-Off
  - Proporcional
  - PID (Proporcional-Integral-Derivativo)
- 🛣️ Definição do caminho (trajetória/desafio) do veículo
- 📊 Interface gráfica com:
  - Gráficos em tempo real para visualização do comportamento do sistema
  - Gráficos de desempenho para análise posterior do comportamento do veículo e do controlador

## 🧪 Aplicação Educacional

O simulador é voltado para fins educacionais e pode ser utilizado como recurso didático em cursos técnicos e disciplinas de engenharia. Ele possibilita a análise de:

- Estabilidade do sistema
- Tempo de acomodação
- Sobressinal
- Erro em regime permanente
- Comportamento do veículo durante a simulação
- Influência dos parâmetros do controlador

Tudo isso de forma prática e visual, aproximando os conceitos teóricos da vivência aplicada.

## 📁 Estrutura do Projeto

| Arquivo                  | Descrição                                                                   |
|--------------------------|-----------------------------------------------------------------------------|
| `classe Veiculo.sce`     | Define o modelo matemático do veículo                                       |
| `classe Controlador.sce` | Implementa os controladores PID, Proporcional e On-Off                      |
| `classe Simulacao.sce`   | Controla a lógica geral da simulação                                        |
| `Janela_Grafica.sce`     | Responsável pela criação da interface gráfica com gráficos em tempo real    |
| `Resultados.sce`         | Gera gráficos adicionais para análise detalhada dos resultados da simulação |

## 🚀 Como Usar

1. Abra o **Scilab** (recomenda-se a versão mais recente).
2. Carregue o arquivo `Simulacao.sce` e ajuste os parâmetros da simulação do veículo e do controlador conforme necessário.
3. Execute o arquivo `Simulacao.sce` para iniciar a simulação.
4. Acompanhe os resultados na interface gráfica em tempo real ou utilize os gráficos adicionais para análise posterior.

## Tutoriais em vídeos:

[Playlist com tutoriais em vídeos de instalação e utilização do simualdor](https://youtube.com/playlist?list=PLl3NUb_DTqW-lARwtwf4ZRTvMERD2YHqY&si=bx1rUhEc4hwJquec)

## 📌 Requisitos

- [Scilab](https://www.scilab.org/) instalado no computador

## 👨‍🏫 Público-Alvo

- Estudantes e professores das áreas de Automação Industrial, Engenharia de Controle e Automação, Mecatrônica e afins
- Instituições de ensino interessadas em enriquecer o ensino de Controle de Processos com ferramentas digitais

## 📃 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

Desenvolvido para o ensino de Controle de Processos do Curso Técnico em Automação Industrial do campus Camaquã do IFSul e utilizado como base para a dissertação de mestrado:

**"Sequência Didática como Possibilidade para Potencializar as Aprendizagens em Controle de Processos no Curso Técnico em Automação Industrial"**

\
💬 *Contribuições são bem-vindas!*
