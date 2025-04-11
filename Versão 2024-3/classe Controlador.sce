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
function Controlador = Controlador_Criar()
    Controlador.Kp = 1;
    Controlador.Ki = 0;
    Controlador.Kd = 0;
    Controlador.S0 = 0;         // Controle Proporcional
    Controlador.Histerese = 0;  // Controle ON-OFF
    Controlador.Passo = 0.05;
    Controlador.Iteracao = 1;
    Controlador.Modo = %T; // PID = %T; Demais = %F
    // Cria os vetores que salvam os dados ao longo do tempo
    Controlador.Varivel_Manipulada(Controlador.Iteracao) = 0;
    Controlador.Calculo_Proporcional(Controlador.Iteracao) = 0;
    Controlador.Calculo_Integral(Controlador.Iteracao) = 0;
    Controlador.Calculo_Derivativo(Controlador.Iteracao) = 0;
    Controlador.Erro(Controlador.Iteracao) = 0;
endfunction

function Controlador = Controlador_Redimensionar_Vetores(Controlador, Tamanho)
    Controlador.Varivel_Manipulada = resize_matrix(Controlador.Varivel_Manipulada, Tamanho, 1);
    Controlador.Calculo_Proporcional = resize_matrix(Controlador.Calculo_Proporcional, Tamanho, 1);
    Controlador.Calculo_Integral = resize_matrix(Controlador.Calculo_Integral, Tamanho, 1);
    Controlador.Calculo_Derivativo = resize_matrix(Controlador.Calculo_Derivativo, Tamanho, 1);
    Controlador.Erro = resize_matrix(Controlador.Erro, Tamanho, 1);
endfunction

function Controlador = Controlador_Configurar(Controlador, Parametro, Valor)
    select Parametro
    case "-Kp"
        Controlador.Kp = Valor;

    case "-Ki"
        Controlador.Ki = Valor;

    case "-Kd"
        Controlador.Kd = Valor;

    case "-S0"
        Controlador.S0 = Valor;

    case "-Histerese"
        Controlador.Histerese = Valor;

    case "-Modo"
        if Valor == "PID" then
            Controlador.Modo = %T; //Controlador PID
        else
            Controlador.Modo = Valor
        end
    case "-Passo"
        Controlador.Passo = Valor;

    else
        errmsg = sprintf (" Parametro %s desconhecido" , Parametro);
        error (errmsg);
    end
endfunction

function Controlador_Controlar(Erro)
    global Controlador
    if (Controlador.Modo == "Proporcional") then
        // Parcela proporcional
        Controlador.Calculo_Proporcional(Controlador.Iteracao) = Erro * Controlador.Kp + Controlador.S0;

        // Construção da MV
        Controlador.Varivel_Manipulada(Controlador.Iteracao) = Controlador.Calculo_Proporcional(Controlador.Iteracao);
    end

    if (Controlador.Modo == "ON-OFF") then
        // Construção do Controlador ON-OFF
        global Acelerador
        if Erro*3.6 > Controlador.Histerese then
            Acelerador = 100;
        end

        if Erro*3.6 < -Controlador.Histerese then
            Acelerador = -100;
        end
        Controlador.Varivel_Manipulada(Controlador.Iteracao) = Acelerador;
    end
endfunction
