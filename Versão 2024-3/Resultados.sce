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
function Mostrar_Resultados_Resumido()
    global Simulacao;
    Posicao_Figura = 0; Offset_Figuras = 25;
    for N_Carro = 1:size(Simulacao.Veiculos)(1)
        Veiculo = Simulacao.Veiculos(N_Carro);

        figure(); // criando uma nova figura
        f1=gcf(); // criando uma figura
        f1.figure_size= [1200,700];
        f1.figure_position = [Posicao_Figura, Posicao_Figura];
        f1.figure_name= Simulacao.Nome_Aluno + " - Dados da simulação do carro -> Kp:" + string(Veiculo.Controlador.Kp) + " - Ki:" + string(Veiculo.Controlador.Ki) + " - Kd:" + string(Veiculo.Controlador.Kd) + " -> Carro: " + Veiculo.Fabricante + " - " + Veiculo.Modelo;

        drawlater();
        clf(f1); // Limpa o grafico
        // Mostra os resultados na tela
        subplot(231);
        plot(Veiculo.Tempo,Veiculo.Aceleracao,'m');
        set(gca(),"grid",[1 1]);
        title('Aceleração', 'fontsize', 3);
        xlabel('Tempo', 'fontsize', 3); ylabel('m/s^2', 'fontsize', 3);

        // Mostra os resultados na tela
        subplot(232);
        plot(Veiculo.Tempo, Veiculo.Velocidade*3.6, 'b', Veiculo.Tempo, Veiculo.Velocidade_Desejada*3.6, 'm');
        set(gca(),"grid",[1 1]);
        title('Velocidade (Azul), Velocidade Desejada (Magenta)', 'fontsize', 3);
        xlabel('Tempo', 'fontsize', 3); ylabel('Km/h', 'fontsize', 3);

        // Mostra os resultados na tela
        subplot(233);
        plot(Veiculo.Tempo,Veiculo.Posicao);
        set(gca(),"grid",[1 1]);
        title('Distância', 'fontsize', 3);
        xlabel('Tempo', 'fontsize', 3); ylabel('Metros', 'fontsize', 3);

        // Mostra os resultados na tela
        subplot(234);
        plot(Veiculo.Tempo,Veiculo.Acelerador,'b',Veiculo.Tempo,-Veiculo.Freio,'r')
        set(gca(),"grid",[1 1]);
        title('Posição do acelerador (Azul), Posição do Freio (Vermelho)', 'fontsize', 3);
        xlabel('Tempo', 'fontsize', 3); ylabel('%', 'fontsize', 3);

        // Mostra os resultados na tela
        subplot(235);
        plot(Veiculo.Tempo,Veiculo.Controlador.Erro*3.6,'r')
        set(gca(),"grid",[1 1])
        title('Erro', 'fontsize', 3); 
        xlabel('Tempo', 'fontsize', 3); ylabel('Km/h', 'fontsize', 3);

        // Mostra os resultados na tela
        subplot(236);
        plot(Veiculo.Posicao,Veiculo.Altura);
        Manipulador_Eixos = gca();
        Manipulador_Eixos.data_bounds(1,2) = Manipulador_Eixos.data_bounds(1,2) - 1;
        Manipulador_Eixos.data_bounds(2,2) = Manipulador_Eixos.data_bounds(2,2) + 1;
        Manipulador_Eixos.grid = [1 1];
        title('Caminho percorrido', 'fontsize', 3);
        xlabel('Distancia(m)', 'fontsize', 3); ylabel('Altura(m)', 'fontsize', 3);
        drawnow(); // desenhando a figura corrente
        Posicao_Figura = Posicao_Figura + Offset_Figuras;
    end
endfunction

