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
function v = Veiculo_Criar()
    // Dados da Construção
    v.Potencia_Maxima_CV = 50.0;
    v.Potencia_Maxima_Watts = v.Potencia_Maxima_CV * 735.5;
    v.Massa = 100.0;
    v.Carga = 0;

    //Simplificação da simulação
    v.Coeficiente_Ajuste_Massa = 1;
    v.Coeficiente_Ajuste_Massa_Configurado = %F; //Coeficiente não ajustado
    v = Veiculo_Calcular_Massa_Ajustada(v);
    v.Coeficiente_Perdas_Mecanicas = 0.72;
    v.Potencia_Maxima_Watts_Ajustada = v.Potencia_Maxima_Watts * v.Coeficiente_Perdas_Mecanicas;

    // Dados do fabricante
    v.Nome = "Veiculo sem nome";
    v.Fabricante = "Xing-Ling";
    v.Aceleracao_0_100 = 0.0;
    v.Velocidade_Maxima = 0.0;

    // Aerodinamica
    v.Cx = 0.0;
    v.Cx_Configurado = %F; //Cx não ajustado
    v.Area_Frontal = 0.0;
    v.Area_Frontal_Configurado = %F; //Area_Frontal não ajustado
    v.Area_Frontal_Efetiva = v.Cx * v.Area_Frontal; //Apenas por referencia

    // Adiciona o controlador
    v.Controlador = Controlador_Criar();

    // Dados da simulacao
    v.Iteracao = 1;
    v.Velocidade_Inicial = 50 / 3.6;
    v.Coeficiente_Ajuste_Massa_Inicial = 0.9;
    v.Passo_Coeficiente_Ajuste_Massa = 0.05;

    // Vetores de dados
    v.Velocidade_Desejada(v.Iteracao) = 50 / 3.6;
    v.Acelerador(v.Iteracao) = 0;
    v.Acelerador_Filtro(v.Iteracao) = 0;
    v.Freio(v.Iteracao) = 0;

    v.Posicao(v.Iteracao) = 0;
    v.Velocidade(v.Iteracao) = 0;
    v.Aceleracao(v.Iteracao) = 0;

    v.Motor(v.Iteracao) = 0;
    v.Arrasto(v.Iteracao) = 0;
    v.Forca_Terreno(v.Iteracao) = 0;
    v.Altura(v.Iteracao) = 0;

    v.Tempo(v.Iteracao) = 0;
    v.Ruido(v.Iteracao) = 0;

    // Velocidade inicial
    v.Velocidade(1) = v.Velocidade_Inicial;
endfunction

function Veiculo = Veiculo_Redimensionar_Vetores(Veiculo, Tamanho)
    Veiculo.Velocidade_Desejada = resize_matrix(Veiculo.Velocidade_Desejada, Tamanho, 1);
    Veiculo.Acelerador = resize_matrix(Veiculo.Acelerador, Tamanho, 1);
    Veiculo.Acelerador_Filtro = resize_matrix(Veiculo.Acelerador_Filtro, Tamanho, 1);
    Veiculo.Freio = resize_matrix(Veiculo.Freio, Tamanho, 1);

    Veiculo.Posicao = resize_matrix(Veiculo.Posicao, Tamanho, 1);
    Veiculo.Velocidade = resize_matrix(Veiculo.Velocidade, Tamanho, 1);
    Veiculo.Aceleracao = resize_matrix(Veiculo.Aceleracao, Tamanho, 1);

    Veiculo.Motor = resize_matrix(Veiculo.Motor, Tamanho, 1);
    Veiculo.Arrasto = resize_matrix(Veiculo.Arrasto, Tamanho, 1);
    Veiculo.Forca_Terreno = resize_matrix(Veiculo.Forca_Terreno, Tamanho, 1);
    Veiculo.Altura = resize_matrix(Veiculo.Altura, Tamanho, 1);

    Veiculo.Tempo = resize_matrix(Veiculo.Tempo, Tamanho, 1);
    Veiculo.Ruido = resize_matrix(Veiculo.Ruido, Tamanho, 1);
endfunction

function Veiculo = Veiculo_Calcular_Massa_Ajustada(Veiculo)
    Veiculo.Massa_Ajustada = (Veiculo.Massa + Veiculo.Carga) * Veiculo.Coeficiente_Ajuste_Massa;
end

