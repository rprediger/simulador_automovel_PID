//-------------------------------------------------------------------------
//   Controle de Velocidade PID
//   Este programa está em constante desenvolvimento por Ricardo Prediger desde 2017!
//   Para informações de contato, por favor entrar em contato com:
//   ricardoprediger@gmail.com
//
//   Licença:
//   Este software é distribuído sob a licença MIT. Você está
//   liberado para usá-lo e distribuí-lo livremente, desde que você mantenha o 
//   seguinte aviso em cada cópia:
//
//   "Este software foi desenvolvido por Ricardo Prediger"
//------------------------------------------------------------------------
global Simulacao; //Cria a varivel global contendo toda a simulação

function Simulacao_Criar_Mundo()
    global Simulacao;
    disp("---------------------------------------");
    disp("Simulação de piloto automatico de um carro");
    disp("Versão 2024.3");
    disp("Prof. Ricardo Prediger");
    disp("---------------------------------------");
    Simulacao.Nome_Aluno = "Aluno sem Nome!";
    Simulacao.Passo = 0.05;
    Simulacao.Veiculos = [];
    Simulacao.Altura_Maxima_trapezio = 20;          //Altura maxima do terreno onde o carro se deloca (metros)
    Simulacao.Altura_Maxima_Morro = 40;             //Altura maxima do terreno onde o carro se deloca (metros)
    Simulacao.Distancia_Total_Percurso = 5500;      //Distancia total do trajeto (metros)
    // Constantes
    Simulacao.p = 1.2922;                           //Desidade do ar
    Simulacao.Gravidade = 9.807;                    //(m/s)
    Simulacao.Amplitude_Ruido = 0.000;              // Amplitude do ruido (m) - Simula a imperfeição do sensor
    Simulacao.Semente_Gerador_Ruido = 2024;         // Valor utilizado para gerar ruidos consistentes durante os testes
    rand('seed',Simulacao.Semente_Gerador_Ruido);   // Configura o gerador de numeros aleatorios
    Simulacao.DEBUG = %f;
endfunction

function Simulacao_Redimensionar_Vetores(Tamanho)
    global Simulacao; global V_Tempo;
    V_Tempo = resize_matrix(V_Tempo, Tamanho, 8);
endfunction

function Simulacao_Ajustar_Vetores_Inicial()
    global Simulacao;
    Tamanho = 1.5 * Simulacao.Distancia_Total_Percurso / (Simulacao.Veiculos(1).Velocidade_Desejada(1) * Simulacao.Passo);
    Simulacao_Redimensionar_Vetores(Tamanho);
    for i = 1:size(Simulacao.Veiculos)(1)
        Simulacao.Veiculos(i) = Veiculo_Redimensionar_Vetores(Simulacao.Veiculos(i), Tamanho);
        Simulacao.Veiculos(i).Controlador = Controlador_Redimensionar_Vetores(Simulacao.Veiculos(i).Controlador, Tamanho);
    end
endfunction

function Simulacao_Ajustar_Vetores_Final()
    global Simulacao;
    Simulacao_Redimensionar_Vetores(Simulacao.Veiculos(1).Iteracao); // Verificar melhoramento
    for i = 1:size(Simulacao.Veiculos)(1)
        Simulacao.Veiculos(i) = Veiculo_Redimensionar_Vetores(Simulacao.Veiculos(i), Simulacao.Veiculos(i).Iteracao);
        Simulacao.Veiculos(i).Controlador = Controlador_Redimensionar_Vetores(Simulacao.Veiculos(i).Controlador, Simulacao.Veiculos(i).Iteracao);
    end
endfunction

function Simulacao_Configurar(Parametro, Valor)
    global Simulacao;
    select Parametro
    case "-Nome_Aluno" then
        Simulacao.Nome_Aluno = Valor;

    case "-Passo" then
        Simulacao.Passo = Valor;
        for i = 1:size(Simulacao.Veiculos)(1)
            Simulacao.Veiculos(i).Controlador.Passo = Simulacao.Passo;
        end

    case "-Veiculo" then
        Valor.Controlador.Passo = Simulacao.Passo;
        Simulacao.Veiculos($ + 1) = Valor;          // Adiciona um veiculo ao mundo

    case "-Altura_Maxima_trapezio" then
        Simulacao.Altura_Maxima_trapezio = Valor;

    case "-Altura_Maxima_Morro" then
        Simulacao.Altura_Maxima_Morro = Valor;

    case "-Distancia_Total_Percurso" then
        Simulacao.Distancia_Total_Percurso = Valor;

    case "-Amplitude_Ruido" then
        Simulacao.Amplitude_Ruido = Valor;

    case "-Semente_Gerador_Ruido" then
        Simulacao.Semente_Gerador_Ruido = Valor;

    case "-DEBUG" then
        Simulacao.DEBUG = Valor;

    else
        errmsg = sprintf (" Parametro %s desconhecido" , Parametro);
        error (errmsg);
    end
