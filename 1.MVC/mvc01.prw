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

    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias('tabela_base')

    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas
    oBrowse:AddLegend( condicao, "cor","descricao" )

    //Ativa a Browse
    oBrowse:Activate()

    FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
    Cria��o do menu MVC
    @author  Kayke Laurindo
    @since   20-06-2023
/*/

Static Function MenuDef()
    Local aRot := {}

    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.mvc01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.mvc01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.mvc01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.mvc01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*/{Protheus.doc} ModelDef
    Cria��o do modelo de dados MVC 
    @author  Kayke Laurindo
    @since   20-06-2023
/*/

Static Function ModelDef()
    //Cria��o do objeto do modelo de dados
    Local oModel := Nil

    //Cria��o da estrutura de dados utilizada na interface
    Local oSttabela_base := FWFormStruct(1, "tabela_base")

    //Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("mvc01M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

    //Atribuindo formul�rios para o modelo
    oModel:AddFields("FORMtabela_base",/*cOwner*/,oSttabela_base)

    //Setando a chave prim�ria da rotina Ex: 'BM_FILIAL','BM_GRUPO'
    oModel:SetPrimaryKey({"campos_tabela_base"},{"campos_tabela_base"})

    //Adicionando descri��o ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMtabela_base"):SetDescription("Formul�rio do Cadastro "+cTitulo)
Return oModel

/*/{Protheus.doc} ViewDef
    Cria��o da vis�o MVC 
    @author  Kayke Laurindo
    @since   20-06-2023
/*/

Static Function ViewDef()
    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("mvc01")

    //Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
    Local oSttabela_base := FWFormStruct(2, "tabela_base")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

    //Criando oView como nulo
    Local oView := Nil

    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_tabela_base", oSttabela_base, "FORMtabela_base")

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)

    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_tabela_base', 'Dados do ' + cTitulo )  

    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})

    //O formul�rio da interface ser� colocado dentro do container
    oView:SetOwnerView("VIEW_tabela_base","TELA")
Return oView