function Veiculo = Veiculo_Configurar(Veiculo, Parametro, Valor)
    select Parametro
    case "-Potencia_Maxima_CV" then
        Veiculo.Potencia_Maxima_CV = Valor;
        Veiculo.Potencia_Maxima_Watts = Valor * 735.5;
        Veiculo.Potencia_Maxima_Watts_Ajustada = Veiculo.Potencia_Maxima_Watts * Veiculo.Coeficiente_Perdas_Mecanicas;

    case "-Coeficiente_Perdas_Mecanicas" then
        Veiculo.Coeficiente_Perdas_Mecanicas = Valor;
        Veiculo.Potencia_Maxima_Watts_Ajustada = Veiculo.Potencia_Maxima_Watts * Veiculo.Coeficiente_Perdas_Mecanicas;

    case "-Carga" then
        Veiculo.Carga = Valor;
        Veiculo = Veiculo_Calcular_Massa_Ajustada(Veiculo);

    case "-Massa" then
        Veiculo.Massa = Valor;
        Veiculo = Veiculo_Calcular_Massa_Ajustada(Veiculo);

    case "-Coeficiente_Ajuste_Massa" then
        Veiculo.Coeficiente_Ajuste_Massa = Valor;
        Veiculo.Coeficiente_Ajuste_Massa_Configurado = %T;
        Veiculo = Veiculo_Calcular_Massa_Ajustada(Veiculo);

    case "-Aceleracao_0_100" then
        Veiculo.Aceleracao_0_100 = Valor;

    case "-Velocidade_Maxima" then
        Veiculo.Velocidade_Maxima = Valor;

    case "-Modelo" then
        Veiculo.Modelo = Valor;

    case "-Fabricante" then
        Veiculo.Fabricante = Valor;

    case "-Cx" then
        Veiculo.Cx = Valor;
        Veiculo.Cx_Configurado = %T;
        Veiculo = Calcular_Coeficiente_Perdas_Mecanicas(Veiculo);

    case "-Area_Frontal" then
        Veiculo.Area_Frontal = Valor;
        Veiculo.Area_Frontal_Configurado = %T;
        Veiculo = Calcular_Coeficiente_Perdas_Mecanicas(Veiculo);

    case "-Velocidade_Inicial" then
        Veiculo.Velocidade_Inicial = Valor / 3.6;
        Veiculo.Velocidade(1) = Veiculo.Velocidade_Inicial;

    case "-Velocidade_Desejada" then
        Veiculo.Velocidade_Desejada(1) = Valor / 3.6;

    case "-Controlador" then
        Veiculo.Controlador = Valor;

    else
        errmsg = sprintf (" Parametro %s desconhecido" , Parametro);
        error (errmsg);
    end
endfunction

function Veiculo = Calcular_Coeficiente_Perdas_Mecanicas(Veiculo)
    // Se os dados aerodinamicos foram fornecidos é possivel uma melhor estimação das perdas mecânicas
    if (Veiculo.Cx_Configurado && Veiculo.Area_Frontal_Configurado) then
        Veiculo.Area_Frontal_Efetiva = Veiculo.Cx * Veiculo.Area_Frontal;
    else
        // Estimação da Area frontal efetiva
        Arrasto_Velocidade_Maxima = Veiculo.Potencia_Maxima_Watts_Ajustada/(Veiculo.Velocidade_Maxima/3.6);
        Veiculo.Area_Frontal_Efetiva = 2 * Arrasto_Velocidade_Maxima / (Simulacao.p * (Veiculo.Velocidade_Maxima/3.6)^2);
        if (Simulacao.DEBUG == %t) then
            disp("###### CALCULO COEFICIENTE PERDAS MECANICAS ##############");
            disp("Potencia_Maxima_Watts_Ajustada: " + string(Veiculo.Potencia_Maxima_Watts_Ajustada));
            disp("Velocidade_Maxima: " + string(Veiculo.Velocidade_Maxima));
            disp("Area fronta efetiva calculada em:" + string(Veiculo.Area_Frontal_Efetiva))
            disp("##########################################################");
            disp("");
        end     
    end

    Arrasto_Velocidade_Maxima = Veiculo.Potencia_Maxima_Watts/(Veiculo.Velocidade_Maxima/3.6); //Sem perdas mecanicas (ideal)
    Coeficiente_Perdas_Mecanicas = Veiculo.Area_Frontal_Efetiva / (2 * Arrasto_Velocidade_Maxima / (Simulacao.p * (Veiculo.Velocidade_Maxima/3.6)^2));
    Veiculo = Veiculo_Configurar(Veiculo, "-Coeficiente_Perdas_Mecanicas", Coeficiente_Perdas_Mecanicas);
    if (Simulacao.DEBUG == %t) then
        disp("##########################################################");
        disp("Area frontal efetiva calculada em:" + string(Veiculo.Area_Frontal_Efetiva))
        disp("Coeficiente_Perdas_Mecanicas:" + string(Veiculo.Coeficiente_Perdas_Mecanicas))
        disp("##########################################################");
        disp("");
    end