endfunction

// Função auxiliar para calculo da autura do terreno
function [Altura] = Relevo(Pos)
    global Simulacao;
    if Pos < 500 then
        Altura = 0;
    elseif Pos < 1000
        //Altura = Pos*Altura_Maxima_trapezio/500 - Altura_Maxima_trapezio;
        Deslocamento = 500; // Inicio do trapézio
        Largura = 1000-Deslocamento; // Fim - inicio do trapézio
        Altura = (Simulacao.Altura_Maxima_trapezio/2)*(cos(Pos*%pi/Largura - Deslocamento*%pi/Largura + %pi) + 1);
    elseif Pos < 2000
        Altura = Simulacao.Altura_Maxima_trapezio;
    elseif Pos < 2500
        //Altura = Altura_Maxima_trapezio - (Pos - 2000)*Altura_Maxima_trapezio/500
        Deslocamento = 2000; // Inicio do trapézio
        Largura = 2500-Deslocamento; // Fim - inicio do trapézio
        Altura = (Simulacao.Altura_Maxima_trapezio/2)*(cos(Pos*%pi/Largura - Deslocamento*%pi/Largura) + 1);
    elseif Pos < 3000
        Altura = 0;
    elseif Pos < 5000
        Pos = Pos - 3000
        Altura = Simulacao.Altura_Maxima_Morro*sin(Pos*%pi*2/2000 - %pi/2)/2 + Simulacao.Altura_Maxima_Morro/2;
    else
        Altura = 0;
    end
endfunction

function Executa_Simulacao()
    global Simulacao;
    tic();
    // Ajuste dos coeficientes de cada veiculo
    for N_Carro = 1:size(Simulacao.Veiculos)(1)
        Veiculo = Simulacao.Veiculos(N_Carro);
        Veiculo = Calcular_Coeficiente_Perdas_Mecanicas(Veiculo);
        if (Veiculo.Coeficiente_Ajuste_Massa_Configurado ~= %T)
            Veiculo = Veiculo_Calcular_Coeficiente_Ajuste(Veiculo);
        end
        Simulacao.Veiculos(N_Carro) = Veiculo;
    end

    Simulacao_Ajustar_Vetores_Inicial();
    Simular_Mundo(1000);
    Simulacao_Ajustar_Vetores_Final();
    disp("Tempo necessario para efetuar a simulação: " + string(toc()) + "s");
endfunction