function Mostrar_Resultados()
    global Simulacao;
    Posicao_Figura = 0; Offset_Figuras = 25;
    background = 8;
    for N_Carro = 1:size(Simulacao.Veiculos)(1)
        Veiculo = Simulacao.Veiculos(N_Carro);

        //Grafico PID
        Posicao_Figura = Posicao_Figura + Offset_Figuras;
        figure(); // criando uma nova figura
        f2=gcf();
        f2.figure_size= [1200,700];
        f2.figure_position = [Posicao_Figura, Posicao_Figura];
        f2.figure_name= Simulacao.Nome_Aluno + " - Dados do controlador PID";
        f2.background = background;

        drawlater();
        // Mostra os resultados na tela
        subplot(211);
        plot(Veiculo.Tempo,Veiculo.Controlador.Erro*3.6, 'r');
        set(gca(),"grid",[1 1]);
        title('Erro', 'fontsize', 3);
        xlabel('Tempo', 'fontsize', 3); ylabel('Km/h', 'fontsize', 3);

        // Mostra os resultados na tela
        subplot(212);
        plot(Veiculo.Tempo,Veiculo.Acelerador,'b',Veiculo.Tempo,-Veiculo.Freio,'r',Veiculo.Tempo,Veiculo.Controlador.Calculo_Proporcional,'g',Veiculo.Tempo,Veiculo.Controlador.Calculo_Integral,'c',Veiculo.Tempo,Veiculo.Controlador.Calculo_Derivativo,'m');
        set(gca(),"data_bounds",[0,-110;Veiculo.Tempo(Veiculo.Iteracao),110]);
        set(gca(),"grid",[1 8]);
        title('Posição do acelerador(Azul), Posição do Freio (Vermelho), Parcela do controlador P(Verde), I(Ciano) e D(Magenta)', 'fontsize', 3); 
        xlabel('Tempo', 'fontsize', 3); ylabel('%', 'fontsize', 3);
        drawnow(); // desenhando a figura corrente

        //Grafico Forças
        Posicao_Figura = Posicao_Figura + Offset_Figuras;
        figure(); // criando uma nova figura
        f3=gcf();
        f3.figure_size= [1200,700];
        f3.figure_position = [Posicao_Figura, Posicao_Figura];
        f3.figure_name= Simulacao.Nome_Aluno + " - Forças no veiculo";
        f3.background = background;
        drawlater();
        plot(Veiculo.Tempo,Veiculo.Motor,'b',Veiculo.Tempo,-Veiculo.Arrasto,'g',Veiculo.Tempo,-Veiculo.Forca_Terreno,'r')
        set(gca(),"grid",[1 1]);
        title('Força do motor (Azul), Força de arrasto(Verde), Força do terreno(Vermelho)', 'fontsize', 3); 
        xlabel('Tempo', 'fontsize', 3); ylabel('Newton', 'fontsize', 3);
        drawnow(); // desenhando a figura corrente

        //Grafico Erro
        Posicao_Figura = Posicao_Figura + Offset_Figuras;
        figure(); // criando uma nova figura
        f4=gcf();
        f4.figure_size= [1200,700];
        f4.figure_position = [Posicao_Figura, Posicao_Figura];
        f4.figure_name= Simulacao.Nome_Aluno + " - Erro de Velocidade";
        f4.background = background;
        drawlater();
        plot(Veiculo.Tempo,Veiculo.Controlador.Erro*3.6,'r');
        Manipulador_Eixos = gca();
        Manipulador_Eixos.data_bounds(1,2) = -2;
        Manipulador_Eixos.data_bounds(2,2) = 2;
        Manipulador_Eixos.grid = [1 1];
        title('Erro', 'fontsize', 3);
        xlabel('Tempo', 'fontsize', 3); ylabel('Km/h', 'fontsize', 3);
        drawnow(); // desenhando a figura corrente

        //Grafico da Aceleracao
        Posicao_Figura = Posicao_Figura + Offset_Figuras;
        figure(); // criando uma nova figura
        f4=gcf();
        f4.figure_size= [1200,700];
        f4.figure_position = [Posicao_Figura, Posicao_Figura];
        f4.figure_name= Simulacao.Nome_Aluno + " - Aceleração lateral do carro: " + Veiculo.Fabricante + " " + Veiculo.Modelo;
        f4.background = background;
        drawlater();
        plot(Veiculo.Tempo,Veiculo.Aceleracao,'m');
        Manipulador_Eixos = gca();
        Manipulador_Eixos.data_bounds(1,2) = -0.2;
        Manipulador_Eixos.data_bounds(2,2) = 0.2;
        Manipulador_Eixos.grid = [1 1];
        title('Aceleração', 'fontsize', 3);
        xlabel('Tempo', 'fontsize', 3); ylabel('m/s^2', 'fontsize', 3);
        drawnow(); // desenhando a figura corrente
    end