endfunction

function Veiculo = Veiculo_Calcular_Coeficiente_Ajuste(Veiculo)
    global Simulacao;

    // Salva o estado atual da simulação e veiculo
    Salvar_Simulacao = Simulacao;
    Veiculo_Teste = Veiculo;

    // Configura o Controlador
    PID_Drag_Race = Controlador_Criar();
    PID_Drag_Race = Controlador_Configurar(PID_Drag_Race, "-Kp", 10000);
    Veiculo_Teste = Veiculo_Configurar(Veiculo_Teste, "-Controlador", PID_Drag_Race);
    Veiculo_Teste = Veiculo_Configurar(Veiculo_Teste, "-Velocidade_Inicial", 1);
    Veiculo_Teste = Veiculo_Configurar(Veiculo_Teste, "-Velocidade_Desejada", 300);
    Veiculo_Teste = Veiculo_Configurar(Veiculo_Teste, "-Carga", 0);

    //Configura a simulação
    Simulacao.Veiculos(1) = Veiculo_Teste; //Garante que tenha apenas o veiculo a ser testado esteja na simulação
    Simulacao_Configurar("-Passo", 0.01);
    Simulacao_Configurar("-Altura_Maxima_trapezio", 0);
    Simulacao_Configurar("-Altura_Maxima_Morro", 0);
    Simulacao_Configurar("-Distancia_Total_Percurso", 5500);
    Simulacao_Configurar("-Amplitude_Ruido", 0.00);
    Simulacao_Ajustar_Vetores_Inicial();

    Finalizou = 0;
    Novo_Coeficiente_Ajuste_Massa = Simulacao.Veiculos(1).Coeficiente_Ajuste_Massa_Inicial;
    Erro_Tempo_Aceleracao_0_100_Anterior = Simulacao.Veiculos(1).Aceleracao_0_100;
    while(Finalizou == 0) then
        Simulacao.Veiculos(1).Iteracao = 1;
        Simulacao.Veiculos(1).Controlador.Iteracao = 1;
        Simulacao.Veiculos(1) = Veiculo_Configurar(Simulacao.Veiculos(1), "-Coeficiente_Ajuste_Massa", Novo_Coeficiente_Ajuste_Massa);

        Simular_Mundo(100.0 / 3.6); //Simulação de Drag Race de 0 a 100;

        Erro_Tempo_Aceleracao_0_100 = Simulacao.Veiculos(1).Aceleracao_0_100 - Simulacao.Veiculos(1).Tempo(Simulacao.Veiculos(1).Iteracao);
        disp("**********************************************************")
        disp("Coeficiente de massa: " + string(Novo_Coeficiente_Ajuste_Massa));
        disp("Aceleração 0-100 Km/h real:" + string(Simulacao.Veiculos(1).Aceleracao_0_100));
        disp("Aceleração 0-100 Km/h simulado: " + string(Simulacao.Veiculos(1).Tempo(Simulacao.Veiculos(1).Iteracao)));
        disp("Difereça: " + string(Erro_Tempo_Aceleracao_0_100));

        if Erro_Tempo_Aceleracao_0_100 < 0 then
            Finalizou = 1;
            if (abs(Erro_Tempo_Aceleracao_0_100_Anterior) < abs(Erro_Tempo_Aceleracao_0_100)) then //Testa se o ultimo resultado é melhor que o penultimo
                Novo_Coeficiente_Ajuste_Massa = Novo_Coeficiente_Ajuste_Massa - Simulacao.Veiculos(1).Passo_Coeficiente_Ajuste_Massa; //retorna ao anterior
            end
        else 
            Novo_Coeficiente_Ajuste_Massa = Novo_Coeficiente_Ajuste_Massa + Simulacao.Veiculos(1).Passo_Coeficiente_Ajuste_Massa;
        end
        Erro_Tempo_Aceleracao_0_100_Anterior = Erro_Tempo_Aceleracao_0_100;
    end
    Simulacao = Salvar_Simulacao;
    disp("Coeficiente de massa escolhido: " + string(Novo_Coeficiente_Ajuste_Massa));
    abort(); //Melhorar
    Veiculo = Veiculo_Configurar(Veiculo, "-Coeficiente_Ajuste_Massa", Novo_Coeficiente_Ajuste_Massa);
endfunction