function Simular_Mundo(Velocidade_Terminal)
    global Simulacao; global V_Tempo;

    // Cria a janela de informações durante a simulação
    ID_Janela_Status_Simulacao=waitbar("Iniciando Simulação!");
    Temporizador_Status = 0.0;

    for N_Carro = 1:size(Simulacao.Veiculos)(1)
        Veiculo = Simulacao.Veiculos(N_Carro);
        global Controlador // Alternativa para melhorar a performance ao chamar uma função que precisa retornar dados
        Controlador = Veiculo.Controlador;

        while(Veiculo.Posicao(Veiculo.Iteracao) < Simulacao.Distancia_Total_Percurso && Veiculo.Velocidade(Veiculo.Iteracao) < Velocidade_Terminal && Veiculo.Posicao(Veiculo.Iteracao) >= 0)
            Tempo_ini = toc(); Index_V_Tempo = 1; // Benchmark

            // Calculando o Erro do sistema
            Erro = Veiculo.Velocidade_Desejada(Veiculo.Iteracao) - Veiculo.Velocidade(Veiculo.Iteracao);

            // Inicio dos calculos da proxima iteração
            Veiculo.Iteracao = Veiculo.Iteracao + 1;
            Veiculo.Tempo(Veiculo.Iteracao) = Veiculo.Tempo(Veiculo.Iteracao - 1) + Simulacao.Passo;
            Veiculo.Velocidade_Desejada(Veiculo.Iteracao) = Veiculo.Velocidade_Desejada(Veiculo.Iteracao - 1) //Para futuras aplicações de com velocidade variavel

            // Adiciona um ruido ao sistema
            if (Simulacao.Amplitude_Ruido > 0) then
                //Veiculo.Ruido(Veiculo.Iteracao) = Veiculo.Ruido(Veiculo.Iteracao - 1) + Simulacao.Amplitude_Ruido*rand(1,"normal");
                Veiculo.Ruido(Veiculo.Iteracao) = Simulacao.Amplitude_Ruido*(rand(1,"normal") - 0.5);
                Erro = Erro + Veiculo.Ruido(Veiculo.Iteracao);
            end

            V_Tempo(Veiculo.Iteracao, Index_V_Tempo) = toc() - Tempo_ini; Index_V_Tempo = Index_V_Tempo + 1;// Benchmark

            // *** CALCULOS DO CONTROLADOR ***
            Controlador.Iteracao = Controlador.Iteracao + 1;
            Controlador.Erro(Controlador.Iteracao) = Erro; //Salva a informação

            if (Controlador.Modo == %T) then // Controlador PID padrão
                // Calculo do termo proporcional
                Controlador.Calculo_Proporcional(Controlador.Iteracao) = Erro * Controlador.Kp;

                // Calculo do termo Integrativo
                if (Controlador.Varivel_Manipulada(Controlador.Iteracao - 1) < 100.0 && Controlador.Varivel_Manipulada(Controlador.Iteracao - 1) > -100.0) // Windup
                    Controlador.Calculo_Integral(Controlador.Iteracao) = Controlador.Calculo_Integral(Controlador.Iteracao - 1) + Erro * Controlador.Passo * Controlador.Ki;
                else
                    Controlador.Calculo_Integral(Controlador.Iteracao) = Controlador.Calculo_Integral(Controlador.Iteracao - 1);
                end

                // Calculo do termo derivativo
                Controlador.Calculo_Derivativo(Controlador.Iteracao) = ((Erro - Controlador.Erro(Controlador.Iteracao - 1))/Controlador.Passo) * Controlador.Kd;

                // Construção do PID
                Controlador.Varivel_Manipulada(Controlador.Iteracao) = Controlador.Calculo_Proporcional(Controlador.Iteracao) + Controlador.Calculo_Integral(Controlador.Iteracao) + Controlador.Calculo_Derivativo(Controlador.Iteracao);
            else // Controladores feito pelo usuario
                // Para não dar problema ao gerar o gráfico
                Controlador.Calculo_Proporcional(Controlador.Iteracao) = 0;
                Controlador.Calculo_Integral(Controlador.Iteracao) = 0;
                Controlador.Calculo_Derivativo(Controlador.Iteracao) = 0;
                //Controlador.Varivel_Manipulada(Controlador.Iteracao) = 0;
                Controlador_Controlar(Erro)
            end
            // *** FIM CALCULOS DO CONTROLADOR ***

            V_Tempo(Veiculo.Iteracao, Index_V_Tempo) = toc() - Tempo_ini; Index_V_Tempo = Index_V_Tempo + 1;// Benchmark

            if Controlador.Varivel_Manipulada(Veiculo.Iteracao) >= 0 then
                Veiculo.Acelerador(Veiculo.Iteracao) = Controlador.Varivel_Manipulada(Veiculo.Iteracao);
                Veiculo.Freio(Veiculo.Iteracao) = 0;
                if Veiculo.Acelerador(Veiculo.Iteracao) > 100 then
                    Veiculo.Acelerador(Veiculo.Iteracao) = 100;        // Limitação Fisica
                end
            else
                if Veiculo.Velocidade(Veiculo.Iteracao - 1) <= 0 then
                    Controlador.Varivel_Manipulada(Veiculo.Iteracao) = 0;
                    disp(Veiculo.Velocidade(Veiculo.Iteracao - 1))
                end
                Veiculo.Acelerador(Veiculo.Iteracao) = 0;
                Veiculo.Freio(Veiculo.Iteracao) = Controlador.Varivel_Manipulada(Veiculo.Iteracao);
                if Veiculo.Freio(Veiculo.Iteracao) < -200 then
                    Veiculo.Freio(Veiculo.Iteracao) = -200;            // Limitação Fisica
                end
            end

            // Aplicando filtro passa baixa no acelerador (Simulando uma inercia do Motor)
            if (Veiculo.Acelerador_Filtro(Veiculo.Iteracao - 1) < Veiculo.Acelerador(Veiculo.Iteracao))
                Veiculo.Acelerador_Filtro(Veiculo.Iteracao) = Veiculo.Acelerador_Filtro(Veiculo.Iteracao - 1) + (Veiculo.Acelerador(Veiculo.Iteracao) - Veiculo.Acelerador_Filtro(Veiculo.Iteracao - 1))/(0.2/Simulacao.Passo);
            else
                Veiculo.Acelerador_Filtro(Veiculo.Iteracao) = Veiculo.Acelerador(Veiculo.Iteracao);
            end
            V_Tempo(Veiculo.Iteracao, Index_V_Tempo) = toc() - Tempo_ini; Index_V_Tempo = Index_V_Tempo + 1;// Benchmark
            
            // Calculo das força no carro
            // Forca do Motor
            Veiculo.Motor(Veiculo.Iteracao) = Veiculo.Potencia_Maxima_Watts_Ajustada/Veiculo.Velocidade(Veiculo.Iteracao - 1)*(Veiculo.Acelerador_Filtro(Veiculo.Iteracao) + Veiculo.Freio(Veiculo.Iteracao))/100.0;

            // Arrasto
            Veiculo.Arrasto(Veiculo.Iteracao) = 0.5 * Veiculo.Area_Frontal_Efetiva * Simulacao.p * Veiculo.Velocidade(Veiculo.Iteracao - 1)^2;
            if Veiculo.Velocidade(Veiculo.Iteracao - 1) < 0 then
                Veiculo.Arrasto(Veiculo.Iteracao) = -Veiculo.Arrasto(Veiculo.Iteracao);
            end

            V_Tempo(Veiculo.Iteracao, Index_V_Tempo) = toc() - Tempo_ini; Index_V_Tempo = Index_V_Tempo + 1;// Benchmark

            // Terreno
            Veiculo.Altura(Veiculo.Iteracao) = Relevo(Veiculo.Posicao(Veiculo.Iteracao - 1));
            
            if Veiculo.Iteracao > 2 then
                Angulo_Altura = atan((Veiculo.Altura(Veiculo.Iteracao) - Veiculo.Altura(Veiculo.Iteracao-1)), (Veiculo.Posicao(Veiculo.Iteracao - 1) - Veiculo.Posicao(Veiculo.Iteracao - 2)))
            else 
                Angulo_Altura = 0;
            end
            V_Tempo(Veiculo.Iteracao, Index_V_Tempo) = toc() - Tempo_ini; Index_V_Tempo = Index_V_Tempo + 1;// Benchmark
            Veiculo.Forca_Terreno(Veiculo.Iteracao) = Simulacao.Gravidade * Veiculo.Massa_Ajustada * sin(Angulo_Altura);

            V_Tempo(Veiculo.Iteracao, Index_V_Tempo) = toc() - Tempo_ini; Index_V_Tempo = Index_V_Tempo + 1;// Benchmark

            // Somatório de forca
            Somatorio_forcas = Veiculo.Motor(Veiculo.Iteracao) - Veiculo.Arrasto(Veiculo.Iteracao) - Veiculo.Forca_Terreno(Veiculo.Iteracao);

            Veiculo.Aceleracao(Veiculo.Iteracao) = Somatorio_forcas / Veiculo.Massa_Ajustada; // Lei de NEWTON a=F/m
            Veiculo.Velocidade(Veiculo.Iteracao) = Veiculo.Velocidade(Veiculo.Iteracao - 1) + Veiculo.Aceleracao(Veiculo.Iteracao)*Simulacao.Passo; //Integral da aceleração
            Veiculo.Posicao(Veiculo.Iteracao) = Veiculo.Posicao(Veiculo.Iteracao - 1) + Veiculo.Velocidade(Veiculo.Iteracao)*Simulacao.Passo; //Integral da velocidade

            V_Tempo(Veiculo.Iteracao, Index_V_Tempo) = toc() - Tempo_ini; Index_V_Tempo = Index_V_Tempo + 1;// Benchmark

            if (toc() > Temporizador_Status)
                waitbar((Veiculo.Posicao(Veiculo.Iteracao) / Simulacao.Distancia_Total_Percurso),"Simulando - Velocidade do carro nesse momento = " + string(Veiculo.Velocidade(Veiculo.Iteracao)*3.6) + "Km/h",ID_Janela_Status_Simulacao);
                Temporizador_Status = toc() + 0.33;
            end
            V_Tempo(Veiculo.Iteracao, Index_V_Tempo) = toc() - Tempo_ini; Index_V_Tempo = Index_V_Tempo + 1;// Benchmark
        end
        // Copia novamente as variaveis locais para as estruturas
        Veiculo.Controlador = Controlador;
        Simulacao.Veiculos(N_Carro) = Veiculo;
    end
    // Limpa as Variaveis globais que não serão mais utilizadas
    clearglobal Controlador;
    close(ID_Janela_Status_Simulacao);
endfunction
