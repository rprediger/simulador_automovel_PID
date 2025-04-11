//-------------------------------------------------------------------------
//   Controle de Velocidade PID
//   Este programa está em constante desenvolvimento por Ricardo Prediger desde 2017!
//
//   Licença:
//   Este software é distribuído sob a licença MIT. Você está
//   liberado para usá-lo e distribuí-lo livremente, desde que você mantenha o 
//   seguinte aviso em cada cópia:
//
//   "Este software foi desenvolvido por Ricardo Prediger"
//------------------------------------------------------------------------
close(winsid()); //fecha todas as janelas graficas
clc(); clear(); clearglobal(); // Limpa a tela e a memoria do scilab

// Executa scritp's auxiliares (bibliotecas)
Diretorio = get_absolute_file_path('Simulacao.sce');
exec(Diretorio + "classe Simulacao.sce");
exec(Diretorio + "classe Controlador.sce");
exec(Diretorio + "classe Veiculo.sce");
exec(Diretorio + "Resultados.sce");
exec(Diretorio + "Janela_Grafica.sce");

// Inicializa o "mundo" da simulação
Simulacao_Criar_Mundo();
Simulacao_Configurar("-DEBUG", %f);
Simulacao_Configurar("-Nome_Aluno", "Seu Nome Aqui");

// Configura a simulação
Simulacao_Configurar("-Altura_Maxima_trapezio", 30);
Simulacao_Configurar("-Altura_Maxima_Morro", 50);
Simulacao_Configurar("-Passo", 0.01);
Simulacao_Configurar("-Amplitude_Ruido", 0.000);

// Configura o Veiculo
Carro = Veiculo_Criar();
Carro = Veiculo_Configurar(Carro, "-Modelo", "Clio");
Carro = Veiculo_Configurar(Carro, "-Fabricante", "Renault");
Carro = Veiculo_Configurar(Carro, "-Potencia_Maxima_CV", 70);         //Potencia máxima do Carro (cv)
Carro = Veiculo_Configurar(Carro, "-Massa", 905);                     //Massa do Veiculo (Kg)
Carro = Veiculo_Configurar(Carro, "-Carga", 0);                       //Carga do Veiculo (Kg)
Carro = Veiculo_Configurar(Carro, "-Aceleracao_0_100", 14.5);         //Em segundos (s)
Carro = Veiculo_Configurar(Carro, "-Velocidade_Maxima", 162);         //Em Km/h
Carro = Veiculo_Configurar(Carro, "-Cx", 0.35);                       //Coeficiente aerodinâmico
Carro = Veiculo_Configurar(Carro, "-Area_Frontal", 1.97);             // Area Frontal do veiculo (m^2)
Carro = Veiculo_Configurar(Carro, "-Velocidade_Inicial", 80);         // Configura a velocidade inicial
Carro = Veiculo_Configurar(Carro, "-Velocidade_Desejada", 80);        // Configura a velocidade desejado
Carro = Veiculo_Configurar(Carro, "-Coeficiente_Ajuste_Massa", 1.5);

// Configura o Controlador
Controlador = Controlador_Criar();
Controlador = Controlador_Configurar(Controlador, "-Modo", "PID");
Controlador = Controlador_Configurar(Controlador, "-Kp", 20);
Controlador = Controlador_Configurar(Controlador, "-Ki", 10);
Controlador = Controlador_Configurar(Controlador, "-Kd", 2);

//Controlador = Controlador_Configurar(Controlador, "-Modo", "ON-OFF");
//Controlador = Controlador_Configurar(Controlador, "-Histerese", 5); // Controle ON-OFF

//Controlador = Controlador_Configurar(Controlador, "-Modo", "Proporcional");
//Controlador = Controlador_Configurar(Controlador, "-Kp", 50);
//Controlador = Controlador_Configurar(Controlador, "-S0", 10); // Controle Proporcional


// Adicionando o Controlador ao Veiculo
Carro = Veiculo_Configurar(Carro, "-Controlador", Controlador);

// Adiciona os veiculos a simulação
Simulacao_Configurar("-Veiculo", Carro);

// Limpa as variaveis que não irão ser mais utilizadas
clear Diretorio Carro Controlador

// Executa as tarefas da simulação
Executa_Simulacao();

// Exibe os resultados
Exibir_Simulacao(5);
Mostrar_Resultados_Resumido();
//Mostrar_Resultados();
