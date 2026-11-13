# language: pt
@issue_2
Funcionalidade: Recarga de saldo
  Como estudante
  Quero adicionar créditos à minha conta via PIX ou cartão de crédito
  Para que eu tenha saldo suficiente para acessar os restaurantes

  Contexto:
    Dado que o estudante está autenticado no Portal do Estudante RU UnB
    E acessou a seção de "Recarga"

  Cenário: Selecionar um pacote predefinido de refeições
    Dado que o estudante visualiza os pacotes de refeições disponíveis
    Quando seleciona o pacote de "5 Refeições" no valor de "R$ 22,50"
    E escolhe o método de pagamento "PIX Instantâneo"
    Então o resumo da recarga deve exibir "5 refeições" com o total de "R$ 22,50"
    E o novo saldo estimado deve ser atualizado para "9 refs (R$ 40,50)"

  Cenário: Definir uma quantidade personalizada de refeições
    Dado que o estudante opta por informar uma quantidade personalizada
    Quando define a quantidade de "5" refeições utilizando os botões de ajuste
    Então o sistema deve calcular automaticamente o valor total de "R$ 22,50" com base na tarifa unitária de "R$ 4,50"
    E o resumo da recarga deve refletir o valor total correspondente

  Cenário: Gerar o QR Code para pagamento via PIX instantâneo
    Dado que o estudante selecionou um pacote de recarga
    Quando seleciona o método de pagamento "PIX Instantâneo"
    Então o sistema deve exibir o QR Code para leitura no aplicativo do banco
    E deve disponibilizar a chave PIX copia e cola com o botão "Copiar Código"

  Cenário: Confirmar a recarga de créditos com sucesso
    Dado que o estudante configurou a recarga de "5 Refeições" via "PIX Instantâneo"
    E o resumo da recarga está correto com o total de "R$ 22,50"
    Quando clica no botão "Confirmar"
    Então a recarga deve ser processada com sucesso
    E os créditos devem ser adicionados ao saldo atual da conta