endfunction

//function Exibir_Grafico_Forças()
//    global Simulacao;
//    Posicao_Figura = 0; Offset_Figuras = 25;
//    Veiculo = Simulacao.Veiculos(1);
//
//    Posicao_Figura = Posicao_Figura + Offset_Figuras;
//    figure(); // criando uma nova figura
//    f3=gcf();
//    f3.figure_size= [1200,700];
//    f3.figure_position = [Posicao_Figura, Posicao_Figura];
//    f3.figure_name= Simulacao.Nome_Aluno + " - Forças no veiculo";
//    f3.background = 8;//f1.background;
//    drawlater();
//    plot(Veiculo.Tempo,Veiculo.Motor,'b',Veiculo.Tempo,-Veiculo.Arrasto,'g',Veiculo.Tempo,-Veiculo.Forca_Terreno,'r')
//    set(gca(),"grid",[1 1]);
//    title('Força do motor (Azul), Força de arrasto(Verde), Força do terreno(Vermelho)', 'fontsize', 3); 
//    xlabel('Tempo', 'fontsize', 3); ylabel('Newton', 'fontsize', 3);
//    drawnow(); // desenhando a figura corrente
//endfunction

function Grafico_Performance()
    global V_Tempo;
    for Num = 1:size(V_Tempo)(2)
        if Num == 1 then
            disp("Tempo V" + string(Num) + ": -Média: " + string(mean(V_Tempo(:,Num))) + " -Mediana:" + string(median(V_Tempo(:,Num))) + "  -Max: " + string(max(V_Tempo(:,Num))));
        else
            Vetor = V_Tempo(:,Num) - V_Tempo(:,Num-1);
            disp("Tempo V" + string(Num) + ": -Média: " + string(mean(Vetor)) + " -Mediana:" + string(median(Vetor)) + "  -Max: " + string(max(Vetor)));
        end
    end
    I_T_Loop = size(V_Tempo)(2); //Indice do tempo do loop
    disp("Tempo Loop: -Média: " + string(mean(V_Tempo(:,I_T_Loop))) + "  -Mediana: " + string(median(V_Tempo(:,I_T_Loop))) + "  -Max: " + string(max(V_Tempo(:,I_T_Loop))));
    figure();
    f = gcf();
    f.figure_size= [1200,700];
    drawlater();
    Vmin = 0; Vmax = 2*median(V_Tempo(:,I_T_Loop))//0.0006;
    subplot(331);
    plot(V_Tempo(:,I_T_Loop));
    Manipulador_Eixos = gca();
    Manipulador_Eixos.data_bounds(1,2) = Vmin;
    Manipulador_Eixos.data_bounds(2,2) = Vmax;
    Manipulador_Eixos.grid = [1 1];
    title("Loop");

    subplot(332);
    plot(V_Tempo(:,1));
    Manipulador_Eixos = gca();
    Manipulador_Eixos.data_bounds(1,2) = Vmin;
    Manipulador_Eixos.data_bounds(2,2) = Vmax;
    Manipulador_Eixos.grid = [1 1];
    title("Tempo V1");

    for Num = 2:size(V_Tempo)(2)
        N_Fig = 331 + Num;
        subplot(N_Fig);
        plot(V_Tempo(:,Num) - V_Tempo(:,Num - 1));
        Manipulador_Eixos = gca();
        Manipulador_Eixos.data_bounds(1,2) = Vmin;
        Manipulador_Eixos.data_bounds(2,2) = Vmax;
        Manipulador_Eixos.grid = [1 1];
        title("Tempo V" + string(Num));
    end
    drawnow(); // desenhando a figura corrente
end
