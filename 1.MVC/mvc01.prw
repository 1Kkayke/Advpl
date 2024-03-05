#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} mvc01
    Cadastro MVC Modelo 1

    @author  Kayke Laurindo
    @since   20-06-2023
    @see     https://tdn.totvs.com/display/public/framework/AdvPl+utilizando+MVC?preview=/6814840/458769351/AdvPL%20utilizando%20MVC%20v2%20-%20POR.pdf
/*/

User Function mvc01()
    Local aArea   := FWGetArea()
    Local oBrowse

    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias('tabela_base')

    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas
    oBrowse:AddLegend( condicao, "cor","descricao" )

    //Ativa a Browse
    oBrowse:Activate()

    FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
    Criação do menu MVC
    @author  Kayke Laurindo
    @since   20-06-2023
/*/

Static Function MenuDef()
    Local aRot := {}

    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.mvc01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.mvc01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.mvc01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.mvc01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*/{Protheus.doc} ModelDef
    Criação do modelo de dados MVC 
    @author  Kayke Laurindo
    @since   20-06-2023
/*/

Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil

    //Criação da estrutura de dados utilizada na interface
    Local oSttabela_base := FWFormStruct(1, "tabela_base")

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("mvc01M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMtabela_base",/*cOwner*/,oSttabela_base)

    //Setando a chave primária da rotina Ex: 'BM_FILIAL','BM_GRUPO'
    oModel:SetPrimaryKey({"campos_tabela_base"},{"campos_tabela_base"})

    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

    //Setando a descrição do formulário
    oModel:GetModel("FORMtabela_base"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel

/*/{Protheus.doc} ViewDef
    Criação da visão MVC 
    @author  Kayke Laurindo
    @since   20-06-2023
/*/

Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("mvc01")

    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oSttabela_base := FWFormStruct(2, "tabela_base")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

    //Criando oView como nulo
    Local oView := Nil

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Atribuindo formulários para interface
    oView:AddField("VIEW_tabela_base", oSttabela_base, "FORMtabela_base")

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)

    //Colocando título do formulário
    oView:EnableTitleView('VIEW_tabela_base', 'Dados do ' + cTitulo )  

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_tabela_base","TELA")
Return oView
