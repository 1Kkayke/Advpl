#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} mvc02
    Cadastro MVC Modelo 2
    @author  Kayke Laurindo
    @since   20-06-2023
 /*/

User Function mvc02()
    Local aArea       := FWGetArea()
    Local oBrowse
    Local cTitulo     := "titulo_browse"
    Private cEnchoice := "titulo_enchoice"
    Private cGrid     := "titulo_grid"

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
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.mvc02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.mvc02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.mvc02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.mvc02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

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
    Local oSttabela_filho := FWFormStruct(1, "tabela_filho")

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("mvc02M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 

    //Removendo campos da estrutura de dados do formulário
    oSttabela_base:RemoveField("campos_tabela_base")

    //Removendo campos da estrutura de dados da grid
    oSttabela_filho:RemoveField("campos_tabela_filho")

    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMtabela_base",/*cOwner*/,oSttabela_base)

    //Atribuindo grid para o modelo
    oModel:AddGrid("GRIDtabela_filho","GRIDtabela_filho",oSttabela_filho,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bLinePost*/)

    //Setando a chave primária da rotina Ex: 'BM_FILIAL','BM_GRUPO'
    oModel:SetPrimaryKey({"campos_tabela_base"},{"campos_tabela_base"})

    //Setando a chave estrangeira da rotina Ex: 'BM_FILIAL','BM_GRUPO'
    oModel:SetRelation( "GRIDtabela_filho", { {"campos_tabela_base","campos_tabela_base"} }, tabela_base->( IndexKey( 1 ) ) )
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

    //Setando a descrição do formulário
    oModel:GetModel("FORMtabela_base"):SetDescription("Formulário do Cadastro "+ cEnchoice)

    //Setando a descrição do grid
    oModel:GetModel("GRIDtabela_filho"):SetDescription("GRID do Cadastro "+ cGrid)

Return oModel

/*/{Protheus.doc} ViewDef
    Criação da visão MVC 
    @author  Kayke Laurindo
    @since   20-06-2023
/*/

Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("mvc02")

    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oSttabela_base := FWFormStruct(2, "tabela_base")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oSttabela_filho := FWFormStruct(2, "tabela_filho")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

    //Criando oView como nulo
    Local oView := Nil

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Removendo campos da estrutura de dados do formulário
    oSttabela_base:RemoveField("campos_tabela_base")

    //Removendo campos da estrutura de dados da grid
    oSttabela_filho:RemoveField("campos_tabela_filho")

    //Atribuindo formulários para interface
    oView:AddField("VIEW_tabela_base", oSttabela_base, "FORMtabela_base")

    //Atribuindo grid para interface
    oView:AddGrid( "VIEW_tabela_filho", oSttabela_filho, "GRIDtabela_filho" )

    //Atribuindo valor incremental para campo na grid
    oView:AddIncrementField("VIEW_tabela_filho", "campos_tabela_filho" )

    //Criando um container com nome superior com 40%
    oView:CreateHorizontalBox("SUPERIOR",40)

    //Criando um container com nome inferior com 60%
    oView:CreateHorizontalBox("INFERIOR",60)

    //Colocando título do formulário
    oView:EnableTitleView("VIEW_tabela_base", "Dados do " + cEnchoice )  

    //Colocando título da grid
    oView:EnableTitleView("VIEW_tabela_filho", "Dados da " + cGrid )  

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_tabela_base","SUPERIOR")

    //A grid da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_tabela_filho","INFERIOR")

Return oView
