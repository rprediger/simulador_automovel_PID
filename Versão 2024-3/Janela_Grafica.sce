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
//-------------------------------------------------------------------------

function Exibir_Simulacao(Velocidade_Simulacao)
    global Simulacao;
    // Cria uma figura para exibir a simulação
    figure(); drawlater();
    ID_Visualizaçao_Calculos = gcf();
    ID_Visualizaçao_Calculos.figure_size= [1200,700];
    ID_Visualizaçao_Calculos.figure_position = [0,0];
    ID_Visualizaçao_Calculos.figure_name = "Animação da Simulação";
    //ID_Visualizaçao_Calculos.anti_aliasing = "16x";
    //ID_Visualizaçao_Calculos.anti_aliasing = "off";
    // Faz o levantamento do terreno
    iteracao = 1;
    Terreno_Altura(iteracao) = zeros(Simulacao.Distancia_Total_Percurso);
    for Posicao_Terreno = 1:1:Simulacao.Distancia_Total_Percurso
        iteracao = iteracao + 1;
        Terreno_Altura(iteracao) = Relevo(Posicao_Terreno);
    end
    Posicao_Terreno = 0:1:Simulacao.Distancia_Total_Percurso;
    Posicao_Terreno = Posicao_Terreno';

    if Velocidade_Simulacao <= 0 then
        Velocidade_Simulacao = 1;
    end

    iteracao = 1; // Reinicializa a variavel
    realtimeinit(Simulacao.Passo);//configura a unidade de tempo
    Temporizador_Status = 0.0;
    FPS.Tempo_Ultimo_Frame = 0.0;
    FPS.Media = 0;
    tic();
    temporizador = 0;

    Veiculo = Simulacao.Veiculos(1); // Apenas do carro 1 *** Melhorar ***
    for iteracao = 1:Veiculo.Iteracao
        if ((Veiculo.Tempo(iteracao) > Velocidade_Simulacao*toc()) || toc() > Temporizador_Status)
            //if ((Veiculo.Tempo(iteracao) >= temporizador))
            temporizador = temporizador + 1;
            // Busca a janela do desenho
            scf(ID_Visualizaçao_Calculos);
            drawlater();
            FPS.Periodo = toc() - FPS.Tempo_Ultimo_Frame;
            FPS.Frequencia = 1/(FPS.Periodo);
            FPS.Media = FPS.Media + (FPS.Frequencia - FPS.Media)/(0.3/FPS.Periodo); //Filtro passa baixa
            FPS.Tempo_Ultimo_Frame = toc();
            if iteracao == 2 then
                FPS.Media = FPS.Frequencia; //Apenas para atualizar o primeiro FPS
            end
            // Atualiza o titulo da janela
            ID_Visualizaçao_Calculos.figure_name = "Dados da simulação (x" + string(Velocidade_Simulacao) + ") - " + "Tempo: " + string(int(Simulacao.Passo * iteracao)) + "s - FPS:" + string(FPS.Media);

            // Monta o grafico do medidor do velocimetro
            if iteracao == 1 then
                subplot(231);
                plot2d(5,0.1, [1,1], "020");
                xarc(0,0,10,10,0*64,180*64); // semicirculo
                gce().foreground = color("black"); //cor da linha
                title('Velocidade', 'fontsize', 3); //titulo
                Raio = 4.3;  //Raio das velocidades do velocimetro
                for Angulo = 0:15:180
                    // cada velocidade do velocimetro
                    xstring(Raio*cosd(Angulo) + 4.5,Raio*sind(Angulo) - 5,string(int(Veiculo.Velocidade_Maxima * (180 - Angulo)/180)));
                    set(gce(), "font_size", 2);
                end
                // Ponteiro do velocimetro
                Angulo = 180 - (180 * (1 - (Veiculo.Velocidade_Maxima - Veiculo.Velocidade(iteracao)*3.6)/Veiculo.Velocidade_Maxima));
                xarrows([5,3.8*cosd(Angulo) + 5], [-4,3.8*sind(Angulo) - 5], 20, color("blue"));
                Manipulador.Velocimetro.Indicador = gce();

                // Indicador do SP
                Angulo = 180 - (180 * (1 - (Veiculo.Velocidade_Maxima - Veiculo.Velocidade_Desejada(iteracao)*3.6)/Veiculo.Velocidade_Maxima));
                Distancia_Indicador_SP = 4.8
                SP_x = [(Distancia_Indicador_SP + 0.1)*cosd(Angulo) + 5, Distancia_Indicador_SP*cosd(Angulo) + 5];
                SP_y = [(Distancia_Indicador_SP + 0.1)*sind(Angulo) - 5, Distancia_Indicador_SP*sind(Angulo) - 5];
                xarrows(SP_x, SP_y, 20, color("scilabgreen4"));
                Manipulador.SP.Indicador = gce();
            else
                // Ponteiro do velocimetro
                Angulo = 180 - (180 * (1 - (Veiculo.Velocidade_Maxima - Veiculo.Velocidade(iteracao)*3.6)/Veiculo.Velocidade_Maxima));
                Manipulador.Velocimetro.Indicador.data = [5,-4; 3.8*cosd(Angulo) + 5,3.8*sind(Angulo) - 5];

                // Indicador do SP
                Angulo = 180 - (180 * (1 - (Veiculo.Velocidade_Maxima - Veiculo.Velocidade_Desejada(iteracao)*3.6)/Veiculo.Velocidade_Maxima));
                Distancia_Indicador_SP = 4.8
                SP_x = [(Distancia_Indicador_SP + 0.1)*cosd(Angulo) + 5, Distancia_Indicador_SP*cosd(Angulo) + 5];
                SP_y = [(Distancia_Indicador_SP + 0.1)*sind(Angulo) - 5, Distancia_Indicador_SP*sind(Angulo) - 5];
                Manipulador.SP.Indicador.data = [SP_x(1), SP_y(1); SP_x(2), SP_y(2)];
            end

            // Velocimento digital
            if iteracao == 1 then
                format("v",6);
                xstring(4,-4.5,"SP: " + string(Veiculo.Velocidade_Desejada(iteracao) * 3.6));
                Manipulador.SP.Texto = gce();
                Manipulador.SP.Texto.font_size = 3;
                Manipulador.SP.Texto.font_style = 6;
                Manipulador.SP.Texto.font_foreground = color("scilabgreen4");
                xstring(4,-5,"V: " + string(Veiculo.Velocidade(iteracao) * 3.6));
                Manipulador.Velocimetro.Texto = gce();
                Manipulador.Velocimetro.Texto.font_size = 3;
                Manipulador.Velocimetro.Texto.font_style = 6;
                Manipulador.Velocimetro.Texto.font_foreground = color("blue");
            else
                Manipulador.SP.Texto.text = "SP: " + string(Veiculo.Velocidade_Desejada(iteracao) * 3.6);
                Manipulador.Velocimetro.Texto.text = "V: " + string(Veiculo.Velocidade(iteracao) * 3.6);
            end

            // Monta o grafico do Medidor do Erro
            if iteracao == 1 then
                subplot(263);
                plot2d(5,3, [1,1], "020");
                xarc(5,5,10,10,-60*64,120*64); // Semicirculo
                gce().foreground = color("black"); // Cor da linha
                gce().background = color("grey"); // Cor de fundo
                title('Erro', 'fontsize', 3); //titulo
                ylabel('Km/h', 'fontsize', 3);
                xstring(5,-4.5,"E: " + string(Veiculo.Controlador.Erro(iteracao) * 3.6));
                Manipulador.Erro.Texto = gce();
                Manipulador.Erro.Texto.font_size = 3;
                Manipulador.Erro.Texto.font_style = 6;
                Manipulador.Erro.Texto.font_foreground = color("red");

                Display_Medidor_Amplitude_Erro = 3;
                for Angulo = -60:20:60
                    // cada velocidade do velocimetro
                    xstring(Raio*cosd(Angulo) + 9, Raio*sind(Angulo) - 0.4,string(int(Display_Medidor_Amplitude_Erro * Angulo/60)));
                    set(gce(), "font_size", 2);
                end
            else
                Erro = Veiculo.Controlador.Erro(iteracao) * 3.6;
                if (abs(Erro) < 0.001) then
                    Erro = 0;
                end
                Manipulador.Erro.Texto.text =("E: " + string(Erro));
            end

            // Calcula o angulo que deve estar o indicador (flecha) do erro
            Angulo = 60 * Veiculo.Controlador.Erro(iteracao)*3.6  / Display_Medidor_Amplitude_Erro;
            Cor_Indicador_Erro = color("blue");
            if Angulo > -60 then
                if Angulo < 60 then
                    Intensidade_Cor = abs(Angulo/60) * 255;
                    Cor_Indicador_Erro = color(Intensidade_Cor, 0, 255 - Intensidade_Cor);
                else
                    Angulo = 60;
                    Cor_Indicador_Erro = color("red");
                end
            else
                Angulo = -60;
                Cor_Indicador_Erro = color("red");
            end

            if iteracao == 1 then
                xarrows([5,3.5*cosd(Angulo) + 9], [0,3.5*sind(Angulo) - 0], 30, Cor_Indicador_Erro);
                Manipulador.Erro.Indicador = gce();
            else
                Manipulador.Erro.Indicador.data = [5, 0; 3.5*cosd(Angulo) + 9,3.5*sind(Angulo) - 0];
                Manipulador.Erro.Indicador.segs_color = Cor_Indicador_Erro;
            end

            // Simulando onde o carro está agora
            if iteracao == 1 then
                subplot(222);
                plot(Posicao_Terreno,Terreno_Altura);
                plot2d(Veiculo.Posicao(iteracao),Veiculo.Altura(iteracao),-12);
                Manipulador.Posicao_Veiculo = gce();
                Manipulador_Eixos = gca();
                Manipulador_Eixos.data_bounds(1,2) = Manipulador_Eixos.data_bounds(1,2) - 1;
                Manipulador_Eixos.data_bounds(2,2) = Manipulador_Eixos.data_bounds(2,2) + 1;
                Manipulador_Eixos.grid = [1 1];
                title('Caminho percorrido pelo ' + Veiculo.Fabricante + " " + Veiculo.Modelo, 'fontsize', 3);
                xlabel('Distancia(m)', 'fontsize', 3); ylabel('Altura(m)', 'fontsize', 3);
            else
                Manipulador.Posicao_Veiculo.children.data = [Veiculo.Posicao(iteracao),Veiculo.Altura(iteracao)];
            end

            // Grafico do acelerador
            Acelerador_Normatizado = Veiculo.Acelerador(iteracao) / 100.0;
            if iteracao == 1 then
                subplot(245);
                xfrect(-0.5,Acelerador_Normatizado,1,Acelerador_Normatizado); //Preenchimento
                Manipulador.Acelerador = gce();
                Manipulador.Acelerador.background = color("blue");
                xrect(-0.5,1,1,1); //Borda
                gce().foreground = color("scilabgreen4");
                title('Acelerador', 'fontsize', 3);
                ylabel('Atuação', 'fontsize', 3);

            else
                Manipulador.Acelerador.data = [-0.5,Acelerador_Normatizado,1,Acelerador_Normatizado];
            end

            // Gráfico do freio
            Freio_Normatizado = -Veiculo.Freio(iteracao) / 200.0;
            if iteracao == 1 then
                subplot(246);
                xfrect(-0.5,Freio_Normatizado,1,Freio_Normatizado); //preenchimento
                Manipulador.Freio = gce();
                Manipulador.Freio.background = color("red");
                xrect(-0.5,1,1,1); //Borda
                gce().foreground = color("black");
                title('Freio', 'fontsize', 3);
                ylabel('Atuação', 'fontsize', 3);

            else
                Manipulador.Freio.data = [-0.5,Freio_Normatizado,1,Freio_Normatizado];
            end

            // Grafico do P
            if iteracao == 1 then
                subplot(2,6,10);
                xfrect(-0.5,0.5,1,0); //Preenchimento
                Manipulador.Controle.P = gce();
                xrect(-0.5,1,1,1); //Borda
                gce().foreground = color("scilabgreen4");
                title('Proporcional', 'fontsize', 3);
                ylabel('Atuação', 'fontsize', 3);

            else
                P_Normatizado = Veiculo.Controlador.Calculo_Proporcional(iteracao) / 100.0 / 2;
                if (P_Normatizado > 0.5) then
                    P_Normatizado = 0.5;
                end
                if (P_Normatizado < -0.5) then
                    P_Normatizado = -0.5;
                end
                if (P_Normatizado > 0) then
                    Manipulador.Controle.P.data = [-0.5,P_Normatizado + 0.5,1,P_Normatizado];
                    Manipulador.Controle.P.background = color("blue");
                else
                    Manipulador.Controle.P.data = [-0.5,0.5,1,-P_Normatizado];
                    Manipulador.Controle.P.background = color("red");
                end
            end


            // Gráfico do I
            if iteracao == 1 then
                subplot(2,6,11);
                xfrect(-0.5,0.5,1,0); //Preenchimento
                Manipulador.Controle.I = gce();
                xrect(-0.5,1,1,1); //Borda
                gce().foreground = color("scilabgreen4");
                title('Integral', 'fontsize', 3); 
                ylabel('Atuação', 'fontsize', 3);
            else
                I_Normatizado = Veiculo.Controlador.Calculo_Integral(iteracao) / 100.0 / 2;
                if (I_Normatizado > 0.5) then
                    I_Normatizado = 0.5;
                end
                if (I_Normatizado < -0.5) then
                    I_Normatizado = -0.5;
                end
                if (I_Normatizado > 0) then
                    Manipulador.Controle.I.data = [-0.5,I_Normatizado + 0.5,1,I_Normatizado];
                    Manipulador.Controle.I.background = color("blue");
                else
                    Manipulador.Controle.I.data = [-0.5,0.5,1,-I_Normatizado];
                    Manipulador.Controle.I.background = color("red");
                end
            end

            // Grafico do D
            if iteracao == 1 then
                subplot(2,6,12);
                xfrect(-0.5,0.5,1,0);
                Manipulador.Controle.D = gce();
                xrect(-0.5,1,1,1)
                gce().foreground = color("scilabgreen4");
                title('Derivativo', 'fontsize', 3);
                ylabel('Atuação', 'fontsize', 3);
            else
                D_Normatizado = Veiculo.Controlador.Calculo_Derivativo(iteracao) / 100.0 / 2;
                if (D_Normatizado > 0.5) then
                    D_Normatizado = 0.5;
                end
                if (D_Normatizado < -0.5) then
                    D_Normatizado = -0.5;
                end
                if (D_Normatizado > 0) then
                    Manipulador.Controle.D.data = [-0.5,D_Normatizado + 0.5,1,D_Normatizado];
                    Manipulador.Controle.D.background = color("blue");
                else
                    Manipulador.Controle.D.data = [-0.5,0.5,1,-D_Normatizado];
                    Manipulador.Controle.D.background = color("red");
                end
            end

            drawnow(); // desenhando a figura corrente
            //xs2gif(ID_Visualizaçao_Calculos, 'C:\Users\Ricardo\Downloads\Temp\Nova pasta\T' + string(temporizador) + '.gif');
            realtime(iteracao/Velocidade_Simulacao); //Sincroniza a simulação com o "tempo real"
        end
        if (toc() > Temporizador_Status)
            Temporizador_Status = toc() + 0.2;
        end
    end
    close(ID_Visualizaçao_Calculos);
endfunction
